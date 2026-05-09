/**
 * Integration tests for the brainstorm server.
 *
 * Tests the full server behavior: HTTP serving, WebSocket communication,
 * file watching, and the brainstorming workflow.
 *
 * Uses the `ws` npm package as a test client (test-only dependency,
 * not shipped to end users).
 */

const { spawn } = require('child_process');
const http = require('http');
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');
const assert = require('assert');

const SERVER_PATH = path.join(__dirname, '../../skills/engineering/brainstorming/scripts/server.cjs');
const TEST_PORT = 3334;
const TEST_DIR = '/tmp/brainstorm-test';
const CONTENT_DIR = path.join(TEST_DIR, 'content');
const STATE_DIR = path.join(TEST_DIR, 'state');

function cleanup() {
  if (fs.existsSync(TEST_DIR)) {
    fs.rmSync(TEST_DIR, { recursive: true });
  }
}

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function fetch(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({
        status: res.statusCode,
        headers: res.headers,
        body: data
      }));
    }).on('error', reject);
  });
}

function startServer() {
  return spawn('node', [SERVER_PATH], {
    env: { ...process.env, BRAINSTORM_PORT: TEST_PORT, BRAINSTORM_DIR: TEST_DIR }
  });
}

async function waitForServer(server) {
  let stdout = '';
  let stderr = '';

  return new Promise((resolve, reject) => {
    server.stdout.on('data', (data) => {
      stdout += data.toString();
      if (stdout.includes('server-started')) {
        resolve({ stdout, stderr, getStdout: () => stdout });
      }
    });
    server.stderr.on('data', (data) => { stderr += data.toString(); });
    server.on('error', reject);

    setTimeout(() => reject(new Error(`Server didn't start. stderr: ${stderr}`)), 5000);
  });
}

async function runTests() {
  cleanup();

  const server = startServer();
  let stdoutAccum = '';
  server.stdout.on('data', (data) => { stdoutAccum += data.toString(); });

  const { stdout: initialStdout } = await waitForServer(server);
  let passed = 0;
  let failed = 0;

  function test(name, fn) {
    return fn().then(() => {
      console.log(`  PASS: ${name}`);
      passed++;
    }).catch(e => {
      console.log(`  FAIL: ${name}`);
      console.log(`    ${e.message}`);
      failed++;
    });
  }

  try {
    // ========== Server Startup ==========
    console.log('\n--- Server Startup ---');

    await test('outputs server-started JSON on startup', () => {
      const msg = JSON.parse(initialStdout.trim());
      assert.strictEqual(msg.type, 'server-started');
    });

    await test('creates content directory', () => {
      assert.ok(fs.existsSync(CONTENT_DIR), 'content dir should exist');
    });

    await test('creates state directory', () => {
      assert.ok(fs.existsSync(STATE_DIR), 'state dir should exist');
    });

    await test('HTTP server responds on port', async () => {
      const res = await fetch(`http://localhost:${TEST_PORT}/`);
      assert.strictEqual(res.status, 200);
    });

    // ========== WebSocket Communication ==========
    console.log('\n--- WebSocket Communication ---');

    await test('accepts WebSocket connections', () => {
      return new Promise((resolve, reject) => {
        const ws = new WebSocket(`ws://localhost:${TEST_PORT}`);
        ws.on('open', () => {
          ws.close();
          resolve();
        });
        ws.on('error', reject);
      });
    });

    await test('responds to ping with pong', () => {
      return new Promise((resolve, reject) => {
        const ws = new WebSocket(`ws://localhost:${TEST_PORT}`);
        ws.on('open', () => {
          ws.ping();
        });
        ws.on('pong', () => {
          ws.close();
          resolve();
        });
        ws.on('error', reject);
      });
    });

    // ========== File Watching ==========
    console.log('\n--- File Watching ---');

    await test('detects new content files', () => {
      const testFile = path.join(CONTENT_DIR, 'test-idea.md');
      fs.writeFileSync(testFile, '# Test Idea\n\nThis is a test idea.');

      return new Promise((resolve, reject) => {
        const ws = new WebSocket(`ws://localhost:${TEST_PORT}`);
        ws.on('message', (data) => {
          const msg = JSON.parse(data);
          if (msg.type === 'file-change' && msg.path.includes('test-idea.md')) {
            ws.close();
            resolve();
          }
        });
        ws.on('error', reject);
        // Wait for file watcher to pick up the change
        setTimeout(() => {
          ws.close();
          reject(new Error('File change not detected within timeout'));
        }, 3000);
      });
    });

    // ========== Brainstorming Workflow ==========
    console.log('\n--- Brainstorming Workflow ---');

    await test('serves content via HTTP', async () => {
      const res = await fetch(`http://localhost:${TEST_PORT}/content/test-idea.md`);
      assert.strictEqual(res.status, 200);
      assert.ok(res.body.includes('Test Idea'));
    });

    // ========== Cleanup ==========
    console.log('\n--- Cleanup ---');

    await test('server shuts down cleanly', () => {
      return new Promise((resolve) => {
        server.kill();
        server.on('exit', () => resolve());
      });
    });

  } catch (e) {
    console.error(`Unexpected error: ${e.message}`);
    failed++;
  } finally {
    server.kill();
    await sleep(500);
    cleanup();
  }

  console.log(`\n=== Results: ${passed} passed, ${failed} failed ===`);
  process.exit(failed > 0 ? 1 : 0);
}

runTests().catch(e => {
  console.error(e);
  process.exit(1);
});
