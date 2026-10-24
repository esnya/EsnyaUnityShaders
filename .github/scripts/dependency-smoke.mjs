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
for(const name of ['semantic-release','@semantic-release/exec','@semantic-release/git','@semantic-release/github','@semantic-release/npm','semantic-release-gitmoji']){
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

 assert.equal(version('npm'),'8.19.4');assert.equal(version('lodash'),'4.18.1');
 const yaml=require('js-yaml');assert.deepEqual(yaml.load('name: fixture\nvalues: [1, 2]\n'),{name:'fixture',values:[1,2]});
 const yaml3=require(path.join(project,'node_modules/unitypackage/node_modules/js-yaml'));
 assert.deepEqual(yaml3.safeLoad('name: fixture\n'),{name:'fixture'});assert.throws(()=>yaml3.safeLoad('x: !!js/function "function () { return 1; }"'));
 const lodash=require('lodash');assert.deepEqual(lodash.merge({a:{x:1}},{a:{y:2}}),{a:{x:1,y:2}});
 lodash.merge({},JSON.parse('{"__proto__":{"fixturePolluted":true}}'));assert.equal({}.fixturePolluted,undefined);
 const minimatch=require('minimatch');assert.equal(minimatch('Assets/Fixture.meta','Assets/*.meta'),true);
 const expand=require('brace-expansion');assert.deepEqual(expand('asset-{one,two}.meta'),['asset-one.meta','asset-two.meta']);
assert.deepEqual(attempts,[]);console.log(JSON.stringify({project:path.basename(project),mode,node:process.version,imports,networkAttempts:0,childProcessAttempts:0,passed:true}));
