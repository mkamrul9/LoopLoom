{{flutter_js}}
{{flutter_build_config}}

const loopLoomBuildVersion = {{flutter_service_worker_version}};
for (const build of _flutter.buildConfig.builds) {
  if (typeof build.mainJsPath === 'string') {
    const separator = build.mainJsPath.includes('?') ? '&' : '?';
    build.mainJsPath = `${build.mainJsPath}${separator}v=${loopLoomBuildVersion}`;
  }
}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: loopLoomBuildVersion,
  },
});
