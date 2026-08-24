// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class ProxyAPIRegistrarTests: XCTestCase {
  func testCodecRetainsRegistrarAfterTearDownUntilEncodingCompletes() {
    let messenger = TestBinaryMessenger()
    var registrar: ProxyAPIRegistrar? = ProxyAPIRegistrar(binaryMessenger: messenger)
    weak let weakRegistrar = registrar
    var codec = Optional(registrar!.codec)

    messenger.sendHandler = {
      registrar!.tearDown()
      registrar = nil
      messenger.sendHandler = nil
    }

    let request = URLRequestWrapper(URLRequest(url: URL(string: "https://flutter.dev")!))
    XCTAssertNotNil(codec!.encode(request))
    XCTAssertNotNil(weakRegistrar)

    codec = nil
    XCTAssertNil(weakRegistrar)
  }

  func testLogFlutterMethodFailureDoesNotThrowAnError() {
    let registrar = TestProxyApiRegistrar()

    XCTExpectFailure("Method should log a message and not throw an error.") {
      XCTAssertThrowsError(
        registrar.logFlutterMethodFailure(
          PigeonError(code: "code", message: "message", details: nil), methodName: "aMethod"))
    }
  }
}
