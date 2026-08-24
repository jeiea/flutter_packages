// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_wkwebview/src/common/url_utils.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';

void main() {
  test('getAbsoluteStringOrNull rethrows other platform exceptions', () async {
    final exception = PlatformException(
      code: 'other-error',
      message: 'message',
      details: 'details',
    );

    await expectLater(
      getAbsoluteStringOrNull(_ThrowingURL(exception), URLCallbackType.urlChange),
      throwsA(same(exception)),
    );
  });
}

class _ThrowingURL extends URL {
  _ThrowingURL(this.exception) : super.pigeon_detached();

  final PlatformException exception;

  @override
  Future<String> getAbsoluteString() => Future<String>.error(exception);
}
