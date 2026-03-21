import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

const _usbBufferSize = 64;

const _vendorFilters = [
  0x239A, // Adafruit boards
  0xCAFE, // TinyUSB example
];

@JS('navigator.usb')
external USB? get _navigatorUsb;

extension type USB._(JSObject _) implements JSObject {
  external JSPromise<USBDevice> requestDevice(
    USBDeviceRequestOptions options,
  );
}

extension type USBDeviceRequestOptions._(JSObject _)
    implements JSObject {
  external factory USBDeviceRequestOptions({
    JSArray<USBDeviceFilter> filters,
  });
}

extension type USBDeviceFilter._(JSObject _)
    implements JSObject {
  external factory USBDeviceFilter({int vendorId});
}

extension type USBDevice._(JSObject _) implements JSObject {
  external USBConfiguration? get configuration;
  external JSPromise<JSAny?> open();
  external JSPromise<JSAny?> close();
  external JSPromise<JSAny?> selectConfiguration(
    int configurationValue,
  );
  external JSPromise<JSAny?> claimInterface(
    int interfaceNumber,
  );
  external JSPromise<JSAny?> selectAlternateInterface(
    int interfaceNumber,
    int alternateSetting,
  );
  external JSPromise<JSAny?> controlTransferOut(
    USBControlTransferParameters setup,
  );
  external JSPromise<USBInTransferResult> transferIn(
    int endpointNumber,
    int length,
  );
  external JSPromise<JSAny?> transferOut(
    int endpointNumber,
    JSArrayBuffer data,
  );
}

extension type USBControlTransferParameters._(JSObject _)
    implements JSObject {
  external factory USBControlTransferParameters({
    String requestType,
    String recipient,
    int request,
    int value,
    int index,
  });
}

extension type USBConfiguration._(JSObject _)
    implements JSObject {
  external JSArray<USBInterface> get interfaces;
}

extension type USBInterface._(JSObject _)
    implements JSObject {
  external int get interfaceNumber;
  external JSArray<USBAlternateInterface> get alternates;
}

extension type USBAlternateInterface._(JSObject _)
    implements JSObject {
  external int get interfaceClass;
  external int get alternateSetting;
  external JSArray<USBEndpoint> get endpoints;
}

extension type USBEndpoint._(JSObject _)
    implements JSObject {
  external String get direction;
  external int get endpointNumber;
}

extension type USBInTransferResult._(JSObject _)
    implements JSObject {
  external JSDataView? get data;
}

typedef DataReceivedCallback = void Function(ByteData data);
typedef ErrorCallback = void Function(Object error);

class WebUsbService {
  USBDevice? _device;
  int _interfaceNumber = 0;
  int _endpointIn = 0;
  int _endpointOut = 0;
  bool _connected = false;

  DataReceivedCallback? onDataReceived;
  ErrorCallback? onError;

  bool get isConnected => _connected;

  static bool get isSupported => _navigatorUsb != null;

  Future<void> connect() async {
    final usb = _navigatorUsb;
    if (usb == null) {
      throw UnsupportedError(
        'WebUSB is not supported in this browser',
      );
    }

    final filters = _vendorFilters
        .map(
          (vendorId) =>
              USBDeviceFilter(vendorId: vendorId),
        )
        .toList();

    final options = USBDeviceRequestOptions(
      filters: filters.toJS,
    );
    _device = await usb.requestDevice(options).toDart;

    await _device!.open().toDart;

    final configuration = _device!.configuration;
    if (configuration == null) {
      await _device!.selectConfiguration(1).toDart;
    }

    _setEndpoints();

    await _device!
        .claimInterface(_interfaceNumber)
        .toDart;

    try {
      await _device!
          .selectAlternateInterface(
            _interfaceNumber,
            _endpointIn,
          )
          .toDart;
    } on Object {
      // Some devices don't support alternate interface
      // selection.
    }

    final controlSetup = USBControlTransferParameters(
      requestType: 'class',
      recipient: 'interface',
      request: 0x22,
      value: 0x01,
      index: _interfaceNumber,
    );
    await _device!
        .controlTransferOut(controlSetup)
        .toDart;

    _connected = true;
    unawaited(_readLoop());
  }

  void _setEndpoints() {
    final configuration = _device!.configuration!;
    final interfaces = configuration.interfaces.toDart;

    for (final usbInterface in interfaces) {
      final alternates = usbInterface.alternates.toDart;

      for (final alternate in alternates) {
        if (alternate.interfaceClass == 0xFF) {
          _interfaceNumber =
              usbInterface.interfaceNumber;
          final endpoints = alternate.endpoints.toDart;

          for (final endpoint in endpoints) {
            if (endpoint.direction == 'out') {
              _endpointOut = endpoint.endpointNumber;
            }
            if (endpoint.direction == 'in') {
              _endpointIn = endpoint.endpointNumber;
            }
          }
        }
      }
    }
  }

  Future<void> _readLoop() async {
    while (_connected) {
      try {
        final result = await _device!
            .transferIn(_endpointIn, _usbBufferSize)
            .toDart;

        final dataView = result.data;
        if (dataView != null) {
          final byteData = dataView.toDart;
          onDataReceived?.call(byteData);
        }
      } on Object catch (error) {
        if (_connected) {
          onError?.call(error);
        }
        break;
      }
    }
  }

  Future<void> send(Uint8List data) async {
    if (_device == null || !_connected) {
      return;
    }
    await _device!
        .transferOut(
          _endpointOut,
          data.buffer.toJS,
        )
        .toDart;
  }

  Future<void> disconnect() async {
    _connected = false;
    if (_device != null) {
      try {
        final controlSetup =
            USBControlTransferParameters(
          requestType: 'class',
          recipient: 'interface',
          request: 0x22,
          value: 0x00,
          index: _interfaceNumber,
        );
        await _device!
            .controlTransferOut(controlSetup)
            .toDart;
        await _device!.close().toDart;
      } on Object {
        // Ignore errors during disconnect.
      }
    }
    _device = null;
  }
}
