import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:little_hero/features/parent_access/data/parent_pin_store.dart';

class FakeParentPinStore extends ParentPinStore {
  FakeParentPinStore({this.pin})
    : super(const FlutterSecureStorage(), scope: 'test');
  String? pin;
  @override
  Future<bool> isConfigured() async => pin != null;
  @override
  Future<void> setPin(String value, {bool replace = false}) async {
    pin = value;
  }

  @override
  Future<void> verify(String value) async {
    if (value != pin) throw const ParentPinException('家长密码不正确，请重试。');
  }
}
