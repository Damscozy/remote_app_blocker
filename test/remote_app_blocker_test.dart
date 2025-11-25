import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_app_blocker/remote_app_blocker.dart';

void main() {
  test('adds one to input values', () {
    RemoteBlockConfig config = RemoteBlockConfig(
      blockedVersions: ['1.0.0', '1.0.1'],
      message: 'This app is blocked.',
      isBlocked: true,
    );
    debugPrint(config.toString());
  });
}
