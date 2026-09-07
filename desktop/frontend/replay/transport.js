// Throwaway host boundary. Reuse the existing fixture inventory and RPC
// responses; never assign frontend state, sidebar marks, or DOM contents.
import { DesktopBrowserHarness } from '../../e2e/tests/support/desktop_browser_harness.js';

const host = new DesktopBrowserHarness(null);
host.liveSessions = [];
const threads = [
  { id: 'replay-a', name: 'Task A', preview: 'Task A', cwd: '/workspace', projectRoot: '/workspace', updatedAt: 2, status: { type: 'idle' }, turns: [] },
  { id: 'replay-b', name: 'Task B', preview: 'Task B', cwd: '/workspace', projectRoot: '/workspace', updatedAt: 1, status: { type: 'idle' }, turns: [
    { id: 'turn-b', status: 'completed', items: [{ type: 'agentMessage', id: 'answer-b', text: 'You are reading Task B. Keep this conversation open while A finishes.' }] },
  ] },
];
const originalReply = host.replyFor.bind(host);
host.replyFor = request => {
  switch (request.method) {
    case 'codex.thread.list': return { data: request.params?.archived ? [] : threads };
    case 'codex.thread.history.read': {
      const thread = threads.find(t => t.id === request.params?.threadId);
      if (!thread) throw new Error('Unknown replay thread');
      return { thread };
    }
    default: return originalReply(request);
  }
};

const realFetch = globalThis.fetch.bind(globalThis);
globalThis.fetch = async (input, options) => {
  const url = new URL(typeof input === 'string' ? input : input.url, location.href);
  if (url.pathname === '/v1/auth/me') return Response.json({ login: 'Replay', avatar_url: '' });
  if (url.pathname === '/v1/devices') return Response.json({ devices: [{ id: 'device-a', name: 'Replay host', hostname: 'fixture', online: true }] });
  if (url.pathname.startsWith('/v1/')) throw new Error('Unmodeled replay request: ' + url.pathname);
  return realFetch(input, options);
};
let socket = null;
let generation = 1;
globalThis.WebSocket = class {
  constructor() {
    socket = this;
    this.readyState = 0;
    queueMicrotask(() => {
      this.readyState = 1;
      this.onopen?.({});
      this.receive({ jsonrpc: '2.0', method: 'agent.connected', params: { stage: 'serving' } });
    });
  }
  receive(value) { this.onmessage?.({ data: JSON.stringify(value) }); }
  send(text) {
    const request = JSON.parse(text);
    host.requests.push(request);
    if (request.id === undefined) return;
    queueMicrotask(() => {
      try {
        this.receive({ jsonrpc: '2.0', id: request.id, result: host.replyFor(request) });
      } catch (error) {
        this.receive({ jsonrpc: '2.0', id: request.id, error: { code: -32000, message: error.message } });
      }
    });
  }
  close() { this.readyState = 3; this.onclose?.({}); }
};
globalThis.__desktopReplay = {
  deliver(event) {
    if (!socket || socket.readyState !== 1) return false;
    const thread = threads.find(t => t.id === event.params.threadId);
    if (!thread) return false;
    thread.turns = [event.params.turn];
    thread.status = { type: event.params.turn.status === 'inProgress' ? 'active' : 'idle' };
    socket.receive({ jsonrpc: '2.0', method: 'codex.notification', params: { ...event, generation: ++generation } });
    return true;
  },
};
