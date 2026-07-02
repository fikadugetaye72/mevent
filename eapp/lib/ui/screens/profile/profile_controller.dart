import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class ProfileController extends GetxController {
  late final AuthService _auth;

  final Rxn<User> user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthService>();
    user.bindStream(_auth.currentUser.stream);
    user.value = _auth.currentUser.value;
  }
}
