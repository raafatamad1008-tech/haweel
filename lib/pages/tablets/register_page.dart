import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/AuthGate.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/user_model.dart';
import 'package:haweel/pages/tablets/login_page.dart';
import 'package:haweel/pages/tablets/login_page_tablet.dart';
import 'package:haweel/services/auth_service.dart';
import 'package:haweel/widgets/input.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final bool isGoogleUser;
  final socialUser;
  const RegisterPage({
    super.key,
    this.isGoogleUser = false,
    this.socialUser = null,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final license = TextEditingController();
  final licenseDate = TextEditingController();

  File? _image;

  int currentPage = 0;

  bool isErrorMessage = false;
  bool isTryingToRegister = false;
  late String message;

  @override
  void initState() {
    super.initState();

    if (widget.isGoogleUser) {
      currentPage = 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(1);
      });
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      name.text = user.displayName ?? "";
      email.text = user.email ?? "";
    }
  }

  // اختيار صورة
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse(
      "https://matheon.online/haweel/public/api/upload-image",
    );

    var request = http.MultipartRequest("POST", url)
      ..headers['Accept'] = 'application/json';
    // ..headers['Content-Type'] = 'multipart/form-data';

    if (_image != null && await File(_image!.path).exists()) {
      request.files.add(
        await http.MultipartFile.fromPath("image", imageFile.path),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار صورة ')));
    }

    var response = await request.send();

    var responseData = await response.stream.bytesToString();
    print("status: ${response.statusCode}");
    print("body: $responseData");
    if (response.statusCode == 200) {
      var data = jsonDecode(responseData);
      return data["url"];
    }

    setState(() {
      isTryingToRegister = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('فشل رفع الصورة ')));

    return null;
  }

  // إنشاء الحساب الكامل
  Future<void> registerUser() async {
    setState(() {
      isTryingToRegister = true;
      isErrorMessage = false;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        isTryingToRegister = false;
      });
      return;
    }

    try {
      final auth = AuthService();
      final firebaseUser = FirebaseAuth.instance.currentUser;

      String uid;

      /// إنشاء حساب إذا لم يكن مستخدم Google
      if (firebaseUser == null) {
        final userCredential = await auth.register(
          email: email.text.trim(),
          password: password.text.trim(),
        );

        uid = userCredential.user!.uid;
      } else {
        uid = firebaseUser.uid;
      }

      /// رفع الصورة
      String imageUrl = "";

      if (_image != null) {
        final uploaded = await uploadImage(_image!);
        if (uploaded != null) {
          imageUrl = uploaded;
        }
      }

      /// إنشاء نموذج المستخدم
      final userModel = UserModel(
        uid: uid,
        name: name.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        city: city.text.trim(),
        license: license.text.trim(),
        licenseExpireDate: licenseDate.text.trim(),
        image: imageUrl,
        status: 1,
        membership: 0,
        profileCompleted: 1,
        badges: [],
        bubblishedContract: 0,
        completedContracts: 0,
        responseTime: 999,
        rating: 0.0,
        isVerified: false,
        fcmToken: "",
        createdAt: DateTime.now(),
      );

      /// حفظ في Firestore
      // await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc(uid)
      //     .set(userModel.toMap());

    await FirebaseFirestore.instance
    .collection("users")
    .doc(uid)
    .set(
      userModel.toMap(),
      SetOptions(merge: true),
    );

      /// الانتقال للواجهة الرئيسية
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }
    }
    /// أخطاء FirebaseAuth
    on FirebaseAuthException catch (e) {
      String errorMessage = "حدث خطأ غير متوقع";

      switch (e.code) {
        case "email-already-in-use":
          errorMessage = "هذا البريد الإلكتروني مستخدم بالفعل";
          break;

        case "weak-password":
          errorMessage = "كلمة المرور ضعيفة";
          break;

        case "invalid-email":
          errorMessage = "صيغة البريد الإلكتروني غير صحيحة";
          break;

        case "network-request-failed":
          errorMessage = "تحقق من اتصال الإنترنت";
          break;

        case "operation-not-allowed":
          errorMessage = "تسجيل البريد الإلكتروني غير مفعل";
          break;
      }

      setState(() {
        isErrorMessage = true;
        message = errorMessage;
      });
    }
    /// أخطاء Firestore أو السيرفر
    catch (e) {
      setState(() {
        isErrorMessage = true;
        message = "حدث خطأ أثناء إنشاء الحساب";
      });

      print("Register Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isTryingToRegister = false;
        });
      }
    }
  }

  void nextPage() {
    if (currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage++);
    }
  }

  void prevPage() {
    if (currentPage >= 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        width: 500,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imgs/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // الصفحة 1
              buildPage1(),

              // الصفحة 2
              buildPage2(),

              // الصفحة 3
              buildPage3(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPage1() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            SizedBox(height: 10),
            Stack(
              children: [
                Align(
                  alignment: AlignmentGeometry.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 213, 195, 255),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new),
                      onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPageTablet()));
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentGeometry.topCenter,
                  child: Image.asset("assets/imgs/logo.png", width: 200),
                ),
              ],
            ),
            SizedBox(height: 40),
            isErrorMessage
                ? Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  )
                : Text(
                    "انشاء حساب",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
            SizedBox(height: 40),
            Input(
              controller: name,
              label: "اسم المستخدم",
              icon: FluentIcons.person_20_regular,
              iconColor: AppColors.primary,
              borderColor: const Color.fromARGB(255, 241, 130, 122),
              isScure: false,
            ),
            SizedBox(height: 20),
            Input(
              controller: email,
              label: "البريد الالكتروني",
              icon: FluentIcons.mail_20_regular,
              iconColor: AppColors.primary,
              borderColor: const Color.fromARGB(255, 241, 130, 122),
              isScure: false,
            ),
            SizedBox(height: 20),
            Input(
              controller: password,
              label: "كلمة المرور",
              icon: FluentIcons.password_20_regular,
              iconColor: AppColors.primary,
              borderColor: const Color.fromARGB(255, 241, 130, 122),
              isScure: true,
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "التالي",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage2() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 10),
            Image.asset("assets/imgs/logo.png", width: 200),
            SizedBox(height: 40),
            isErrorMessage
                ? Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  )
                : Text(
                    "بيانات اخري",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
            SizedBox(height: 40),
            Input(
              controller: address,
              label: "العنوان",
              icon: FluentIcons.person_20_regular,
              iconColor: AppColors.primary,
              borderColor: const Color.fromARGB(255, 241, 130, 122),
              isScure: false,
            ),
            SizedBox(height: 20),
            Input(
              controller: city,
              label: "المدينة",
              icon: FluentIcons.city_24_regular,
              iconColor: AppColors.primary,
              borderColor: const Color.fromARGB(255, 241, 130, 122),
              isScure: false,
            ),
            SizedBox(height: 20),
            Input(
              controller: license,
              label: "رقم الرخصة",
              icon: FluentIcons.certificate_24_regular,
              iconColor: AppColors.primary,
              borderColor: Color.fromARGB(255, 241, 130, 122),
              isScure: false,
            ),
            SizedBox(height: 20),
            Input(
              controller: licenseDate,
              label: "تاريخ الانتهاء",
              icon: FluentIcons.calculator_24_regular,
              iconColor: AppColors.primary,
              borderColor: const Color.fromARGB(255, 241, 130, 122),
              type: "date",
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "التالي",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: prevPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "رجوع",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage3() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.asset("assets/imgs/logo.png", width: 200),
          SizedBox(height: 40),
          isErrorMessage
              ? Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                )
              : Text(
                  "صورة المستخدم",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
          SizedBox(height: 40),
          GestureDetector(
            onTap: pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? const Icon(Icons.add_a_photo, size: 40)
                  : null,
            ),
          ),
          SizedBox(height: 40),
          Text(
            "اختر صورة للملف الشخصي",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          Spacer(),
          const SizedBox(height: 20),
          isTryingToRegister
              ? SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: CircularProgressIndicator(
                      color: AppColors.roundBackground,
                    ),
                  ),
                )
              : SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "انشاء الحساب",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 20),
          SizedBox(
            width: 400,
            child: ElevatedButton(
              onPressed: prevPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text(
                "رجوع",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
