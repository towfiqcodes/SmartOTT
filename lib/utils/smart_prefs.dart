import 'package:get_storage/get_storage.dart';

class SmartPrefs {
  static final getStorage = GetStorage('SmartOTTPrefs');

  String get userId => getStorage.read('userId') ?? '';

  void setUserId(String val) => getStorage.write('userId', val);

  String get userEmail => getStorage.read('userEmail') ?? '';

  void setUserEmail(String val) => getStorage.write('userEmail', val);

  String get imageUrl => getStorage.read('imageUrl') ?? '';

  void setImageUrl(String val) => getStorage.write('imageUrl', val);

  String get fullName => getStorage.read('fullName') ?? '';

  void setFullName(String val) => getStorage.write('fullName', val);

  bool get isLogin => getStorage.read('isLogin') ?? false;

  void setIsLogin(bool val) => getStorage.write('isLogin', val);

  void clear() {
    getStorage.erase();
  }
}
