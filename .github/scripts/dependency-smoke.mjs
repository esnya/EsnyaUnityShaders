import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createRequire, syncBuiltinESMExports} from 'node:module';
import {pathToFileURL} from 'node:url';
import net from 'node:net';
import tls from 'node:tls';
import http from 'node:http';
import https from 'node:https';
import childProcess from 'node:child_process';

const project=path.resolve(process.argv[2] || ".");
const mode="shaders";
process.chdir(project);
const require=createRequire(path.join(project,'package.json'));
const attempts=[];
const deny=kind=>()=>{attempts.push(kind);throw new Error(`Hermetic check blocked ${kind}`);};
net.Socket.prototype.connect=deny('network socket');
tls.connect=deny('TLS socket');
http.request=deny('HTTP request');
https.request=deny('HTTPS request');
globalThis.fetch=deny('global fetch');
for(const key of ['spawn','spawnSync','exec','execSync','execFile','execFileSync','fork'])childProcess[key]=deny('child process '+key);
syncBuiltinESMExports();
const version=name=>JSON.parse(fs.readFileSync(path.join(project,'node_modules',name,'package.json'),'utf8')).version;
assert.equal(process.versions.node,'24.22.1');
assert.equal(version('handlebars'),'4.7.10');
assert.equal(version('minimist'),'1.2.8');
const h=require('handlebars').create();
assert.equal(h.compile('{{#each values}}{{@index}}={{this}};{{/each}}')({values:['a','<b>']}),'0=a;1=&lt;b&gt;;');
h.registerPartial('row','[{{name}}]');
assert.equal(h.compile('{{#each items}}{{> row}}{{/each}}')({items:[{name:'one'},{name:'two'}]}),'[one][two]');
const ast=h.parse('{{#if ok}}safe{{/if}}');
ast.body[0].program.blockParams={length:'0'};
assert.throws(()=>h.compile(ast)({ok:true}));
assert.equal(h.compile('{{lookup subject "constructor"}}')({subject:Function.prototype},{allowProtoMethodsByDefault:true}),'');
const imports=[];
for(const name of ['semantic-release','@semantic-release/exec','@semantic-release/git','@semantic-release/github','@semantic-release/npm','semantic-release-gitmoji','semantic-release-monorepo']){
 const loaded=await import(pathToFileURL(require.resolve(name)).href);assert.ok(Object.keys(loaded).length>0,name);imports.push(name);
}
const gitmoji=require('semantic-release-gitmoji');
const ReleaseNotes=require(path.join(path.dirname(require.resolve('semantic-release-gitmoji')),'lib/release-notes.js'));
const context={options:{repositoryUrl:'https://github.com/example/public-fixture.git'},commits:[],lastRelease:{version:'0.1.0',gitTag:'v0.1.0',gitHead:'b'.repeat(40)},nextRelease:{version:'0.1.1',gitTag:'v0.1.1',gitHead:'a'.repeat(40)},logger:{log(){},warn(){},error(){},success(){}}};
let commitIndex=0;
for(const [emoji,expected] of [['\u{1f4a5}','major'],['\u2728','minor'],['\u{1f41b}','patch']]){
 // Each CLI invocation normally gets a fresh singleton; isolate independent fixtures in this guarded process.
 ReleaseNotes._instance=undefined;
 const title=emoji+' keep release notes compatible (#12)';const checkContext={...context,commits:[{hash:(++commitIndex).toString(16).repeat(40),subject:title,message:title,body:''}]};
 assert.equal(await gitmoji.analyzeCommits({},checkContext),expected);
 assert.match(await gitmoji.generateNotes({},checkContext),/keep release notes compatible/);
}

 assert.equal(version('npm'),'11.21.1');assert.equal(version('lodash'),'4.18.1');
 const yaml=require('js-yaml');assert.deepEqual(yaml.load('name: fixture\nvalues: [1, 2]\n'),{name:'fixture',values:[1,2]});
 const yaml3=require(path.join(project,'node_modules/unitypackage/node_modules/js-yaml'));
 assert.deepEqual(yaml3.safeLoad('name: fixture\n'),{name:'fixture'});assert.throws(()=>yaml3.safeLoad('x: !!js/function "function () { return 1; }"'));
 const lodash=require('lodash');assert.deepEqual(lodash.merge({a:{x:1}},{a:{y:2}}),{a:{x:1,y:2}});
 lodash.merge({},JSON.parse('{"__proto__":{"fixturePolluted":true}}'));assert.equal({}.fixturePolluted,undefined);
 const minimatch=require('minimatch');assert.equal(minimatch('Assets/Fixture.meta','Assets/*.meta'),true);
 const expand=require('brace-expansion');assert.deepEqual(expand('asset-{one,two}.meta'),['asset-one.meta','asset-two.meta']);

const semver=require('semver');
assert.equal(version('semantic-release'),'25.0.0');
assert.equal(version('@semantic-release/npm'),'13.0.0');
assert.equal(version('semantic-release-gitmoji'),'1.6.9');
assert.equal(version('semantic-release-monorepo'),'8.0.1');
assert.equal(version('typescript'),'4.9.5');
assert.equal(version('@natsuneko-laboratory/unitypackage'),'1.1.1');
for(const name of ['semantic-release','@semantic-release/exec','@semantic-release/git','@semantic-release/github','@semantic-release/npm','semantic-release-gitmoji','semantic-release-monorepo']){
 const pkg=JSON.parse(fs.readFileSync(path.join(project,'node_modules',name,'package.json'),'utf8'));
 if(pkg.peerDependencies?.['semantic-release'])assert.ok(semver.satisfies(version('semantic-release'),pkg.peerDependencies['semantic-release']),name+' peer');
 if(pkg.engines?.node)assert.ok(semver.satisfies(process.versions.node,pkg.engines.node),name+' Node engine');
}
const coreRequire=createRequire(require.resolve('semantic-release'));
assert.equal(coreRequire.resolve('@semantic-release/npm'),require.resolve('@semantic-release/npm'));
const unityRequire=createRequire(require.resolve('@natsuneko-laboratory/unitypackage'));
const npmRequire=createRequire(path.join(project,'node_modules/npm/package.json'));
assert.equal(unityRequire('tar/package.json').version,'7.5.22');
assert.equal(npmRequire('tar/package.json').version,'7.5.22');
const lock=JSON.parse(fs.readFileSync(path.join(project,'package-lock.json'),'utf8'));
const tarPaths=Object.entries(lock.packages).filter(([p])=>p.endsWith('node_modules/tar'));
assert.equal(tarPaths.length,2);assert.ok(tarPaths.every(([,record])=>record.version==='7.5.22'));
assert.ok(!Object.entries(lock.packages).some(([p,record])=>p.endsWith('node_modules/cross-spawn')&&record.version.startsWith('5.')));
const monorepo=await import(pathToFileURL(require.resolve('semantic-release-monorepo')).href);
assert.equal(monorepo.tagFormat,JSON.parse(fs.readFileSync(path.join(project,'package.json'),'utf8')).name+'-v${version}');
const config=require('js-yaml').load(fs.readFileSync(path.join(project,'.releaserc.yml'),'utf8'));
assert.equal(config.plugins[1][1].pkgRoot,'Packages/com.nekometer.esnya.esnya-unity-shaders');
assert.equal(config.plugins[1][1].npmPublish,false);assert.equal(config.extends,undefined);assert.equal(config.branches,undefined);
const target=path.resolve(project,config.plugins[1][1].pkgRoot);assert.ok(target.startsWith(project+path.sep));
assert.equal(JSON.parse(fs.readFileSync(path.join(target,'package.json'),'utf8')).name,'com.nekometer.esnya.esnya-unity-shaders');
const githubRequire=createRequire(coreRequire.resolve('@semantic-release/github'));
assert.equal(githubRequire('undici/package.json').version,'7.30.1');
const api=githubRequire('undici');const agent=new api.MockAgent();agent.disableNetConnect();const pool=agent.get('https://fixture.invalid');
pool.intercept({path:'/fixture',method:'GET'}).reply(200,{safe:true},{headers:{'content-type':'application/json'}});
assert.deepEqual(await(await api.fetch('https://fixture.invalid/fixture',{dispatcher:agent})).json(),{safe:true});
await agent.close();

assert.deepEqual(attempts,[]);console.log(JSON.stringify({project:path.basename(project),mode,node:process.version,imports,networkAttempts:0,childProcessAttempts:0,passed:true}));
