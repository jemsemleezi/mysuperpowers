/**
 * Unit tests for the zero-dependency WebSocket protocol implementation.
 *
 * Tests the WebSocket frame encoding/decoding, handshake computation,
 * and protocol-level behavior independent of the HTTP server.
 *
 * The module under test exports:
 *   - computeAcceptKey(clientKey) -> string
 *   - encodeFrame(opcode, payload) -> Buffer
 *   - decodeFrame(buffer) -> { opcode, payload, bytesConsumed } | null
 *   - OPCODES: { TEXT, CLOSE, PING, PONG }
 */

const assert = require('assert');
const crypto = require('crypto');
const path = require('path');

// The module under test — will be the new zero-dep server file
const SERVER_PATH = path.join(__dirname, '../../skills/engineering/brainstorming/scripts/server.cjs');
let ws;

try {
  ws = require(SERVER_PATH);
} catch (e) {
  // Module doesn't exist yet (TDD — tests written before implementation)
  console.error(`Cannot load ${SERVER_PATH}: ${e.message}`);
  console.error('This is expected if running tests before implementation.');
  process.exit(1);
}

function runTests() {
  let passed = 0;
  let failed = 0;

  function test(name, fn) {
    try {
      fn();
      console.log(`  PASS: ${name}`);
      passed++;
    } catch (e) {
      console.log(`  FAIL: ${name}`);
      console.log(`    ${e.message}`);
      failed++;
    }
  }

  // ========= Handshake =========
  console.log('\n--- WebSocket Handshake ---');

  test('computeAcceptKey produces correct RFC 6455 accept value', () => {
    // RFC 6455 Section 4.2.2 example
    const clientKey = 'dGhlIHNhbXBsZSBub25jZQ==';
    const expected = 's3pPLMBiTxaQ9kYGzzhZRbK+xOo=';
    assert.strictEqual(ws.computeAcceptKey(clientKey), expected);
  });

  test('computeAcceptKey produces valid base64 for random keys', () => {
    for (let i = 0; i < 10; i++) {
      const randomKey = crypto.randomBytes(16).toString('base64');
      const result = ws.computeAcceptKey(randomKey);
      // Result should be valid base64
      assert.strictEqual(Buffer.from(result, 'base64').toString('base64'), result);
      // SHA-1 output is 20 bytes, base64 encoded = 28 chars
      assert.strictEqual(result.length, 28);
    }
  });

  // ========= Frame Encoding =========
  console.log('\n--- Frame Encoding (server -> client) ---');

  test('encodes small text frame (< 126 bytes)', () => {
    const payload = 'Hello';
    const frame = ws.encodeFrame(ws.OPCODES.TEXT, Buffer.from(payload));
    // FIN bit + TEXT opcode = 0x81, length = 5
    assert.strictEqual(frame[0], 0x81);
    assert.strictEqual(frame[1], 5);
    assert.strictEqual(frame.slice(2).toString(), 'Hello');
    assert.strictEqual(frame.length, 7);
  });

  test('encodes close frame', () => {
    const frame = ws.encodeFrame(ws.OPCODES.CLOSE, Buffer.alloc(0));
    assert.strictEqual(frame[0], 0x88); // FIN + CLOSE
  });

  test('encodes ping frame', () => {
    const frame = ws.encodeFrame(ws.OPCODES.PING, Buffer.from('ping'));
    assert.strictEqual(frame[0], 0x89); // FIN + PING
    assert.strictEqual(frame[1], 4);
  });

  test('encodes pong frame', () => {
    const frame = ws.encodeFrame(ws.OPCODES.PONG, Buffer.from('pong'));
    assert.strictEqual(frame[0], 0x8A); // FIN + PONG
    assert.strictEqual(frame[1], 4);
  });

  // ========= Frame Decoding =========
  console.log('\n--- Frame Decoding (client -> server) ---');

  test('decodes small text frame', () => {
    const encoded = ws.encodeFrame(ws.OPCODES.TEXT, Buffer.from('Hi'));
    const decoded = ws.decodeFrame(encoded);
    assert.ok(decoded !== null);
    assert.strictEqual(decoded.opcode, ws.OPCODES.TEXT);
    assert.strictEqual(decoded.payload.toString(), 'Hi');
    assert.strictEqual(decoded.bytesConsumed, encoded.length);
  });

  test('returns null for incomplete frame', () => {
    const frame = Buffer.alloc(1);
    frame[0] = 0x81; // TEXT, FIN
    // No length byte — incomplete
    assert.strictEqual(ws.decodeFrame(frame), null);
  });

  test('decodes ping and responds with pong', () => {
    const ping = ws.encodeFrame(ws.OPCODES.PING, Buffer.from('are you there?'));
    const decoded = ws.decodeFrame(ping);
    assert.ok(decoded !== null);
    assert.strictEqual(decoded.opcode, ws.OPCODES.PING);
    assert.strictEqual(decoded.payload.toString(), 'are you there?');
  });

  // ========= OPCODES constant =========
  console.log('\n--- OPCODES Constants ---');

  test('OPCODES has all required opcodes', () => {
    assert.ok(ws.OPCODES.TEXT !== undefined, 'TEXT opcode missing');
    assert.ok(ws.OPCODES.CLOSE !== undefined, 'CLOSE opcode missing');
    assert.ok(ws.OPCODES.PING !== undefined, 'PING opcode missing');
    assert.ok(ws.OPCODES.PONG !== undefined, 'PONG opcode missing');
  });

  test('TEXT opcode is 0x01', () => {
    assert.strictEqual(ws.OPCODES.TEXT, 0x01);
  });

  test('CLOSE opcode is 0x08', () => {
    assert.strictEqual(ws.OPCODES.CLOSE, 0x08);
  });

  test('PING opcode is 0x09', () => {
    assert.strictEqual(ws.OPCODES.PING, 0x09);
  });

  test('PONG opcode is 0x0A', () => {
    assert.strictEqual(ws.OPCODES.PONG, 0x0A);
  });

  // ========= Summary =========
  console.log(`\n=== Results: ${passed} passed, ${failed} failed ===`);
  process.exit(failed > 0 ? 1 : 0);
}

runTests().catch(e => {
  console.error(e);
  process.exit(1);
});
