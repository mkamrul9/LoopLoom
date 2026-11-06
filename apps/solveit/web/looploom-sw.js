// The app shell is cached for offline practice. Dynamic same-origin assets are
// cached after their first successful request. Cloud coaching still needs a network.
const CACHE_NAME = 'looploom-app-v1';
const SHELL = [
  '/index.html',
  '/flutter_bootstrap.js',
  '/main.dart.js',
  '/flutter.js',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/assets/AssetManifest.bin',
  '/assets/FontManifest.json',
  '/assets/fonts/MaterialIcons-Regular.otf',
  '/canvaskit/canvaskit.js',
  '/canvaskit/canvaskit.wasm',
  '/canvaskit/chromium/canvaskit.js',
  '/canvaskit/chromium/canvaskit.wasm'
];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names.filter((name) => name.startsWith('looploom-app-') && name !== CACHE_NAME)
      .map((name) => caches.delete(name)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin) return;

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    const fallbackKey = request.mode === 'navigate' ? '/index.html' : request;
    try {
      const response = await fetch(request);
      if (response.ok && response.type === 'basic') {
        await cache.put(fallbackKey, response.clone());
      }
      return response;
    } catch (_) {
      const cached = await cache.match(fallbackKey);
      if (cached) return cached;
      return Response.error();
    }
  })());
});
