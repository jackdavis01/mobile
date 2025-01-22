'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-192.png": "b7975b9c8d545b4cc34c03809725cb22",
"icons/Icon-maskable-512.png": "058a2be8a687eef8764104cc8c45f50d",
"icons/Icon-512.png": "10e60ae03b15933aa965e2b29eedc6fc",
"icons/Icon-192.png": "46c7ff5dbc814bc0e505d61559af4cf7",
"app-ads.txt": "069642af45967e46285cbc18e0e779bf",
"assets/assets/images/chess_queen_bronze.svg": "fa54e8958935f5e9e1553d95ba59ee89",
"assets/assets/images/chess_queen_silver.svg": "d4fb65ee079b2be01b83fd5f73de130d",
"assets/assets/images/snap-store-black.png": "05e997d3f56d1067e7e2576a306bc40d",
"assets/assets/images/get-it-on-windows-badge-black.png": "efe7d00f6f96ff64b4ce77e6fea1afda",
"assets/assets/images/is/iS_logo.png": "57786eb6e17ac7f9d2e8dabe0c1b01e2",
"assets/assets/images/google-play-badge.png": "1e91d02cf5a902f38f2923c006d79281",
"assets/assets/images/app_store_badge.png": "2e6ec85fe18a7f64868c51252f492731",
"assets/assets/images/chess_queen_gold.svg": "2f52e739658a7bb93cc7d708c17e05c4",
"assets/assets/images/chess_queen_blue.svg": "4153ba095e3a5989236e09948b3ebdc0",
"assets/assets/certificates/_.up.railway.app.pem": "81ac8a6ba40ea5c31ae8c4d19b5fd38f",
"assets/AssetManifest.bin": "6d258108bd6a73fe57cb9951e46a9d02",
"assets/NOTICES": "2b36d5aec8ee99de4b9c928e40f28536",
"assets/AssetManifest.json": "192d3aede63d13b4761f0e9e19e59a9a",
"assets/fonts/MaterialIcons-Regular.otf": "3c2a354ad0c8ef3008ec6818d91bfffb",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "f9c59d37d439c74209b86d94b18fd396",
"version.json": "206e046c3a92fe8a6f3129321c6d13ed",
"manifest.json": "6db072cf8750fdf3a36af4debd15e380",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"index.html": "d4f54a05f7797f9085f63e98d2606857",
"/": "d4f54a05f7797f9085f63e98d2606857",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"favicon.png": "54b3ca68eafb038720089b823b0f8f9c",
"flutter_bootstrap.js": "2dfb387519df8fb42eb7b0d7750e08c7",
"main.dart.js": "596236970d25741cd6476371d71da977",
"js/multithreadedfindsolutionscontroller.js": "f8976f5201e72d94cb0c8fc59cbb34d2",
"js/findsolutionsthread.js": "8e9c3ead23ec6acd18b1c623c3899962",
"js/findsolutionscontroller.js": "62d53595f5debe757b5631d511e67654",
"js/multithreadedfindsolutionsthread.js": "3c0c74b587f48eb0f2907b6399ccf5be",
"js/stepandcheck.js": "715cfb11b60002738ff409f82fde5270"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
