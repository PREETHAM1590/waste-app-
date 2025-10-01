// Simple HTTP server to serve test webapp
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3002;

const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.wav': 'audio/wav',
  '.mp4': 'video/mp4',
  '.woff': 'application/font-woff',
  '.ttf': 'application/font-ttf',
  '.eot': 'application/vnd.ms-fontobject',
  '.otf': 'application/font-otf',
  '.wasm': 'application/wasm'
};

const server = http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);
  
  // Handle CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  
  let filePath = '.' + req.url;
  
  // Default to index.html
  if (filePath === './') {
    filePath = './index.html';
  }
  
  // Redirect /advanced to advanced.html
  if (filePath === './advanced') {
    filePath = './advanced.html';
  }
  
  const extname = String(path.extname(filePath)).toLowerCase();
  const mimeType = mimeTypes[extname] || 'application/octet-stream';
  
  fs.readFile(filePath, (error, content) => {
    if (error) {
      if (error.code === 'ENOENT') {
        // File not found
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end(`
          <html>
            <body style="font-family: Arial; padding: 20px; background: #0b1220; color: #e8f0ff;">
              <h1>404 - File Not Found</h1>
              <p>Available pages:</p>
              <ul>
                <li><a href="/" style="color: #2dd4bf;">Simple Tester</a></li>
                <li><a href="/advanced" style="color: #2dd4bf;">Advanced Tester</a></li>
              </ul>
            </body>
          </html>
        `, 'utf-8');
      } else {
        res.writeHead(500);
        res.end('Sorry, check with the site admin for error: ' + error.code + ' ..\n');
      }
    } else {
      res.writeHead(200, { 'Content-Type': mimeType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(PORT, () => {
  console.log(`🌐 Test webapp server running at http://localhost:${PORT}`);
  console.log(`📱 Simple tester: http://localhost:${PORT}`);
  console.log(`🎯 Advanced tester: http://localhost:${PORT}/advanced`);
  console.log(`🔗 API server should be running at http://localhost:3001`);
});

server.on('error', (e) => {
  if (e.code === 'EADDRINUSE') {
    console.log(`Port ${PORT} is already in use. Try stopping other servers or use a different port.`);
  } else {
    console.log('Server error:', e);
  }
});
