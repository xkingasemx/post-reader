{{flutter_js}}
{{flutter_build_config}}

async function startReader() {
  // The release web build can reopen offline after its first visit.
  // Keep the development server and hot reload outside the offline cache.
  const releaseBuild = _flutter.buildConfig.builds.some(
    (build) => build.compileTarget === 'dart2js'
  );
  if (releaseBuild && 'serviceWorker' in navigator) {
    try {
      const ready = new Promise((resolve) => {
        if (navigator.serviceWorker.controller) return resolve();
        navigator.serviceWorker.addEventListener('controllerchange', resolve, { once: true });
      });
      await navigator.serviceWorker.register('offline_worker.js');
      // Browsers that restrict workers should still be able to read online.
      await Promise.race([ready, new Promise((resolve) => setTimeout(resolve, 4000))]);
    } catch (error) {
      console.warn('Offline app files are unavailable in this browser.', error);
    }
  }
  await _flutter.loader.load();
}

startReader();
