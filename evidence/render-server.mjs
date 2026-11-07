import http from 'node:http';
import fs from 'node:fs';
const root='C:/Users/pavel/Documents/DeepSeekHarness/cache/netology-20261107/w-1301';
const files=new Set(['01-services.html','02-tcp.html','03-udp.html']);
http.createServer((req,res)=>{const name=req.url.slice(1); if(!files.has(name)){res.writeHead(404);res.end();return;} res.writeHead(200,{'Content-Type':'text/html; charset=utf-8'});res.end(fs.readFileSync(root+'/'+name));}).listen(8131,'127.0.0.1',()=>console.log('Owned local render server http://127.0.0.1:8131, three HTML files only'));
