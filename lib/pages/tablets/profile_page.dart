import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/user_model.dart';
import 'package:haweel/services/auth_service.dart';
import 'package:haweel/services/user_service.dart';
import 'package:haweel/widgets/input.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<UserModel?>? userFuture;
  late String uid;
  File? _image;

  bool isUploading = false;

  @override
  void initState() {
    super.initState();

    uid = FirebaseAuth.instance.currentUser!.uid;

    userFuture = UserService().getUser(uid);
  }

  Future<String?> uploadImage(File imageFile) async {
  try {

    final url = Uri.parse(
      "https://matheon.online/haweel/public/api/upload-image",
    );

    var request = http.MultipartRequest("POST", url)
      ..headers['Accept'] = 'application/json';

    /// التأكد أن الملف موجود
    if (await imageFile.exists()) {

      request.files.add(
        await http.MultipartFile.fromPath("image", imageFile.path),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء اختيار صورة"),
        ),
      );

      return null;
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    /// نجاح الرفع
    if (response.statusCode == 200) {

      var data = jsonDecode(responseData);
      return data["url"];

    } else {

      /// خطأ من السيرفر
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ لم يتم تحميل الصورة حاول مرة أخرى"),
        ),
      );

      return null;
    }

  } catch (e) {

    /// خطأ اتصال أو Exception
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("حدث خطأ لم يتم تحميل الصورة حاول مرة أخرى"),
      ),
    );

    return null;
  }
}

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    _image = File(picked.path);

    // await updateUserImage(_image!, uid);

    setState(() => isUploading = true);
    await updateUserImage(_image!, uid);
    setState(() => isUploading = false);

    setState(() {
      userFuture = UserService().getUser(uid);
    });
  }

  Future<void> updateUserImage(File imageFile, String userId) async {
    String? imageUrl = await uploadImage(imageFile);

    print("image url is : $imageUrl");

    if (imageUrl == null) return;

    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "image": imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("لم يتم العثور على بيانات المستخدم"));
        }

        final user = snapshot.data!;

        Future<void> showEditUserDialog(
          BuildContext context,
          UserModel user,
        ) async {
          final nameController = TextEditingController(text: user.name);
          final emailController = TextEditingController(text: user.email);
          final addressController = TextEditingController(text: user.address);
          final cityController = TextEditingController(text: user.city);
          final licenseController = TextEditingController(text: user.license);
          final licenseExpireController = TextEditingController(
            text: user.licenseExpireDate,
          );

          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,

                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.grey)],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    FluentIcons.person_24_regular,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 16),
                      
                                Center(
                                  child: Text(
                                    "تحديث بيانات المستخدم",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Spacer(),
                                // IconButton(
                                //   onPressed: () {
                                //     Navigator.pop(context);
                                //   },
                                //   icon: Icon(Icons.cancel_outlined),
                                // ),
                              ],
                            ),
                          ),
                      
                          Padding(
                            padding: EdgeInsetsGeometry.all(16),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                      
                                Input(
                                  controller: nameController,
                                  label: "الاسم",
                                  icon: FluentIcons.person_24_regular,
                                  iconColor: AppColors.primary,
                                  borderColor: Colors.redAccent,
                                ),
                                SizedBox(height: 20),
                                Input(
                                  controller: emailController,
                                  label: "البريد",
                                  icon: FluentIcons.mail_24_regular,
                                  iconColor: AppColors.primary,
                                  borderColor: Colors.redAccent,
                                ),
                                SizedBox(height: 20),
                                Input(
                                  controller: cityController,
                                  label: "المدينة",
                                  icon: FluentIcons.city_24_regular,
                                  iconColor: AppColors.primary,
                                  borderColor: Colors.redAccent,
                                ),
                                SizedBox(height: 20),
                                Input(
                                  controller: addressController,
                                  label: "العنوان",
                                  icon: FluentIcons.pin_24_filled,
                                  iconColor: AppColors.primary,
                                  borderColor: Colors.redAccent,
                                ),
                                SizedBox(height: 20),
                                Input(
                                  controller: licenseController,
                                  label: "رقم الرخصة",
                                  icon: FluentIcons.certificate_24_regular,
                                  iconColor: AppColors.primary,
                                  borderColor: Colors.redAccent,
                                ),
                                SizedBox(height: 20),
                                Input(
                                  controller: licenseExpireController,
                                  label: "تاريخ انتهاء الرخصة",
                                  icon: FluentIcons.calculator_24_regular,
                                  iconColor: AppColors.primary,
                                  borderColor: Colors.redAccent,
                                  type: "date",
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                      
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.grey)],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(user.uid)
                                          .update({
                                            "name": nameController.text,
                                            "email": emailController.text,
                                            "address": addressController.text,
                                            "city": cityController.text,
                                            "license": licenseController.text,
                                            "license_export_date":
                                                licenseExpireController.text,
                                          });
                      
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      setState(() {
                                        userFuture = UserService().getUser(uid);
                                      });
                                    },
                      
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text("تحديث"),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                      
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.background,
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text("الغاء"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.roundBackground,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back_ios_new),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),

                              Spacer(),
                              Text(
                                "الملف الشخصي",
                                style: TextStyle(fontSize: 24),
                              ),
                              Spacer(),

                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.roundBackground,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(FluentIcons.edit_24_regular),
                                  onPressed: () async {
                                    await showEditUserDialog(context, user);
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.roundBackground,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.logout),
                                  onPressed: () async {

                                    showDialog(context: context, builder: (context){
                                      return AlertDialog(
                                        title: const Text("تسجيل الخروج"),
                                        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("الغاء"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await AuthService().logout();

                                              if (!context.mounted) return;

                                              Navigator.pop(context);
                                            },
                                            child: const Text("تأكيد"),
                                          ),
                                        ],
                                      );
                                    });
                                 
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              SizedBox(
                                width: 120,
                                child: Stack(
                                  alignment: AlignmentGeometry.bottomCenter,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await pickImage();
                                      },
                                      child: CircleAvatar(
                                        radius: 64,
                                        backgroundImage: NetworkImage(
                                          user.image!,
                                        ),
                                      ),
                                    ),

                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: user.membership == 0
                                          ? Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.roundBackground,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(100),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.new_releases,
                                                size: 32,
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : user.membership == 1
                                          ? Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(100),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.bolt,
                                                size: 32,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  128,
                                                  55,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(100),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.verified,
                                                size: 32,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  174,
                                                  0,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                user.name,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),

                              SizedBox(height: 30),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("contracts")
                                        .where("uid", isEqualTo: uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return _statCard(
                                          "العقود المنشورة",
                                          "...",
                                        );
                                      }

                                      final count = snapshot.data!.docs.length;

                                      return _statCard(
                                        "العقود المنشورة",
                                        count.toString(),
                                      );
                                    },
                                  ),

                                  SizedBox(width: 20),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("contracts")
                                        .where("uid", isEqualTo: uid)
                                        .where("status", isEqualTo: 3)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return _statCard(
                                          "العقود المنجزة",
                                          "...",
                                        );
                                      }

                                      final count = snapshot.data!.docs.length;

                                      return _statCard(
                                        "العقود المنجزة",
                                        count.toString(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),

                              SizedBox(
                                width: 500,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 20),
                                
                                    const SizedBox(height: 12),
                                
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          122,
                                          234,
                                          225,
                                          248,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              124,
                                              195,
                                              152,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            FluentIcons.city_24_regular,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          "البريد الالكتروني ",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          user.email,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          122,
                                          234,
                                          225,
                                          248,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              124,
                                              195,
                                              152,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            FluentIcons.city_24_regular,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          "المدينة ",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          user.city,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          122,
                                          234,
                                          225,
                                          248,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              124,
                                              195,
                                              152,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            FluentIcons.city_24_regular,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          "العنوان ",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          user.address,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          122,
                                          234,
                                          225,
                                          248,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              124,
                                              195,
                                              152,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            FluentIcons.certificate_24_regular,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          "رقم الرخصة",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                
                                        subtitle: Text(
                                          user.license,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          122,
                                          234,
                                          225,
                                          248,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              124,
                                              195,
                                              152,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            FluentIcons.calculator_24_regular,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          "تاريخ الانتهاء",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                
                                        subtitle: Text(
                                          user.licenseExpireDate,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isUploading)
                Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white,)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 12,
            offset: const Offset(-4, -4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
