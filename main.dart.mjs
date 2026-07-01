// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `load-ids` option is passed. Each load ID maps to one
  //   or more wasm files as specified in the emitted JSON file. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It also takes a callback that should be invoked with the
  //   loaded module in a format supported by `WebAssembly.compile` or
  //   `WebAssembly.compileStreaming` and the result of using the JS 'import'
  //   API on the js file path. It should return a Promise that resolves when
  //   all the modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports,
      {loadDeferredModules, loadDynamicModule, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _1: (decoder, codeUnits) => decoder.decode(codeUnits),
      _2: () => new TextDecoder("utf-8", {fatal: true}),
      _3: () => new TextDecoder("utf-8", {fatal: false}),
      _4: (s) => +s,
      _5: x0 => new Uint8Array(x0),
      _6: (x0,x1,x2) => x0.set(x1,x2),
      _7: (x0,x1) => x0.transferFromImageBitmap(x1),
      _9: (x0,x1,x2) => x0.slice(x1,x2),
      _10: (x0,x1) => x0.decode(x1),
      _11: (x0,x1) => x0.segment(x1),
      _12: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _135: (x0,x1) => x0.appendChild(x1),
      _166: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _167: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _168: (x0,x1) => new OffscreenCanvas(x0,x1),
      _169: x0 => x0.remove(),
      _170: (x0,x1) => x0.append(x1),
      _172: x0 => x0.unlock(),
      _173: x0 => x0.getReader(),
      _174: (x0,x1) => x0.item(x1),
      _175: x0 => x0.next(),
      _176: x0 => x0.now(),
      _177: (x0,x1) => x0.revokeObjectURL(x1),
      _178: x0 => x0.close(),
      _179: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _180: x0 => new window.ImageDecoder(x0),
      _181: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      _182: (x0,x1) => x0.decode(x1),
      _183: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._183(f,arguments.length,x0) }),
      _184: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _186: (x0,x1) => x0.getModifierState(x1),
      _187: x0 => x0.preventDefault(),
      _188: x0 => x0.stopPropagation(),
      _189: (x0,x1) => x0.removeProperty(x1),
      _190: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._190(f,arguments.length,x0) }),
      _191: x0 => new window.FinalizationRegistry(x0),
      _192: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _194: (x0,x1) => x0.unregister(x1),
      _195: (x0,x1) => x0.prepend(x1),
      _196: x0 => new Intl.Locale(x0),
      _197: (x0,x1) => x0.observe(x1),
      _198: x0 => x0.disconnect(),
      _199: (x0,x1) => x0.getAttribute(x1),
      _200: (x0,x1) => x0.contains(x1),
      _201: (x0,x1) => x0.querySelector(x1),
      _202: (x0,x1) => x0.matchMedia(x1),
      _203: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._203(f,arguments.length,x0) }),
      _204: (x0,x1,x2) => x0.call(x1,x2),
      _205: x0 => x0.blur(),
      _206: x0 => x0.hasFocus(),
      _207: (x0,x1) => x0.removeAttribute(x1),
      _208: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _209: (x0,x1) => x0.hasAttribute(x1),
      _210: (x0,x1) => x0.getModifierState(x1),
      _211: (x0,x1) => x0.createTextNode(x1),
      _212: x0 => x0.getBoundingClientRect(),
      _213: (x0,x1) => x0.replaceWith(x1),
      _214: (x0,x1) => x0.contains(x1),
      _215: (x0,x1) => x0.closest(x1),
      _216: () => new Array(),
      _653: x0 => new Uint8Array(x0),
      _656: () => globalThis.window.flutterConfiguration,
      _658: x0 => x0.assetBase,
      _663: x0 => x0.canvasKitMaximumSurfaces,
      _664: x0 => x0.debugShowSemanticsNodes,
      _665: x0 => x0.hostElement,
      _666: x0 => x0.multiViewEnabled,
      _667: x0 => x0.nonce,
      _669: x0 => x0.fontFallbackBaseUrl,
      _679: x0 => x0.console,
      _680: x0 => x0.devicePixelRatio,
      _681: x0 => x0.document,
      _682: x0 => x0.history,
      _683: x0 => x0.innerHeight,
      _684: x0 => x0.innerWidth,
      _685: x0 => x0.location,
      _686: x0 => x0.navigator,
      _687: x0 => x0.visualViewport,
      _688: x0 => x0.performance,
      _689: x0 => x0.parent,
      _691: x0 => x0.URL,
      _693: (x0,x1) => x0.getComputedStyle(x1),
      _694: x0 => x0.screen,
      _695: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._695(f,arguments.length,x0) }),
      _696: (x0,x1) => x0.requestAnimationFrame(x1),
      _700: (x0,x1) => x0.warn(x1),
      _702: (x0,x1) => x0.debug(x1),
      _703: x0 => globalThis.parseFloat(x0),
      _704: () => globalThis.window,
      _705: () => globalThis.Intl,
      _706: () => globalThis.Symbol,
      _707: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _709: x0 => x0.clipboard,
      _710: x0 => x0.maxTouchPoints,
      _711: x0 => x0.vendor,
      _712: x0 => x0.language,
      _713: x0 => x0.platform,
      _714: x0 => x0.userAgent,
      _715: (x0,x1) => x0.vibrate(x1),
      _716: x0 => x0.languages,
      _717: x0 => x0.documentElement,
      _718: (x0,x1) => x0.querySelector(x1),
      _719: (x0,x1) => x0.querySelectorAll(x1),
      _721: (x0,x1) => x0.createElement(x1),
      _724: (x0,x1) => x0.createEvent(x1),
      _725: x0 => x0.activeElement,
      _728: x0 => x0.head,
      _729: x0 => x0.body,
      _731: (x0,x1) => { x0.title = x1 },
      _734: x0 => x0.visibilityState,
      _735: () => globalThis.document,
      _736: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._736(f,arguments.length,x0) }),
      _737: (x0,x1) => x0.dispatchEvent(x1),
      _745: x0 => x0.target,
      _747: x0 => x0.timeStamp,
      _748: x0 => x0.type,
      _750: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _756: x0 => x0.baseURI,
      _757: x0 => x0.firstChild,
      _761: x0 => x0.parentElement,
      _763: (x0,x1) => { x0.textContent = x1 },
      _764: x0 => x0.parentNode,
      _765: x0 => x0.nextSibling,
      _766: (x0,x1) => x0.removeChild(x1),
      _767: x0 => x0.isConnected,
      _775: x0 => x0.clientHeight,
      _776: x0 => x0.clientWidth,
      _777: x0 => x0.offsetHeight,
      _778: x0 => x0.offsetWidth,
      _779: x0 => x0.id,
      _780: (x0,x1) => { x0.id = x1 },
      _783: (x0,x1) => { x0.spellcheck = x1 },
      _784: x0 => x0.tagName,
      _785: x0 => x0.style,
      _787: (x0,x1) => x0.querySelectorAll(x1),
      _788: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _789: x0 => x0.tabIndex,
      _790: (x0,x1) => { x0.tabIndex = x1 },
      _791: (x0,x1) => x0.focus(x1),
      _792: x0 => x0.scrollTop,
      _793: (x0,x1) => { x0.scrollTop = x1 },
      _794: (x0,x1) => { x0.scrollLeft = x1 },
      _795: x0 => x0.scrollLeft,
      _796: x0 => x0.classList,
      _797: (x0,x1) => x0.scrollIntoView(x1),
      _800: (x0,x1) => { x0.className = x1 },
      _802: (x0,x1) => x0.getElementsByClassName(x1),
      _803: x0 => x0.click(),
      _804: (x0,x1) => x0.attachShadow(x1),
      _807: x0 => x0.computedStyleMap(),
      _808: (x0,x1) => x0.get(x1),
      _814: (x0,x1) => x0.getPropertyValue(x1),
      _815: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _816: x0 => x0.offsetLeft,
      _817: x0 => x0.offsetTop,
      _818: x0 => x0.offsetParent,
      _820: (x0,x1) => { x0.name = x1 },
      _821: x0 => x0.content,
      _822: (x0,x1) => { x0.content = x1 },
      _826: (x0,x1) => { x0.src = x1 },
      _827: x0 => x0.naturalWidth,
      _828: x0 => x0.naturalHeight,
      _832: (x0,x1) => { x0.crossOrigin = x1 },
      _834: (x0,x1) => { x0.decoding = x1 },
      _835: x0 => x0.decode(),
      _840: (x0,x1) => { x0.nonce = x1 },
      _845: (x0,x1) => { x0.width = x1 },
      _847: (x0,x1) => { x0.height = x1 },
      _850: (x0,x1) => x0.getContext(x1),
      _918: x0 => x0.width,
      _919: x0 => x0.height,
      _921: (x0,x1) => x0.fetch(x1),
      _922: x0 => x0.status,
      _924: x0 => x0.body,
      _925: x0 => x0.arrayBuffer(),
      _928: x0 => x0.read(),
      _929: x0 => x0.value,
      _930: x0 => x0.done,
      _937: x0 => x0.name,
      _938: x0 => x0.x,
      _939: x0 => x0.y,
      _942: x0 => x0.top,
      _943: x0 => x0.right,
      _944: x0 => x0.bottom,
      _945: x0 => x0.left,
      _955: x0 => x0.height,
      _956: x0 => x0.width,
      _957: x0 => x0.scale,
      _958: (x0,x1) => { x0.value = x1 },
      _961: (x0,x1) => { x0.placeholder = x1 },
      _963: (x0,x1) => { x0.name = x1 },
      _964: x0 => x0.selectionDirection,
      _965: x0 => x0.selectionStart,
      _966: x0 => x0.selectionEnd,
      _969: x0 => x0.value,
      _971: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _972: x0 => x0.readText(),
      _973: (x0,x1) => x0.writeText(x1),
      _975: x0 => x0.altKey,
      _976: x0 => x0.code,
      _977: x0 => x0.ctrlKey,
      _978: x0 => x0.key,
      _979: x0 => x0.keyCode,
      _980: x0 => x0.location,
      _981: x0 => x0.metaKey,
      _982: x0 => x0.repeat,
      _983: x0 => x0.shiftKey,
      _984: x0 => x0.isComposing,
      _986: x0 => x0.state,
      _987: (x0,x1) => x0.go(x1),
      _989: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _990: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _991: x0 => x0.pathname,
      _992: x0 => x0.search,
      _993: x0 => x0.hash,
      _997: x0 => x0.state,
      _1000: (x0,x1) => x0.createObjectURL(x1),
      _1002: x0 => new Blob(x0),
      _1012: x0 => x0.matches,
      _1016: x0 => x0.matches,
      _1020: x0 => x0.relatedTarget,
      _1022: x0 => x0.clientX,
      _1023: x0 => x0.clientY,
      _1024: x0 => x0.offsetX,
      _1025: x0 => x0.offsetY,
      _1028: x0 => x0.button,
      _1029: x0 => x0.buttons,
      _1030: x0 => x0.ctrlKey,
      _1034: x0 => x0.pointerId,
      _1035: x0 => x0.pointerType,
      _1036: x0 => x0.pressure,
      _1037: x0 => x0.tiltX,
      _1038: x0 => x0.tiltY,
      _1039: x0 => x0.getCoalescedEvents(),
      _1042: x0 => x0.deltaX,
      _1043: x0 => x0.deltaY,
      _1044: x0 => x0.wheelDeltaX,
      _1045: x0 => x0.wheelDeltaY,
      _1046: x0 => x0.deltaMode,
      _1053: x0 => x0.changedTouches,
      _1056: x0 => x0.clientX,
      _1057: x0 => x0.clientY,
      _1060: x0 => x0.data,
      _1063: (x0,x1) => { x0.disabled = x1 },
      _1065: (x0,x1) => { x0.type = x1 },
      _1066: (x0,x1) => { x0.max = x1 },
      _1067: (x0,x1) => { x0.min = x1 },
      _1068: x0 => x0.value,
      _1069: (x0,x1) => { x0.value = x1 },
      _1070: x0 => x0.disabled,
      _1071: (x0,x1) => { x0.disabled = x1 },
      _1073: (x0,x1) => { x0.placeholder = x1 },
      _1075: (x0,x1) => { x0.name = x1 },
      _1076: (x0,x1) => { x0.autocomplete = x1 },
      _1078: x0 => x0.selectionDirection,
      _1079: x0 => x0.selectionStart,
      _1081: x0 => x0.selectionEnd,
      _1084: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1085: (x0,x1) => x0.add(x1),
      _1087: (x0,x1) => { x0.noValidate = x1 },
      _1088: (x0,x1) => { x0.method = x1 },
      _1089: (x0,x1) => { x0.action = x1 },
      _1114: x0 => x0.orientation,
      _1115: x0 => x0.width,
      _1116: x0 => x0.height,
      _1117: (x0,x1) => x0.lock(x1),
      _1136: x0 => new ResizeObserver(x0),
      _1139: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1139(f,arguments.length,x0,x1) }),
      _1147: x0 => x0.length,
      _1148: x0 => x0.iterator,
      _1149: x0 => x0.Segmenter,
      _1150: x0 => x0.v8BreakIterator,
      _1151: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1154: x0 => x0.language,
      _1155: x0 => x0.script,
      _1156: x0 => x0.region,
      _1174: x0 => x0.done,
      _1175: x0 => x0.value,
      _1176: x0 => x0.index,
      _1180: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1181: (x0,x1) => x0.adoptText(x1),
      _1182: x0 => x0.first(),
      _1183: x0 => x0.next(),
      _1184: x0 => x0.current(),
      _1186: () => globalThis.window.FinalizationRegistry,
      _1197: x0 => x0.hostElement,
      _1198: x0 => x0.viewConstraints,
      _1201: x0 => x0.maxHeight,
      _1202: x0 => x0.maxWidth,
      _1203: x0 => x0.minHeight,
      _1204: x0 => x0.minWidth,
      _1205: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1205(f,arguments.length,x0) }),
      _1206: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1206(f,arguments.length,x0) }),
      _1207: (x0,x1) => ({addView: x0,removeView: x1}),
      _1210: x0 => x0.loader,
      _1211: () => globalThis._flutter,
      _1212: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1213: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1213(f,arguments.length,x0) }),
      _1214: (module,f) => finalizeWrapper(f, function() { return module.exports._1214(f,arguments.length) }),
      _1215: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1218: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1218(f,arguments.length,x0) }),
      _1219: x0 => ({runApp: x0}),
      _1221: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1221(f,arguments.length,x0,x1) }),
      _1222: x0 => new Promise(x0),
      _1223: x0 => x0.length,
      _1224: () => globalThis.window.ImageDecoder,
      _1225: x0 => x0.tracks,
      _1227: x0 => x0.completed,
      _1229: x0 => x0.image,
      _1235: x0 => x0.displayWidth,
      _1236: x0 => x0.displayHeight,
      _1237: x0 => x0.duration,
      _1240: x0 => x0.ready,
      _1241: x0 => x0.selectedTrack,
      _1242: x0 => x0.repetitionCount,
      _1243: x0 => x0.frameCount,
      _1292: (x0,x1,x2) => x0.open(x1,x2),
      _1293: (x0,x1) => x0.createElement(x1),
      _1294: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1295: x0 => ({video: x0}),
      _1296: (x0,x1) => x0.getUserMedia(x1),
      _1297: x0 => x0.getTracks(),
      _1298: x0 => x0.stop(),
      _1304: (x0,x1) => x0.createElement(x1),
      _1310: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1313: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1314: () => globalThis.Module_soloud._createWorkerInWasm(),
      _1315: x0 => globalThis.Module_soloud._malloc(x0),
      _1316: (x0,x1,x2) => globalThis.Module_soloud.setValue(x0,x1,x2),
      _1318: x0 => globalThis.Module_soloud._free(x0),
      _1320: (x0,x1,x2,x3) => globalThis.Module_soloud._initEngine(x0,x1,x2,x3),
      _1323: (x0,x1) => globalThis.Module_soloud.getValue(x0,x1),
      _1326: () => globalThis.Module_soloud._dispose(),
      _1327: () => globalThis.Module_soloud._isInited(),
      _1328: (x0,x1,x2,x3,x4) => globalThis.Module_soloud._loadMem(x0,x1,x2,x3,x4),
      _1329: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => globalThis.Module_soloud._setBufferStream(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      _1332: x0 => globalThis.Module_soloud._resetBufferStream(x0),
      _1336: (x0,x1,x2) => globalThis.Module_soloud._addAudioDataStream(x0,x1,x2),
      _1347: (x0,x1) => globalThis.Module_soloud._setPause(x0,x1),
      _1351: (x0,x1,x2,x3,x4,x5,x6) => globalThis.Module_soloud._play(x0,x1,x2,x3,x4,x5,x6),
      _1352: x0 => globalThis.Module_soloud._stop(x0),
      _1353: x0 => globalThis.Module_soloud._disposeSound(x0),
      _1354: () => globalThis.Module_soloud._disposeAllSound(),
      _1360: () => globalThis.Module_soloud._getVisualizationEnabled(),
      _1366: x0 => globalThis.Module_soloud._getLength(x0),
      _1367: (x0,x1) => globalThis.Module_soloud._seek(x0,x1),
      _1372: (x0,x1) => globalThis.Module_soloud._setVolume(x0,x1),
      _1376: x0 => globalThis.Module_soloud._getIsValidVoiceHandle(x0),
      _1395: (x0,x1) => globalThis.Module_soloud._scheduleStop(x0,x1),
      _1423: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1424: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1435: (x0,x1,x2) => x0.setItem(x1,x2),
      _1436: (x0,x1) => x0.getItem(x1),
      _1437: x0 => x0.decode(),
      _1438: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1439: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1440: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1440(f,arguments.length,x0) }),
      _1441: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1441(f,arguments.length,x0) }),
      _1442: x0 => x0.send(),
      _1443: () => new XMLHttpRequest(),
      _1444: x0 => globalThis.FilesetResolver.forVisionTasks(x0),
      _1445: (x0,x1) => globalThis.HandLandmarker.createFromOptions(x0,x1),
      _1446: (x0,x1,x2) => x0.detectForVideo(x1,x2),
      _1447: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1447(f,arguments.length,x0) }),
      _1448: (x0,x1) => x0.requestAnimationFrame(x1),
      _1449: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1449(f,arguments.length,x0) }),
      _1450: (x0,x1) => x0.cancelAnimationFrame(x1),
      _1451: (x0,x1) => ({sysex: x0,software: x1}),
      _1452: (x0,x1) => x0.requestMIDIAccess(x1),
      _1453: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1453(f,arguments.length,x0) }),
      _1454: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1454(f,arguments.length,x0) }),
      _1455: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1455(f,arguments.length,x0,x1) }),
      _1456: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1456(f,arguments.length,x0,x1) }),
      _1457: (x0,x1) => x0.send(x1),
      _1458: () => globalThis.navigator,
      _1459: x0 => x0.inputs,
      _1460: x0 => x0.outputs,
      _1461: (x0,x1) => { x0.onstatechange = x1 },
      _1462: x0 => x0.forEach,
      _1463: x0 => x0.forEach,
      _1464: x0 => x0.name,
      _1465: x0 => x0.id,
      _1467: (x0,x1) => { x0.onmidimessage = x1 },
      _1468: x0 => x0.name,
      _1469: x0 => x0.id,
      _1471: x0 => x0.data,
      _1472: x0 => ({mode: x0}),
      _1473: x0 => ({create: x0}),
      _1474: (x0,x1,x2) => x0.getFileHandle(x1,x2),
      _1475: x0 => x0.getFile(),
      _1476: x0 => x0.createWritable(),
      _1477: x0 => x0.name,
      _1478: (x0,x1) => x0.write(x1),
      _1479: x0 => x0.close(),
      _1480: x0 => globalThis.showDirectoryPicker(x0),
      _1481: () => globalThis.showDirectoryPicker,
      _1482: x0 => x0.arrayBuffer(),
      _1483: x0 => ({vendorId: x0}),
      _1484: x0 => ({filters: x0}),
      _1485: (x0,x1) => x0.requestDevice(x1),
      _1486: x0 => x0.open(),
      _1487: (x0,x1) => x0.selectConfiguration(x1),
      _1488: (x0,x1) => x0.claimInterface(x1),
      _1489: (x0,x1,x2) => x0.selectAlternateInterface(x1,x2),
      _1490: (x0,x1,x2,x3,x4) => ({requestType: x0,recipient: x1,request: x2,value: x3,index: x4}),
      _1491: (x0,x1) => x0.controlTransferOut(x1),
      _1492: (x0,x1,x2) => x0.transferIn(x1,x2),
      _1493: (x0,x1,x2) => x0.transferOut(x1,x2),
      _1494: () => globalThis.navigator.usb,
      _1495: x0 => x0.configuration,
      _1497: x0 => x0.interfaces,
      _1498: x0 => x0.interfaceNumber,
      _1499: x0 => x0.alternates,
      _1500: x0 => x0.interfaceClass,
      _1502: x0 => x0.endpoints,
      _1503: x0 => x0.direction,
      _1504: x0 => x0.endpointNumber,
      _1505: x0 => x0.data,
      _1506: (x0,x1) => x0.removeItem(x1),
      _1507: (x0,x1) => x0.querySelector(x1),
      _1508: x0 => ({type: x0}),
      _1509: (x0,x1) => new Blob(x0,x1),
      _1510: x0 => globalThis.URL.createObjectURL(x0),
      _1511: (x0,x1) => x0.item(x1),
      _1512: () => new FileReader(),
      _1514: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1515: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1515(f,arguments.length,x0) }),
      _1516: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1517: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1517(f,arguments.length,x0) }),
      _1518: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1518(f,arguments.length,x0) }),
      _1519: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1519(f,arguments.length,x0) }),
      _1520: (x0,x1) => x0.removeChild(x1),
      _1521: x0 => x0.click(),
      _1528: Date.now,
      _1530: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1531: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1532: () => typeof dartUseDateNowForTicks !== "undefined",
      _1533: () => 1000 * performance.now(),
      _1534: () => Date.now(),
      _1535: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1536: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1537: () => new WeakMap(),
      _1538: (map, o) => map.get(o),
      _1539: (map, o, v) => map.set(o, v),
      _1540: x0 => new WeakRef(x0),
      _1541: x0 => x0.deref(),
      _1548: () => globalThis.WeakRef,
      _1551: s => JSON.stringify(s),
      _1552: s => printToConsole(s),
      _1553: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      _1554: (o, p, r) => o.replaceAll(p, () => r),
      _1555: (o, p, r) => o.replace(p, () => r),
      _1556: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1557: s => s.toUpperCase(),
      _1558: s => s.trim(),
      _1559: s => s.trimLeft(),
      _1560: s => s.trimRight(),
      _1561: (string, times) => string.repeat(times),
      _1562: Function.prototype.call.bind(String.prototype.indexOf),
      _1563: (s, p, i) => s.lastIndexOf(p, i),
      _1564: (string, token) => string.split(token),
      _1565: Object.is,
      _1569: (o, t) => typeof o === t,
      _1570: (o, c) => o instanceof c,
      _1571: o => Object.keys(o),
      _1575: (o, a) => o + a,
      _1625: x0 => new Array(x0),
      _1627: x0 => x0.length,
      _1629: (x0,x1) => x0[x1],
      _1630: (x0,x1,x2) => { x0[x1] = x2 },
      _1633: (x0,x1,x2) => new DataView(x0,x1,x2),
      _1635: x0 => new Int8Array(x0),
      _1636: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _1638: x0 => new Uint8ClampedArray(x0),
      _1640: x0 => new Int16Array(x0),
      _1642: x0 => new Uint16Array(x0),
      _1644: x0 => new Int32Array(x0),
      _1646: x0 => new Uint32Array(x0),
      _1648: x0 => new Float32Array(x0),
      _1650: x0 => new Float64Array(x0),
      _1674: x0 => x0.random(),
      _1675: (x0,x1) => x0.getRandomValues(x1),
      _1676: () => globalThis.crypto,
      _1677: () => globalThis.Math,
      _1690: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1691: (handle) => clearTimeout(handle),
      _1692: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1693: (handle) => clearInterval(handle),
      _1694: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1695: () => Date.now(),
      _1696: () => new Error().stack,
      _1697: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1698: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1699: (x0,x1) => x0.exec(x1),
      _1700: (x0,x1) => x0.test(x1),
      _1701: x0 => x0.pop(),
      _1703: o => o === undefined,
      _1705: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1707: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1708: o => o instanceof RegExp,
      _1709: (l, r) => l === r,
      _1710: o => o,
      _1711: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      _1712: o => o,
      _1713: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      _1714: o => o,
      _1715: b => !!b,
      _1716: o => o.length,
      _1718: (o, i) => o[i],
      _1719: f => f.dartFunction,
      _1720: () => ({}),
      _1721: () => [],
      _1723: () => globalThis,
      _1724: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1725: (o, p) => p in o,
      _1726: (o, p) => o[p],
      _1727: (o, p, v) => o[p] = v,
      _1728: (o, m, a) => o[m].apply(o, a),
      _1730: o => String(o),
      _1731: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _1732: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1732(f,arguments.length,x0) }),
      _1733: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1733(f,arguments.length,x0,x1) }),
      _1734: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      _1735: o => [o],
      _1736: (o0, o1) => [o0, o1],
      _1737: (o0, o1, o2) => [o0, o1, o2],
      _1738: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1739: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      _1740: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1741: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1742: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1743: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1744: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1745: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1746: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1747: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1748: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1749: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1750: x0 => new ArrayBuffer(x0),
      _1751: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1752: x0 => x0.input,
      _1753: x0 => x0.index,
      _1754: x0 => x0.groups,
      _1755: x0 => x0.flags,
      _1756: x0 => x0.multiline,
      _1757: x0 => x0.ignoreCase,
      _1758: x0 => x0.unicode,
      _1759: x0 => x0.dotAll,
      _1760: (x0,x1) => { x0.lastIndex = x1 },
      _1761: (o, p) => p in o,
      _1762: (o, p) => o[p],
      _1763: (o, p, v) => o[p] = v,
      _1772: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1772(f,arguments.length,x0) }),
      _1773: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1773(f,arguments.length,x0) }),
      _1778: (x0,x1) => new WebSocket(x0,x1),
      _1779: (x0,x1) => x0.send(x1),
      _1780: (x0,x1,x2) => x0.close(x1,x2),
      _1781: (x0,x1) => x0.close(x1),
      _1782: x0 => x0.close(),
      _1788: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1788(f,arguments.length,x0) }),
      _1791: x0 => new BroadcastChannel(x0),
      _1792: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1792(f,arguments.length,x0) }),
      _1793: (x0,x1) => x0.postMessage(x1),
      _1794: x0 => x0.close(),
      _1795: () => new AbortController(),
      _1796: x0 => x0.abort(),
      _1797: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _1798: (x0,x1) => globalThis.fetch(x0,x1),
      _1799: (x0,x1) => x0.get(x1),
      _1800: (module,f) => finalizeWrapper(f, function(x0,x1,x2) { return module.exports._1800(f,arguments.length,x0,x1,x2) }),
      _1801: (x0,x1) => x0.forEach(x1),
      _1802: x0 => x0.getReader(),
      _1803: x0 => x0.cancel(),
      _1804: x0 => x0.read(),
      _1810: () => globalThis.Module_soloud.wasmWorker,
      _1814: (x0,x1) => x0.key(x1),
      _1815: o => o instanceof Array,
      _1819: a => a.pop(),
      _1820: (a, i) => a.splice(i, 1),
      _1821: (a, s) => a.join(s),
      _1822: (a, s, e) => a.slice(s, e),
      _1824: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1825: a => a.length,
      _1827: (a, i) => a[i],
      _1828: (a, i, v) => a[i] = v,
      _1830: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      _1831: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1832: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof DataView) return 1;
        return 2;
      },
      _1833: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      _1834: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1835: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      _1836: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1837: o => o instanceof Uint8ClampedArray,
      _1838: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1839: o => o instanceof Uint16Array,
      _1840: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1841: o => o instanceof Int16Array,
      _1842: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1843: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      _1844: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1845: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      _1846: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1848: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1849: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      _1850: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1851: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      _1852: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1853: (a, i) => a.push(i),
      _1854: (t, s) => t.set(s),
      _1855: l => new DataView(new ArrayBuffer(l)),
      _1856: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1857: o => o.byteLength,
      _1858: o => o.buffer,
      _1859: o => o.byteOffset,
      _1860: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1861: (b, o) => new DataView(b, o),
      _1862: (b, o, l) => new DataView(b, o, l),
      _1863: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1864: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1865: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1866: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1867: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1868: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1869: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1870: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1871: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1872: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1873: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1874: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1877: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1878: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1879: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1880: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1881: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1882: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1883: Function.prototype.call.bind(Number.prototype.toString),
      _1884: Function.prototype.call.bind(BigInt.prototype.toString),
      _1885: Function.prototype.call.bind(Number.prototype.toString),
      _1886: (d, digits) => d.toFixed(digits),
      _1909: () => globalThis.document,
      _1911: () => globalThis.console,
      _1916: (x0,x1) => { x0.height = x1 },
      _1918: (x0,x1) => { x0.width = x1 },
      _1920: (x0,x1) => { x0.pointerEvents = x1 },
      _1929: x0 => x0.style,
      _1932: x0 => x0.src,
      _1933: (x0,x1) => { x0.src = x1 },
      _1934: x0 => x0.naturalWidth,
      _1935: x0 => x0.naturalHeight,
      _1950: (x0,x1) => x0.error(x1),
      _1955: x0 => x0.status,
      _1956: (x0,x1) => { x0.responseType = x1 },
      _1958: x0 => x0.response,
      _2072: (x0,x1) => { x0.draggable = x1 },
      _2088: x0 => x0.style,
      _2565: (x0,x1) => { x0.src = x1 },
      _2572: (x0,x1) => { x0.allow = x1 },
      _2574: (x0,x1) => { x0.allowFullscreen = x1 },
      _2660: x0 => x0.videoWidth,
      _2661: x0 => x0.videoHeight,
      _2698: (x0,x1) => { x0.srcObject = x1 },
      _2706: x0 => x0.readyState,
      _2722: (x0,x1) => { x0.autoplay = x1 },
      _3017: (x0,x1) => { x0.accept = x1 },
      _3031: x0 => x0.files,
      _3057: (x0,x1) => { x0.multiple = x1 },
      _3075: (x0,x1) => { x0.type = x1 },
      _3794: () => globalThis.window,
      _3835: x0 => x0.location,
      _3854: x0 => x0.navigator,
      _4118: x0 => x0.localStorage,
      _4126: x0 => x0.href,
      _4227: x0 => x0.mediaDevices,
      _4243: x0 => x0.userAgent,
      _4294: x0 => x0.data,
      _4341: (x0,x1) => { x0.onmessage = x1 },
      _4399: (x0,x1) => { x0.onmessage = x1 },
      _4447: x0 => x0.length,
      _4664: x0 => x0.readyState,
      _4677: (x0,x1) => { x0.binaryType = x1 },
      _4680: x0 => x0.code,
      _4681: x0 => x0.reason,
      _6389: x0 => x0.signal,
      _6450: x0 => x0.firstChild,
      _6461: () => globalThis.document,
      _6877: (x0,x1) => { x0.id = x1 },
      _6904: x0 => x0.children,
      _8223: x0 => x0.value,
      _8225: x0 => x0.done,
      _8404: x0 => x0.size,
      _8405: x0 => x0.type,
      _8412: x0 => x0.name,
      _8418: x0 => x0.length,
      _8423: x0 => x0.result,
      _8920: x0 => x0.url,
      _8922: x0 => x0.status,
      _8924: x0 => x0.statusText,
      _8925: x0 => x0.headers,
      _8926: x0 => x0.body,
      _11051: (x0,x1) => { x0.border = x1 },
      _11329: (x0,x1) => { x0.display = x1 },
      _11493: (x0,x1) => { x0.height = x1 },
      _11687: (x0,x1) => { x0.objectFit = x1 },
      _12115: (x0,x1) => { x0.transform = x1 },
      _12183: (x0,x1) => { x0.width = x1 },
      _12551: x0 => x0.name,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });
    dartInstance.exports.$setThisModule(dartInstance);

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
