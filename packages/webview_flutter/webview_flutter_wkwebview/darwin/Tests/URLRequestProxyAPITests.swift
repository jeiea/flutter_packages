// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

class RequestProxyAPITests: XCTestCase {
  func testURLGetAbsoluteStringMessageHandlerReturnsString() {
    let messenger = TestBinaryMessenger()
    let registrar = ProxyAPIRegistrar(binaryMessenger: messenger)
    registrar.setUp()
    defer { registrar.tearDown() }

    let url = URL(string: "https://flutter.dev/path")!
    let message = registrar.codec.encode([url])
    let reply = messenger.sendToMessageHandler(
      onChannel: "dev.flutter.pigeon.webview_flutter_wkwebview.URL.getAbsoluteString",
      message: message)
    let response = registrar.codec.decode(reply) as? [Any?]

    XCTAssertEqual(response?.first as? String, url.absoluteString)
  }

  func testURLGetAbsoluteStringMessageHandlerReturnsMissingInstanceError() {
    // This covers a manual correction to generated Swift until Pigeon safely rejects missing
    // host-call proxy arguments. https://github.com/flutter/flutter/issues/191254 tracks the same
    // lifetime class; https://github.com/flutter/packages/pull/12531 guards the opposite direction.
    // Remove the correction only after the generated handler returns this error itself.
    let messenger = TestBinaryMessenger()
    let registrar = ProxyAPIRegistrar(binaryMessenger: messenger)
    registrar.setUp()
    defer { registrar.tearDown() }

    let message = missingURLCodec.encode([MissingURL(identifier: 42)])
    let reply = messenger.sendToMessageHandler(
      onChannel: "dev.flutter.pigeon.webview_flutter_wkwebview.URL.getAbsoluteString",
      message: message)
    let response = registrar.codec.decode(reply) as? [Any?]

    XCTAssertEqual(response?.first as? String, "missing-instance-error")
  }

  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api, url: "myString")
    XCTAssertNotNil(instance)
  }

  func testGetUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let value = try? api.pigeonDelegate.getUrl(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.value.url?.absoluteString)
  }

  func testSetHttpMethod() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let method = "GET"
    try? api.pigeonDelegate.setHttpMethod(pigeonApi: api, pigeonInstance: instance, method: method)

    XCTAssertEqual(instance.value.httpMethod, method)
  }

  func testGetHttpMethod() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))

    let method = "POST"
    instance.value.httpMethod = method
    let value = try? api.pigeonDelegate.getHttpMethod(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, method)
  }

  func testSetHttpBody() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let body = FlutterStandardTypedData(bytes: Data())
    try? api.pigeonDelegate.setHttpBody(pigeonApi: api, pigeonInstance: instance, body: body)

    XCTAssertEqual(instance.value.httpBody, body.data)
  }

  func testGetHttpBody() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let body = FlutterStandardTypedData(bytes: Data())
    instance.value.httpBody = body.data
    let value = try? api.pigeonDelegate.getHttpBody(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value?.data, body.data)
  }

  func testSetAllHttpHeaderFields() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let fields = ["key": "value"]
    try? api.pigeonDelegate.setAllHttpHeaderFields(
      pigeonApi: api, pigeonInstance: instance, fields: fields)

    XCTAssertEqual(instance.value.allHTTPHeaderFields, fields)
  }

  func testGetAllHttpHeaderFields() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLRequest(registrar)

    let instance = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    let fields = ["key": "value"]
    instance.value.allHTTPHeaderFields = fields

    let value = try? api.pigeonDelegate.getAllHttpHeaderFields(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, fields)
  }
}

private final class MissingURL {
  let identifier: Int64

  init(identifier: Int64) {
    self.identifier = identifier
  }
}

private class MissingURLCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let missingURL = value as? MissingURL {
      super.writeByte(128)
      super.writeValue(missingURL.identifier)
    } else {
      super.writeValue(value)
    }
  }
}

private class MissingURLCodecReaderWriter: FlutterStandardReaderWriter {
  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return MissingURLCodecWriter(data: data)
  }
}

private let missingURLCodec = FlutterStandardMessageCodec(
  readerWriter: MissingURLCodecReaderWriter())
