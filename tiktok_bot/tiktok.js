#!/usr/bin/env node
'use strict';

const http = require('http');
const crypto = require('crypto');

const PORT = Number(process.env.TIKTOK_BRIDGE_PORT || 3001);
const HOST = process.env.TIKTOK_BRIDGE_HOST || '127.0.0.1';
const TTL_MS = Number(process.env.TIKTOK_EVENT_TTL_MS || 60000);
const ROOM_ID = process.env.TIKTOK_ROOM_ID || '';
const UNIQUE_ID = process.env.TIKTOK_UNIQUE_ID || '';
const ENABLE_MOCK = process.env.TIKTOK_MOCK === '1';

/** @type {Array<{id:string,type:string,nickname:string,message:string,giftName:string,repeatCount:number,ts:number}>} */
const queue = [];

function json(res, statusCode, payload) {
  const raw = JSON.stringify(payload);
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(raw)
  });
  res.end(raw);
}

function pushEvent(event) {
  queue.push({
    id: event.id || crypto.randomUUID(),
    type: event.type || 'unknown',
    nickname: event.nickname || 'desconhecido',
    message: event.message || '',
    giftName: event.giftName || '',
    repeatCount: Number(event.repeatCount || 0),
    ts: Date.now()
  });

  const now = Date.now();
  while (queue.length && (now - queue[0].ts) > TTL_MS) queue.shift();
}

function consumeBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 1024 * 1024) {
        reject(new Error('Payload too large'));
      }
    });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

function setupMockData() {
  setInterval(() => {
    pushEvent({
      type: 'chat',
      nickname: 'MockUser',
      message: `Mensagem teste em ${new Date().toLocaleTimeString('pt-BR')}`
    });

    pushEvent({
      type: 'gift',
      nickname: 'MockUser',
      giftName: 'Rose',
      repeatCount: 1
    });
  }, 8000);

  console.log('[TikTok Bridge] Modo mock ativo (TIKTOK_MOCK=1).');
}

async function setupTikTokLiveConnector() {
  let TikTokLiveConnection;
  try {
    ({ TikTokLiveConnection } = require('tiktok-live-connector'));
  } catch (_err) {
    console.warn('[TikTok Bridge] pacote "tiktok-live-connector" não encontrado.');
    console.warn('[TikTok Bridge] Instale com: npm i tiktok-live-connector');
    return;
  }

  if (!ROOM_ID && !UNIQUE_ID) {
    console.warn('[TikTok Bridge] defina TIKTOK_ROOM_ID ou TIKTOK_UNIQUE_ID para conectar na live.');
    return;
  }

  const target = UNIQUE_ID || ROOM_ID;
  const tiktok = new TikTokLiveConnection(target);

  tiktok.on('chat', (data) => {
    pushEvent({ type: 'chat', nickname: data.nickname, message: data.comment });
  });

  tiktok.on('gift', (data) => {
    pushEvent({
      type: 'gift',
      nickname: data.nickname,
      giftName: data.giftName,
      repeatCount: data.repeatCount
    });
  });

  tiktok.on('error', (error) => {
    console.error('[TikTok Bridge] erro no conector:', error?.message || error);
  });

  try {
    const state = await tiktok.connect();
    console.log('[TikTok Bridge] conectado na live:', target, state?.roomId || 'sem roomId');
  } catch (err) {
    console.error('[TikTok Bridge] falha ao conectar na live:', err?.message || err);
  }
}

const server = http.createServer(async (req, res) => {
  try {
    const { method, url } = req;

    if (method === 'GET' && url === '/health') {
      return json(res, 200, { ok: true, queueSize: queue.length, ts: new Date().toISOString() });
    }

    if (method === 'GET' && url === '/events') {
      const events = queue.splice(0, queue.length);
      return json(res, 200, { events, count: events.length, ts: new Date().toISOString() });
    }

    if (method === 'POST' && url === '/event') {
      const raw = await consumeBody(req);
      const data = raw ? JSON.parse(raw) : {};
      pushEvent(data);
      return json(res, 201, { ok: true, queued: queue.length });
    }

    return json(res, 404, { ok: false, error: 'Not Found' });
  } catch (err) {
    return json(res, 500, { ok: false, error: err?.message || 'Internal error' });
  }
});

server.listen(PORT, HOST, async () => {
  console.log(`[TikTok Bridge] HTTP ativo em http://${HOST}:${PORT}`);
  if (ENABLE_MOCK) setupMockData();
  await setupTikTokLiveConnector();
});
