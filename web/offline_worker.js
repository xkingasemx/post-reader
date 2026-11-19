// Hive owns post data. This worker only saves the same-origin Flutter app files.
const scope = self.registration.scope;
const cacheName = 'offline-posts-shell-v1:' + scope;
const indexUrl = new URL('index.html', scope).href;

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(cacheName);
    await cache.addAll(['./', 'index.html', 'flutter_bootstrap.js', 'main.dart.js']);
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET' || !request.url.startsWith(scope)) return;
  event.respondWith((async () => {
    const cache = await caches.open(cacheName);
    try {
      const response = await fetch(request);
      if (response.ok) {
        // A storage quota error must not prevent an online request from working.
        await cache.put(request, response.clone()).catch(() => {});
      }
      return response;
    } catch (error) {
      const saved = await cache.match(request);
      if (saved) return saved;
      if (request.mode === 'navigate') {
        const entry = await cache.match(indexUrl);
        if (entry) return entry;
      }
      throw error;
    }
  })());
});
