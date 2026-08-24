// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'web_kit.g.dart';

/// The callback that requested conversion of a native URL proxy.
enum URLCallbackType {
  /// A web view URL change callback.
  urlChange('while handling a URL change callback'),

  /// A provisional navigation failure callback.
  provisionalNavigationFailure('while handling a provisional navigation failure callback');

  const URLCallbackType(this.errorContext);

  /// Non-sensitive context reported when a native URL proxy is unavailable.
  final String errorContext;
}

/// Returns the absolute string of [url], or null if its native proxy is gone.
Future<String?> getAbsoluteStringOrNull(URL url, URLCallbackType callbackType) async {
  try {
    return await url.getAbsoluteString();
  } on PlatformException catch (error) {
    if (error.code != 'missing-instance-error') {
      rethrow;
    }

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: FlutterError('A native URL proxy instance was unavailable.'),
        library: 'webview_flutter_wkwebview',
        context: ErrorDescription(callbackType.errorContext),
      ),
    );
    return null;
  }
}
