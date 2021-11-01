import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_3d_ball/flutter_3d_ball.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_3d_ball');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await Flutter3dBall.platformVersion, '42');
  // });
}
