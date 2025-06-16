import 'package:get/get.dart';

class AuthController extends GetxController {
  RxString currentUserDocumentId = ''.obs;

  void setCurrentUserDocumentId(String userId) {
    currentUserDocumentId.value = userId;
  }

  String getCurrentUserDocumentId() {
    return currentUserDocumentId.value;
  }
}