import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import vm from 'node:vm';
import {createHash} from 'node:crypto';
import {createRequire, syncBuiltinESMExports} from 'node:module';
import net from 'node:net';
import tls from 'node:tls';
import http from 'node:http';
import https from 'node:https';
import childProcess from 'node:child_process';

const project=path.resolve(process.argv[2] || '.');
const legacyProject=process.argv[3]?path.resolve(process.argv[3]):undefined;
const require=createRequire(path.join(project,'package.json'));
const attempts=[];
const deny=kind=>()=>{attempts.push(kind);throw new Error('Archive fixture blocked '+kind);};
net.Socket.prototype.connect=deny('network');tls.connect=deny('TLS');
http.request=deny('HTTP');https.request=deny('HTTPS');globalThis.fetch=deny('fetch');
for(const name of ['spawn','spawnSync','exec','execSync','execFile','execFileSync','fork'])childProcess[name]=deny('child process '+name);
const created=new Set();
const temporaryRoot=path.resolve(os.tmpdir());
const mkdtemp=fs.promises.mkdtemp.bind(fs.promises);
fs.promises.mkdtemp=async(...args)=>{
 const result=path.resolve(await mkdtemp(...args));
 assert.ok(result.startsWith(temporaryRoot+path.sep));created.add(result);return result;
};
const confined=target=>{
 const absolute=path.resolve(String(target));
 assert.ok([...created].some(p=>absolute===p||absolute.startsWith(p+path.sep)),'Cleanup stays in fixture-created directories');
 return absolute;
};
const remove=fs.promises.rm.bind(fs.promises);
fs.promises.rm=async(target,options)=>{if(options?.recursive)confined(target);return remove(target,options);};
syncBuiltinESMExports();
assert.equal(process.versions.node,'24.22.1');
const unityRequire=createRequire(require.resolve('@natsuneko-laboratory/unitypackage'));
const tar=unityRequire('tar');
assert.equal(unityRequire('tar/package.json').version,'7.5.22');
const archive=require('@natsuneko-laboratory/unitypackage').archive;
const ts=require('typescript');
const callerPath=path.join(project,'.github/scripts/create-unitypackage.ts');
const source=fs.readFileSync(callerPath,'utf8');
const ast=ts.createSourceFile(callerPath,source,ts.ScriptTarget.Latest,true,ts.ScriptKind.TS);
const calls=[];
const visit=node=>{if(ts.isCallExpression(node)&&ts.isIdentifier(node.expression)&&node.expression.text==='archive')calls.push(node);ts.forEachChild(node,visit);};
visit(ast);assert.equal(calls.length,1);assert.equal(calls[0].arguments.length,1);assert.ok(ts.isObjectLiteralExpression(calls[0].arguments[0]));
const oldSource=source.slice(0,calls[0].getStart(ast))+'archive(metaFiles.map((p) => path.relative(tmp, p)), tmp, unitypackageName)'+source.slice(calls[0].getEnd());
const directoryFilter='?.filter((w: string) => fs.statSync(w).isDirectory())';
assert.equal(source.split(directoryFilter).length,2);
let fixture;
const loadCaller=(text,requireFrom,withControl=false,full=false,record)=>{
 const boundary=text.indexOf('\n(async () => {');assert.ok(boundary>0);
 const javascript=ts.transpileModule(full?text:text.slice(0,boundary),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.CommonJS,esModuleInterop:true}}).outputText;
 const guardedRequire=name=>{
  assert.ok(['@natsuneko-laboratory/unitypackage','fs','glob','mkdirp','path','os','rimraf','recursive-copy'].includes(name));
  if(name==='rimraf'){const actual=requireFrom(name);return (target,...args)=>actual(confined(target),...args);}
  if(name==='fs'&&full)return {...fs,promises:{...fs.promises,readFile:async(target,...args)=>{if(/\.meta[\\/]package\.json$/.test(String(target)))record.metadataManifestReads.push(String(target));return fs.promises.readFile(target,...args);}}};
  if(name==='@natsuneko-laboratory/unitypackage'&&full&&!withControl)return {archive:async(...args)=>{record.destinations.push(args[2]);return requireFrom(name).archive(...args);}};
  if(name==='@natsuneko-laboratory/unitypackage'&&withControl)return {archive:async args=>{
   if(record)record.destinations.push(args.dest);
   assert.ok(args.files.every(p=>path.isAbsolute(p)&&!p.endsWith('.meta')&&p.startsWith(args.root+path.sep)));
   assert.ok(created.has(path.resolve(args.root)));assert.ok(path.resolve(args.dest).startsWith(fixture+path.sep));
   await archive(args);await archive({...args,dest:args.dest+'.control'});
  }};
  return requireFrom(name);
 };
 const run=()=>vm.runInNewContext(javascript+(full?'':'\n;createUnityPackage'),{require:guardedRequire,exports:{},console:{log(){},error(error){record.errors.push({code:error.code,message:String(error.message)});}},process:{env:{VERSION:'9.8.7-fixture'},cwd:()=>process.cwd()}},{filename:callerPath,timeout:15000});
 return full?run:run();
};
const incompatibleCaller=loadCaller(oldSource,require);
const legacyRequire=legacyProject?createRequire(path.join(legacyProject,'package.json')):undefined;
fixture=await fs.promises.mkdtemp(path.join(temporaryRoot,'shader-archive-fixture-'));
await fs.promises.mkdir(path.join(fixture,'dist'));
const folderGuid='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',fileGuid='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
const folderMeta=`fileFormatVersion: 2\nguid: ${folderGuid}\nfolderAsset: yes\nDefaultImporter:\n  externalObjects: {}\n`;
const fileMeta=`fileFormatVersion: 2\nguid: ${fileGuid}\nTextScriptImporter:\n  externalObjects: {}\n`;
const manifests=path.join(project,'Packages');
const workspaces=fs.readdirSync(manifests,{withFileTypes:true}).filter(entry=>entry.isDirectory()).map(entry=>({folder:entry.name,...JSON.parse(fs.readFileSync(path.join(manifests,entry.name,'package.json'),'utf8'))}));
assert.deepEqual(workspaces.map(p=>p.name).sort(),[
 'com.nekometer.esnya.esnya-osakana-shader','com.nekometer.esnya.esnya-pbr-shader',
 'com.nekometer.esnya.esnya-toon-shader','com.nekometer.esnya.esnya-unity-shaders',
]);
for(const workspace of workspaces){
 const location=path.join(fixture,'Packages',workspace.folder);await fs.promises.mkdir(location,{recursive:true});
 await fs.promises.writeFile(path.join(location,'package.json'),JSON.stringify({name:workspace.name,displayName:workspace.displayName}));
 await fs.promises.writeFile(location+'.meta',folderMeta);await fs.promises.writeFile(path.join(location,'fixture.txt'),'fixture payload\n');
 await fs.promises.writeFile(path.join(location,'fixture.txt.meta'),fileMeta);
}
const entries=async file=>{
 const result=new Map(),pending=[];
 await tar.t({file,onentry:entry=>{
  const chunks=[];const key=entry.path.replace(/^\.\//,'').replace(/\/$/,'');
  pending.push(new Promise((resolve,reject)=>{entry.on('data',chunk=>chunks.push(chunk));entry.on('error',reject);entry.on('end',()=>{result.set(key,Buffer.concat(chunks));resolve();});}));entry.resume();
 }});await Promise.all(pending);return result;
};
const results=[];const priorCwd=process.cwd();
const originalScheduler={errors:[],metadataManifestReads:[],destinations:[]};
const fullCandidate={errors:[],metadataManifestReads:[],destinations:[]};
const legacyEntries=new Map();
try{
 process.chdir(fixture);
 await fs.promises.writeFile(path.join(fixture,'package.json'),JSON.stringify({name:'public-archive-fixture',workspaces:['Packages/*']}));
 const broken=loadCaller(source.replace(directoryFilter,''),require,true,true,originalScheduler)();
 assert.equal(typeof broken?.then,'function');await broken;
 assert.equal(originalScheduler.errors.length,1);assert.equal(originalScheduler.metadataManifestReads.length,1);assert.match(originalScheduler.errors[0].message,/\.meta/);assert.ok(originalScheduler.destinations.length<4);
 await assert.rejects(()=>incompatibleCaller(path.join(fixture,'Packages',workspaces[0].folder)),/map|undefined/);
 if(legacyRequire){
  const record={errors:[],metadataManifestReads:[],destinations:[]};
  await loadCaller(oldSource,legacyRequire,false,true,record)();assert.deepEqual(record.errors,[]);assert.equal(record.destinations.length,4);
  for(const workspace of workspaces){
   const safeName=workspace.displayName.replace(/[\s\\\/]/g,'-');const outputName=safeName+'-v9.8.7-fixture.unitypackage';
   const Zip=legacyRequire('adm-zip');const entry=new Zip(path.join(fixture,'dist',outputName)).getEntry('archtemp.tar');assert.ok(entry);
   const decoded=path.join(fixture,safeName+'-legacy.tar');await fs.promises.writeFile(decoded,entry.getData());legacyEntries.set(outputName,await entries(decoded));
  }
 }
 await loadCaller(source,require,true,true,fullCandidate)();assert.deepEqual(fullCandidate.errors,[]);assert.deepEqual(fullCandidate.metadataManifestReads,[]);assert.equal(fullCandidate.destinations.length,4);
 for(const workspace of workspaces){
  const location=path.join(fixture,'Packages',workspace.folder);const safeName=workspace.displayName.replace(/[\s\\\/]/g,'-');
  const outputName=safeName+'-v9.8.7-fixture.unitypackage';const destination=path.join(fixture,'dist',outputName);
  const previous=legacyEntries.get(outputName);
  const actual=await entries(destination);const control=await entries(destination+'.control');
  const bytes=fs.readFileSync(destination);assert.deepEqual([...bytes.subarray(0,2)],[0x1f,0x8b]);assert.ok(bytes.length<65536);
  const expected=new Map([[folderGuid+'/asset.meta',folderMeta],[folderGuid+'/pathname','Assets/'+safeName],[fileGuid+'/asset.meta',fileMeta],[fileGuid+'/pathname','Assets/'+safeName+'/fixture.txt'],[fileGuid+'/asset','fixture payload\n']]);
  for(const[key,value]of expected){assert.equal(actual.get(key)?.toString(),value,key);assert.deepEqual(actual.get(key),control.get(key));if(previous)assert.deepEqual(actual.get(key),previous.get(key));}
  assert.deepEqual([...new Set([...actual.keys()].map(k=>k.split('/')[0]))].sort(),[folderGuid,fileGuid]);
  const contentSha256=createHash('sha256').update([...expected.keys()].sort().map(key=>key+'\0'+actual.get(key).toString('base64')).join('\n')).digest('hex');
  results.push({name:workspace.name,outputName,essentialEntries:expected.size,contentSha256,legacyCompared:!!previous});
 }
}finally{process.chdir(priorCwd);await fs.promises.rm(fixture,{recursive:true,force:true});}
assert.deepEqual(attempts,[]);
console.log(JSON.stringify({node:process.version,fixtureOnly:true,fullCaller:true,workspaceResults:results,originalSchedulerFailure:{error:originalScheduler.errors[0],metadataManifestReads:originalScheduler.metadataManifestReads.length,workspaceCalls:originalScheduler.destinations.length},candidateWorkspaceCalls:fullCandidate.destinations.length,positionalApiRejected:true,format:'gzip-tar',networkAttempts:0,childProcessAttempts:0,releaseEngineInvocations:0,passed:true}));
