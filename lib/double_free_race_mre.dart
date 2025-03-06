import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io' show Platform;

main() async {
  late final DynamicLibrary nativeLib;

  if (Platform.isLinux) {
    nativeLib = DynamicLibrary.open('libnative.so');
  } else if (Platform.isMacOS) {
    nativeLib = DynamicLibrary.open('libnative.dylib');
  } else {
    throw "wat";
  }

  var _wakePort = ReceivePort()..listen(_pollTask);

  var initResult = nativeLib.lookupFunction<
      IntPtr Function(Pointer<Void>, Int64),
      int Function(Pointer<Void>, int)>
    ('start_send_loop')(NativeApi.initializeApiDLData, _wakePort.sendPort.nativePort);

  assert(initResult == 0);
}

void _pollTask(dynamic msg) {
  msg as Uint8List;
  // print("DART: recv ${msg.buffer.asByteData().getUint64(0, Endian.big)}");
}
