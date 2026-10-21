// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
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
            AB: x0 => new Int16Array(x0),
      AC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      AD: x0 => x0.clientX,
      AE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      AF: x0 => x0.touches,
      AG: (x0,x1) => x0.querySelectorAll(x1),
      AH: x0 => x0.clipboard,
      AI: x0 => x0.offsetWidth,
      AJ: (x0,x1) => globalThis.Module_soloud._scheduleStop(x0,x1),
      AK: (x0,x1) => { x0.download = x1 },
      AL: (x0,x1) => { x0.responseType = x1 },
      AM: (x0,x1) => { x0.display = x1 },
      AN: () => globalThis.Module_soloud._getVisualizationEnabled(),
      B: s => printToConsole(s),
      BB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      BC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      BD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      BE: x0 => x0.matches,
      BF: x0 => x0.pressure,
      BG: (x0,x1) => x0.requestAnimationFrame(x1),
      BH: (x0,x1) => x0.writeText(x1),
      BI: x0 => x0.stopPropagation(),
      BJ: () => globalThis.Module_soloud._isInited(),
      BK: (x0,x1) => { x0.target = x1 },
      BL: () => new XMLHttpRequest(),
      BM: (x0,x1) => { x0.accept = x1 },
      BN: (x0,x1,x2,x3) => globalThis.Module_soloud._initEngine(x0,x1,x2,x3),
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: x0 => new Uint16Array(x0),
      CC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      CD: x0 => x0.getBoundingClientRect(),
      CE: (x0,x1) => x0.matchMedia(x1),
      CF: x0 => x0.tiltY,
      CG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CH: x0 => x0.unlock(),
      CI: x0 => x0.disabled,
      CJ: (x0,x1) => globalThis.Module_soloud._setPause(x0,x1),
      CK: (x0,x1) => { x0.href = x1 },
      CL: (x0,x1,x2) => x0.setAttribute(x1,x2),
      CM: (x0,x1) => { x0.multiple = x1 },
      CN: () => globalThis.Module_soloud._disposeAllSound(),
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: x0 => new Int32Array(x0),
      DC: (x0,x1) => x0.querySelector(x1),
      DD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      DE: x0 => x0.matches,
      DF: x0 => x0.tiltX,
      DG: x0 => x0.now(),
      DH: (x0,x1) => x0.lock(x1),
      DI: (x0,x1) => { x0.min = x1 },
      DJ: (x0,x1) => globalThis.Module_soloud._seek(x0,x1),
      DK: (x0,x1) => x0.createElement(x1),
      DL: (x0,x1) => { x0.allowFullscreen = x1 },
      DM: (x0,x1) => { x0.draggable = x1 },
      DN: () => globalThis.Module_soloud._dispose(),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      EC: (x0,x1) => x0.item(x1),
      ED: s => new Date(s * 1000).getTimezoneOffset() * 60,
      EE: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      EF: x0 => x0.pointerType,
      EG: x0 => x0.performance,
      EH: x0 => x0.orientation,
      EI: (x0,x1) => { x0.max = x1 },
      EJ: x0 => globalThis.Module_soloud._malloc(x0),
      EK: () => globalThis.document,
      EL: (x0,x1) => { x0.allow = x1 },
      EM: (x0,x1) => { x0.type = x1 },
      EN: () => globalThis.Module_soloud._createWorkerInWasm(),
      F: () => new Error().stack,
      FB: x0 => new Uint32Array(x0),
      FC: x0 => x0.length,
      FD: Date.now,
      FE: f => f.dartFunction,
      FF: x0 => x0.pointerId,
      FG: (d, digits) => d.toFixed(digits),
      FH: (x0,x1) => x0.querySelector(x1),
      FI: (x0,x1) => { x0.disabled = x1 },
      FJ: (x0,x1,x2,x3,x4,x5,x6) => globalThis.Module_soloud._play(x0,x1,x2,x3,x4,x5,x6),
      FK: x0 => x0.naturalHeight,
      FL: (x0,x1) => { x0.height = x1 },
      FM: (x0,x1,x2) => globalThis.Module_soloud._addAudioDataStream(x0,x1,x2),
      FN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      G: s => JSON.stringify(s),
      GB: x0 => new Float32Array(x0),
      GC: (x0,x1) => x0.querySelectorAll(x1),
      GD: (handle) => clearTimeout(handle),
      GE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      GF: x0 => x0.getCoalescedEvents(),
      GG: x0 => x0.maxHeight,
      GH: (x0,x1) => { x0.title = x1 },
      GI: (x0,x1) => { x0.scrollLeft = x1 },
      GJ: (x0,x1) => globalThis.Module_soloud.getValue(x0,x1),
      GK: x0 => x0.naturalWidth,
      GL: (x0,x1) => { x0.width = x1 },
      GM: x0 => globalThis.Module_soloud._resetBufferStream(x0),
      GN: (x0,x1) => { x0.onmessage = x1 },
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      HC: (x0,x1) => x0.getAttribute(x1),
      HD: (x0,x1) => x0.closest(x1),
      HE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      HF: (x0,x1) => x0.getModifierState(x1),
      HG: x0 => x0.maxWidth,
      HH: (x0,x1) => x0.vibrate(x1),
      HI: (x0,x1) => { x0.spellcheck = x1 },
      HJ: x0 => globalThis.Module_soloud._free(x0),
      HK: (x0,x1) => x0.createElement(x1),
      HL: (x0,x1) => { x0.border = x1 },
      HM: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => globalThis.Module_soloud._setBufferStream(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      HN: () => globalThis.Module_soloud.wasmWorker,
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Float64Array(x0),
      IC: x0 => x0.remove(),
      ID: x0 => x0.bottom,
      IE: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      IF: s => s.trimLeft(),
      IG: x0 => x0.minHeight,
      IH: x0 => x0.arrayBuffer(),
      II: (x0,x1) => { x0.disabled = x1 },
      IJ: x0 => globalThis.Module_soloud._getLength(x0),
      IK: (x0,x1) => { x0.pointerEvents = x1 },
      IL: x0 => x0.style,
      IM: x0 => x0.getTracks(),
      IN: x0 => x0.input,
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      JC: (x0,x1) => x0.appendChild(x1),
      JD: x0 => x0.top,
      JE: (o, i) => o[i],
      JF: s => s.toUpperCase(),
      JG: x0 => x0.minWidth,
      JH: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      JI: (a, i) => a.splice(i, 1),
      JJ: (x0,x1,x2) => globalThis.Module_soloud.setValue(x0,x1,x2),
      JK: (x0,x1) => { x0.height = x1 },
      JL: (x0,x1) => { x0.src = x1 },
      JM: x0 => x0.stop(),
      JN: x0 => globalThis.Module_soloud._disposeSound(x0),
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: x0 => new ArrayBuffer(x0),
      KC: (x0,x1) => x0.append(x1),
      KD: x0 => x0.right,
      KE: o => o.length,
      KF: (x0,x1) => x0[x1],
      KG: (x0,x1) => x0.removeProperty(x1),
      KH: x0 => x0.status,
      KI: a => a.pop(),
      KJ: (x0,x1,x2,x3,x4) => globalThis.Module_soloud._loadMem(x0,x1,x2,x3,x4),
      KK: (x0,x1) => { x0.width = x1 },
      KL: x0 => x0.name,
      KM: (x0,x1) => x0.cancelAnimationFrame(x1),
      KN: (x0,x1) => x0.transferFromImageBitmap(x1),
      L: o => o === undefined,
      LB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      LC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      LD: x0 => x0.left,
      LE: o => {
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
      LF: x0 => x0.length,
      LG: (x0,x1) => x0.add(x1),
      LH: (x0,x1) => x0.fetch(x1),
      LI: (map, o, v) => map.set(o, v),
      LJ: x0 => globalThis.Module_soloud._stop(x0),
      LK: x0 => x0.style,
      LL: (x0,x1) => ({sysex: x0,software: x1}),
      LM: x0 => ({video: x0}),
      LN: (x0,x1) => x0.getContext(x1),
      M: o => String(o),
      MB: (x0,x1,x2) => new DataView(x0,x1,x2),
      MC: x0 => x0.style,
      MD: x0 => x0.clientY,
      ME: x0 => x0.language,
      MF: (x0,x1) => x0.exec(x1),
      MG: x0 => x0.data,
      MH: x0 => x0.content,
      MI: (map, o) => map.get(o),
      MJ: x0 => globalThis.Module_soloud._getIsValidVoiceHandle(x0),
      MK: (x0,x1) => { x0.src = x1 },
      ML: (x0,x1) => x0.requestMIDIAccess(x1),
      MM: (x0,x1) => x0.getUserMedia(x1),
      MN: (x0,x1) => { x0.height = x1 },
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: (o, p) => o[p],
      NC: x0 => x0.debugShowSemanticsNodes,
      ND: x0 => x0.clientX,
      NE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      NF: x0 => x0.index,
      NG: (x0,x1) => { x0.scrollTop = x1 },
      NH: x0 => x0.document,
      NI: () => new WeakMap(),
      NJ: (x0,x1) => globalThis.Module_soloud._setVolume(x0,x1),
      NK: () => globalThis.document,
      NL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      NM: x0 => globalThis.FilesetResolver.forVisionTasks(x0),
      NN: (x0,x1) => { x0.width = x1 },
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      OC: o => o,
      OD: x0 => x0.changedTouches,
      OE: () => globalThis.window.FinalizationRegistry,
      OF: x0 => x0.flags,
      OG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      OH: () => typeof dartUseDateNowForTicks !== "undefined",
      OI: x0 => new WeakRef(x0),
      OJ: x0 => ({mode: x0}),
      OK: x0 => x0.src,
      OL: (x0,x1) => { x0.onstatechange = x1 },
      OM: (x0,x1) => globalThis.HandLandmarker.createFromOptions(x0,x1),
      ON: x0 => x0.height,
      P: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      PC: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      PD: x0 => x0.offsetY,
      PE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PF: (a, s) => a.join(s),
      PG: (x0,x1) => { x0.value = x1 },
      PH: () => Date.now(),
      PI: x0 => x0.deref(),
      PJ: x0 => globalThis.showDirectoryPicker(x0),
      PK: (x0,x1) => x0.revokeObjectURL(x1),
      PL: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      PM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PN: x0 => x0.width,
      Q: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      QB: o => o.byteOffset,
      QC: (x0,x1) => x0.warn(x1),
      QD: x0 => x0.offsetX,
      QE: x0 => new window.FinalizationRegistry(x0),
      QF: (x0,x1) => x0.error(x1),
      QG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      QH: () => 1000 * performance.now(),
      QI: () => globalThis.WeakRef,
      QJ: x0 => ({filters: x0}),
      QK: (x0,x1) => { x0.src = x1 },
      QL: x0 => x0.id,
      QM: (x0,x1) => x0.requestAnimationFrame(x1),
      QN: x0 => x0.rasterEndMilliseconds,
      R: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      RB: o => o.buffer,
      RC: x0 => x0.console,
      RD: x0 => x0.type,
      RE: (x0,x1) => x0.unregister(x1),
      RF: () => globalThis.console,
      RG: (x0,x1) => { x0.value = x1 },
      RH: x0 => new Uint8Array(x0),
      RI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      RJ: (x0,x1) => x0.requestDevice(x1),
      RK: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      RL: x0 => x0.forEach,
      RM: (x0,x1,x2) => x0.detectForVideo(x1,x2),
      RN: x0 => x0.rasterStartMilliseconds,
      S: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      SB: Function.prototype.call.bind(DataView.prototype.getUint8),
      SC: () => globalThis.window,
      SD: x0 => x0.maxTouchPoints,
      SE: (x0,x1) => x0.contains(x1),
      SF: s => s.trimRight(),
      SG: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      SH: (x0,x1,x2) => x0.slice(x1,x2),
      SI: (a, s, e) => a.slice(s, e),
      SJ: x0 => x0.open(),
      SK: x0 => x0.naturalHeight,
      SL: x0 => x0.outputs,
      SM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      SN: x0 => x0.imageBitmaps,
      T: x0 => new Promise(x0),
      TB: (b, o) => new DataView(b, o),
      TC: (o, c) => o instanceof c,
      TD: x0 => x0.platform,
      TE: (s) => +s,
      TF: x0 => x0.blur(),
      TG: x0 => x0.value,
      TH: (x0,x1) => x0.decode(x1),
      TI: (x0,x1,x2) => x0.open(x1,x2),
      TJ: (x0,x1) => x0.selectConfiguration(x1),
      TK: x0 => x0.naturalWidth,
      TL: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      TM: x0 => x0.readyState,
      TN: x0 => x0.canvasKitMaximumSurfaces,
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: (b, o, l) => new DataView(b, o, l),
      UC: (string, token) => string.split(token),
      UD: x0 => x0.body,
      UE: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      UF: x0 => x0.button,
      UG: x0 => x0.selectionDirection,
      UH: (x0,x1) => x0.adoptText(x1),
      UI: () => globalThis.window,
      UJ: (x0,x1) => x0.claimInterface(x1),
      UK: x0 => x0.decode(),
      UL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      UM: (o, p, v) => o[p] = v,
      UN: x0 => x0.nextSibling,
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      VC: o => o instanceof Array,
      VD: () => globalThis.document,
      VE: s => s.trim(),
      VF: x0 => x0.innerHeight,
      VG: x0 => x0.selectionStart,
      VH: x0 => x0.first(),
      VI: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      VJ: (x0,x1,x2) => x0.selectAlternateInterface(x1,x2),
      VK: (x0,x1) => { x0.decoding = x1 },
      VL: x0 => x0.data,
      VM: x0 => x0.videoHeight,
      VN: (x0,x1) => x0.debug(x1),
      W: x0 => new Array(x0),
      WB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      WC: (a, i) => a[i],
      WD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      WE: x0 => x0.classList,
      WF: x0 => x0.innerWidth,
      WG: x0 => x0.selectionEnd,
      WH: x0 => x0.next(),
      WI: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      WJ: (x0,x1,x2,x3,x4) => ({requestType: x0,recipient: x1,request: x2,value: x3,index: x4}),
      WK: (x0,x1) => { x0.crossOrigin = x1 },
      WL: x0 => x0.id,
      WM: x0 => x0.videoWidth,
      WN: x0 => x0.baseURI,
      X: o => [o],
      XB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      XC: a => a.length,
      XD: x0 => x0.hasFocus(),
      XE: x0 => x0.preventDefault(),
      XF: x0 => x0.height,
      XG: x0 => x0.value,
      XH: x0 => x0.current(),
      XI: (x0,x1) => x0.removeItem(x1),
      XJ: (x0,x1) => x0.controlTransferOut(x1),
      XK: (x0,x1) => x0.createObjectURL(x1),
      XL: x0 => x0.name,
      XM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      XN: x0 => x0.hostElement,
      Y: (o0, o1) => [o0, o1],
      YB: (t, s) => t.set(s),
      YC: (x0,x1) => x0.test(x1),
      YD: x0 => x0.relatedTarget,
      YE: x0 => x0.parent,
      YF: x0 => x0.width,
      YG: x0 => x0.selectionDirection,
      YH: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      YI: x0 => x0.localStorage,
      YJ: (x0,x1,x2) => x0.transferIn(x1,x2),
      YK: x0 => x0.URL,
      YL: x0 => x0.forEach,
      YM: (x0,x1) => { x0.srcObject = x1 },
      YN: x0 => x0.location,
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      ZC: x0 => x0.userAgent,
      ZD: x0 => x0.shiftKey,
      ZE: x0 => x0.timeStamp,
      ZF: x0 => x0.clientHeight,
      ZG: x0 => x0.selectionStart,
      ZH: x0 => x0.v8BreakIterator,
      ZI: (x0,x1,x2) => x0.setItem(x1,x2),
      ZJ: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof DataView) return 1;
        return 2;
      },
      ZK: x0 => new Blob(x0),
      ZL: x0 => x0.inputs,
      ZM: x0 => x0.mediaDevices,
      ZN: (x0,x1) => x0.getModifierState(x1),
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      aC: x0 => x0.navigator,
      aD: (decoder, codeUnits) => decoder.decode(codeUnits),
      aE: (x0,x1) => x0.hasAttribute(x1),
      aF: x0 => x0.clientWidth,
      aG: x0 => x0.selectionEnd,
      aH: () => globalThis.Intl,
      aI: (x0,x1) => x0.getItem(x1),
      aJ: x0 => x0.data,
      aK: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      aL: (x0,x1) => { x0.onmidimessage = x1 },
      aM: x0 => x0.navigator,
      aN: x0 => x0.metaKey,
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      bC: Function.prototype.call.bind(String.prototype.toLowerCase),
      bD: () => new TextDecoder("utf-8", {fatal: true}),
      bE: x0 => x0.buttons,
      bF: (x0,x1) => { x0.content = x1 },
      bG: x0 => x0.keyCode,
      bH: (x0,x1) => x0.segment(x1),
      bI: (a, i) => a.splice(i, 1)[0],
      bJ: x0 => x0.endpointNumber,
      bK: x0 => new window.ImageDecoder(x0),
      bL: () => globalThis.navigator,
      bM: (x0,x1) => { x0.transform = x1 },
      bN: x0 => x0.altKey,
      c: o => o,
      cB: Function.prototype.call.bind(DataView.prototype.getUint32),
      cC: Object.is,
      cD: () => new TextDecoder("utf-8", {fatal: false}),
      cE: x0 => x0.ctrlKey,
      cF: (x0,x1) => { x0.name = x1 },
      cG: (x0,x1) => x0.scrollIntoView(x1),
      cH: x0 => x0.index,
      cI: (x0,x1) => x0.getRandomValues(x1),
      cJ: x0 => x0.direction,
      cK: x0 => x0.name,
      cL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      cM: (x0,x1) => { x0.objectFit = x1 },
      cN: x0 => x0.ctrlKey,
      d: (o, p) => o[p],
      dB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      dC: x0 => x0.vendor,
      dD: (a, i, v) => a[i] = v,
      dE: x0 => x0.y,
      dF: x0 => x0.head,
      dG: x0 => x0.multiViewEnabled,
      dH: x0 => x0.next(),
      dI: () => globalThis.crypto,
      dJ: x0 => x0.endpoints,
      dK: x0 => x0.repetitionCount,
      dL: (x0,x1,x2) => x0.addEventListener(x1,x2),
      dM: (x0,x1) => { x0.autoplay = x1 },
      dN: x0 => x0.isComposing,
      e: () => globalThis,
      eB: Function.prototype.call.bind(DataView.prototype.getInt32),
      eC: (x0,x1) => x0.createTextNode(x1),
      eD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      eE: x0 => x0.x,
      eF: (x0,x1) => x0.removeChild(x1),
      eG: (x0,x1) => x0.replaceWith(x1),
      eH: x0 => x0.value,
      eI: l => new DataView(new ArrayBuffer(l)),
      eJ: x0 => x0.interfaceNumber,
      eK: x0 => x0.frameCount,
      eL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eM: x0 => x0.userAgent,
      eN: x0 => x0.code,
      f: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      fC: (x0,x1) => { x0.id = x1 },
      fD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      fE: x0 => x0.scrollTop,
      fF: x0 => x0.firstChild,
      fG: (x0,x1) => { x0.type = x1 },
      fH: x0 => x0.done,
      fI: (o, p) => p in o,
      fJ: x0 => x0.interfaceClass,
      fK: x0 => x0.selectedTrack,
      fL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fM: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      fN: x0 => x0.repeat,
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: o => o instanceof Uint16Array,
      gC: (x0,x1) => { x0.nonce = x1 },
      gD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      gE: x0 => x0.offsetTop,
      gF: x0 => x0.viewConstraints,
      gG: (x0,x1) => { x0.className = x1 },
      gH: (o, m, a) => o[m].apply(o, a),
      gI: x0 => x0.groups,
      gJ: x0 => x0.alternates,
      gK: x0 => x0.completed,
      gL: (x0,x1) => x0.removeChild(x1),
      gM: x0 => x0.history,
      gN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      h: (x0,x1) => ({addView: x0,removeView: x1}),
      hB: Function.prototype.call.bind(DataView.prototype.getUint16),
      hC: x0 => x0.nonce,
      hD: x0 => x0.visibilityState,
      hE: x0 => x0.scrollLeft,
      hF: x0 => x0.hostElement,
      hG: (x0,x1) => { x0.tabIndex = x1 },
      hH: x0 => x0.iterator,
      hI: () => new AbortController(),
      hJ: x0 => x0.interfaces,
      hK: x0 => x0.ready,
      hL: (o, a) => o + a,
      hM: x0 => x0.href,
      hN: (x0,x1) => x0.key(x1),
      i: (l, r) => l === r,
      iB: o => o instanceof Int16Array,
      iC: () => globalThis.window.flutterConfiguration,
      iD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      iE: x0 => x0.offsetLeft,
      iF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      iG: (x0,x1) => { x0.name = x1 },
      iH: () => globalThis.Symbol,
      iI: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      iJ: x0 => x0.configuration,
      iK: x0 => x0.tracks,
      iL: x0 => x0.children,
      iM: x0 => x0.location,
      iN: x0 => x0.length,
      j: x0 => x0.random(),
      jB: Function.prototype.call.bind(DataView.prototype.getInt16),
      jC: (x0,x1) => x0.attachShadow(x1),
      jD: x0 => x0.disconnect(),
      jE: x0 => x0.offsetParent,
      jF: x0 => ({runApp: x0}),
      jG: (x0,x1) => { x0.placeholder = x1 },
      jH: (x0,x1) => new Intl.Segmenter(x0,x1),
      jI: (x0,x1) => globalThis.fetch(x0,x1),
      jJ: x0 => ({vendorId: x0}),
      jK: x0 => x0.close(),
      jL: x0 => x0.firstChild,
      jM: () => new Array(),
      jN: (x0,x1) => x0.querySelector(x1),
      k: o => o,
      kB: o => o instanceof Uint8ClampedArray,
      kC: (x0,x1) => x0.createElement(x1),
      kD: x0 => new Intl.Locale(x0),
      kE: (o, p, r) => o.replace(p, () => r),
      kF: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      kG: (x0,x1) => { x0.autocomplete = x1 },
      kH: x0 => x0.Segmenter,
      kI: (x0,x1) => x0.get(x1),
      kJ: () => globalThis.navigator.usb,
      kK: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      kL: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      kM: (x0,x1) => new WebSocket(x0,x1),
      kN: (x0,x1) => { x0.id = x1 },
      l: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      lB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      lC: x0 => x0.scale,
      lD: x0 => x0.region,
      lE: (x0,x1) => { x0.lastIndex = x1 },
      lF: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      lG: (x0,x1) => { x0.name = x1 },
      lH: x0 => x0.buffer,
      lI: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      lJ: () => globalThis.showDirectoryPicker,
      lK: (x0,x1) => x0.decode(x1),
      lL: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      lM: x0 => x0.reason,
      lN: x0 => x0.length,
      m: () => globalThis.Math,
      mB: Function.prototype.call.bind(DataView.prototype.setInt32),
      mC: x0 => x0.visualViewport,
      mD: x0 => x0.script,
      mE: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      mF: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      mG: (x0,x1) => { x0.placeholder = x1 },
      mH: x0 => x0.wasmMemory,
      mI: (x0,x1) => x0.forEach(x1),
      mJ: o => o.byteLength,
      mK: x0 => x0.displayHeight,
      mL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      mM: x0 => x0.code,
      mN: x0 => x0.getReader(),
      n: (x0,x1) => x0.prepend(x1),
      nB: Function.prototype.call.bind(DataView.prototype.setUint32),
      nC: x0 => x0.devicePixelRatio,
      nD: x0 => x0.language,
      nE: o => o instanceof RegExp,
      nF: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      nG: (x0,x1) => { x0.action = x1 },
      nH: () => globalThis.window._flutter_skwasmInstance,
      nI: x0 => x0.name,
      nJ: x0 => x0.name,
      nK: x0 => x0.displayWidth,
      nL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      nM: (o, t) => typeof o === t,
      nN: x0 => x0.value,
      o: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      oB: Function.prototype.call.bind(DataView.prototype.setInt16),
      oC: x0 => x0.height,
      oD: x0 => x0.languages,
      oE: x0 => x0.dotAll,
      oF: x0 => x0.history,
      oG: (x0,x1) => { x0.method = x1 },
      oH: () => new TextDecoder(),
      oI: x0 => x0.statusText,
      oJ: x0 => x0.close(),
      oK: x0 => x0.duration,
      oL: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      oM: x0 => x0.data,
      oN: x0 => x0.done,
      p: b => !!b,
      pB: Function.prototype.call.bind(DataView.prototype.setUint16),
      pC: x0 => x0.width,
      pD: (x0,x1) => x0.observe(x1),
      pE: x0 => x0.unicode,
      pF: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      pG: (x0,x1) => { x0.noValidate = x1 },
      pH: x0 => x0.debugSkipFontRetryDelay,
      pI: x0 => x0.url,
      pJ: (x0,x1) => x0.write(x1),
      pK: x0 => x0.image,
      pL: (x0,x1) => x0.item(x1),
      pM: (x0,x1,x2) => x0.close(x1,x2),
      pN: x0 => x0.read(),
      q: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      qB: Function.prototype.call.bind(DataView.prototype.setUint8),
      qC: x0 => x0.screen,
      qD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      qE: x0 => x0.ignoreCase,
      qF: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      qG: (x0,x1) => x0.removeAttribute(x1),
      qH: (x0,x1,x2) => x0.set(x1,x2),
      qI: x0 => x0.status,
      qJ: x0 => x0.createWritable(),
      qK: () => globalThis.window.ImageDecoder,
      qL: () => new FileReader(),
      qM: (x0,x1) => x0.close(x1),
      qN: x0 => x0.body,
      r: (x0,x1) => x0.focus(x1),
      rB: Function.prototype.call.bind(DataView.prototype.setInt8),
      rC: (string, times) => string.repeat(times),
      rD: x0 => new ResizeObserver(x0),
      rE: x0 => x0.multiline,
      rF: o => Object.keys(o),
      rG: x0 => x0.isConnected,
      rH: x0 => x0.fontFallbackBaseUrl,
      rI: x0 => x0.getReader(),
      rJ: x0 => ({create: x0}),
      rK: x0 => x0.decode(),
      rL: (x0,x1) => x0.readAsArrayBuffer(x1),
      rM: x0 => x0.close(),
      rN: (x0,x1) => new OffscreenCanvas(x0,x1),
      s: () => ({}),
      sB: Function.prototype.call.bind(DataView.prototype.getInt8),
      sC: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      sD: (x0,x1) => x0.getPropertyValue(x1),
      sE: (o, p, r) => o.replaceAll(p, () => r),
      sF: x0 => x0.state,
      sG: x0 => x0.click(),
      sH: (handle) => clearInterval(handle),
      sI: x0 => x0.read(),
      sJ: (x0,x1,x2) => x0.getFileHandle(x1,x2),
      sK: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      sL: x0 => ({type: x0}),
      sM: (x0,x1) => x0.send(x1),
      sN: x0 => x0.assetBase,
      t: (o, p, v) => o[p] = v,
      tB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      tC: x0 => x0.tabIndex,
      tD: x0 => globalThis.parseFloat(x0),
      tE: x0 => x0.deltaMode,
      tF: x0 => x0.state,
      tG: (x0,x1) => x0.getElementsByClassName(x1),
      tH: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      tI: x0 => x0.value,
      tJ: x0 => x0.arrayBuffer(),
      tK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tL: (x0,x1) => new Blob(x0,x1),
      tM: x0 => x0.readyState,
      tN: x0 => x0.loader,
      u: () => [],
      uB: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      uC: (x0,x1) => x0.contains(x1),
      uD: (x0,x1) => x0.getComputedStyle(x1),
      uE: x0 => x0.deltaY,
      uF: (x0,x1) => x0.go(x1),
      uG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      uH: () => Date.now(),
      uI: x0 => x0.done,
      uJ: x0 => x0.getFile(),
      uK: (x0,x1,x2) => x0.addEventListener(x1,x2),
      uL: x0 => x0.size,
      uM: (x0,x1) => { x0.binaryType = x1 },
      uN: () => globalThis._flutter,
      v: (a, i) => a.push(i),
      vB: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      vC: x0 => x0.activeElement,
      vD: x0 => x0.documentElement,
      vE: x0 => x0.deltaX,
      vF: x0 => x0.hash,
      vG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      vH: (x0,x1) => x0.send(x1),
      vI: x0 => x0.cancel(),
      vJ: (x0,x1,x2) => x0.transferOut(x1,x2),
      vK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      vL: x0 => x0.name,
      vM: x0 => new BroadcastChannel(x0),
      w: x0 => new Int8Array(x0),
      wB: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      wC: x0 => x0.parentNode,
      wD: x0 => x0.computedStyleMap(),
      wE: x0 => x0.wheelDeltaY,
      wF: x0 => x0.location,
      wG: (x0,x1) => x0.dispatchEvent(x1),
      wH: x0 => x0.pop(),
      wI: x0 => x0.body,
      wJ: x0 => new Blob(x0),
      wK: x0 => x0.send(),
      wL: x0 => x0.type,
      wM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      x: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      xB: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      xC: x0 => x0.tagName,
      xD: (x0,x1) => x0.get(x1),
      xE: x0 => x0.wheelDeltaX,
      xF: x0 => x0.search,
      xG: (x0,x1) => x0.createEvent(x1),
      xH: (x0,x1,x2) => x0.insertBefore(x1,x2),
      xI: x0 => x0.headers,
      xJ: x0 => globalThis.URL.createObjectURL(x0),
      xK: x0 => x0.status,
      xL: x0 => x0.result,
      xM: x0 => x0.close(),
      y: x0 => new Uint8Array(x0),
      yB: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      yC: x0 => x0.target,
      yD: (o, p) => p in o,
      yE: x0 => x0.key,
      yF: x0 => x0.pathname,
      yG: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      yH: x0 => x0.id,
      yI: x0 => x0.signal,
      yJ: x0 => x0.click(),
      yK: x0 => x0.response,
      yL: x0 => x0.length,
      yM: (x0,x1) => x0.postMessage(x1),
      z: x0 => new Uint8ClampedArray(x0),
      zB: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      zC: x0 => x0.clientY,
      zD: (x0,x1) => { x0.textContent = x1 },
      zE: x0 => x0.identifier,
      zF: x0 => x0.parentElement,
      zG: x0 => x0.readText(),
      zH: x0 => x0.offsetHeight,
      zI: x0 => x0.abort(),
      zJ: x0 => globalThis.URL.revokeObjectURL(x0),
      zK: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      zL: x0 => x0.files,
      zM: (x0,x1) => { x0.onmessage = x1 },

    };

    const baseImports = {
      _: dart2wasm,
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
