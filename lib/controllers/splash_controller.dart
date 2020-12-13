import 'dart:async';

import 'package:enote/views/phone_number/phone_number_screen.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(Duration(seconds: 3), () => Get.off(PhoneNumber()));
    super.onInit();
  }
}
