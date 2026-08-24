// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

class TestBinaryMessenger: NSObject, FlutterBinaryMessenger {
  var sendHandler: (() -> Void)?

  func send(onChannel channel: String, message: Data?) {
    sendHandler?()
  }

  func send(
    onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {
    sendHandler?()
  }

  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    return 0
  }

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {

  }
}
