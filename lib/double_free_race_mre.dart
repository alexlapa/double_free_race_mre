import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io' show Platform;

final class ShutdownWatcher implements Finalizable {
  static var _finalizer;

  ShutdownWatcher(Pointer<NativeFinalizerFunction> callback) {
    _finalizer = NativeFinalizer(callback);
    _finalizer.attach(this, Pointer.fromAddress(0));
  }
}

ShutdownWatcher? shutdownWatcher;

main() async {
  late final DynamicLibrary nativeLib;

  if (Platform.isLinux) {
    nativeLib = DynamicLibrary.open('libnative.so');
  } else if (Platform.isMacOS) {
    nativeLib = DynamicLibrary.open('libnative.dylib');
  } else {
    throw "wat";
  }

  shutdownWatcher = ShutdownWatcher(
    nativeLib.lookup<NativeFinalizerFunction>('shutdown_callback'),
  );

  var _wakePort = ReceivePort()..listen(_pollTask);

  var initResult = nativeLib.lookupFunction<
    IntPtr Function(Pointer<Void>, Int64),
    int Function(Pointer<Void>, int)
  >('start_send_loop')(
    NativeApi.initializeApiDLData,
    _wakePort.sendPort.nativePort,
  );

  assert(initResult == 0);
}

void _pollTask(dynamic msg) {
  msg as Uint8List;
  // print("DART: recv ${msg.buffer.asByteData().getUint64(0, Endian.big)}");
}
