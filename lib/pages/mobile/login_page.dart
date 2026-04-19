import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/pages/tablets/register_page.dart';
import 'package:haweel/services/auth_service.dart';
import 'package:haweel/widgets/input.dart';

enum SignUpMethod { email, google }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool tringToLogin = false;
  bool isErrorMessage = false;
  late String message = "تسجيل الدخول";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imgs/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Image.asset("assets/imgs/logo.png", width: 200),

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
                          message,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  SizedBox(height: 40),
                  Input(
                    controller: emailController,
                    label: "البريد الالكتروني",
                    icon: FluentIcons.mail_24_regular,
                    iconColor: AppColors.primary,
                    borderColor: const Color.fromARGB(255, 241, 130, 122),
                    isScure: false,
                  ),
                  SizedBox(height: 20),
                  Input(
                    controller: passwordController,
                    label: "كلمة المرور",
                    icon: FluentIcons.password_24_regular,
                    iconColor: AppColors.primary,
                    borderColor: const Color.fromARGB(255, 241, 130, 122),
                    isScure: true,
                  ),

                  SizedBox(height: 40),
                  !tringToLogin
                      ? SizedBox(
                          width: 400,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                tringToLogin = true;
                              });
                              try {
                                await AuthService().login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                                tringToLogin = false;

                                print("تم تسجيل الدخول بنجاح");
                              } on FirebaseAuthException catch (e) {
                                tringToLogin = false;
                                isErrorMessage = true;
                                print("خطاء ${e.code}");
                                switch (e.code) {
                                  case 'user-not-found':
                                    setState(() {
                                      message = "البريد الإلكتروني غير مسجل";
                                    });
                                    break;

                                  case 'wrong-password':
                                    setState(() {
                                      message = "كلمة المرور غير صحيحة";
                                    });
                                    break;
                                  case 'invalid-email':
                                    setState(() {
                                      message =
                                          "صيغة البريد الإلكتروني غير صحيحة";
                                    });
                                    break;

                                  case 'user-disabled':
                                    setState(() {
                                      message = "تم تعطيل هذا الحساب";
                                    });
                                    break;

                                  case 'too-many-requests':
                                    setState(() {
                                      message = "محاولات كثيرة، حاول لاحقًا";
                                    });
                                    break;

                                  default:
                                    setState(() {
                                      message = "حدث خطأ غير متوقع";
                                    });
                                }

                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(content: Text(message)),
                                // );
                              } catch (e) {
                                isErrorMessage = true;
                                tringToLogin = false;
                                setState(() {
                                  Text("حدث خطأ غير متوقع");
                                });
                              }
                            },
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
                              "دخول",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 400,
                          child: ElevatedButton(
                            onPressed: () async {
                              // tringToLogin = false;
                              // try {
                              //   await AuthService().login(
                              //     email: emailController.text.trim(),
                              //     password: passwordController.text.trim(),
                              //   );

                              //   print("تم تسجيل الدخول بنجاح");
                              // } catch (e) {
                              //   print("خطأ: $e");
                              // }
                            },
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
                              color: Colors.white,
                            ),
                          ),
                        ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
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
                        "انشاء حساب",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  TextButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty) {
                        setState(() {
                          isErrorMessage = true;
                          message = "ادخل البريد الالكتروني اولا";
                        });
                        return;
                      }

                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailController.text.trim(),
                        );

                        setState(() {
                          isErrorMessage = false;
                          message =
                              "تم ارسال رابط استعادة كلمة المرور إلى بريدك";
                        });
                      } on FirebaseAuthException {
                        setState(() {
                          isErrorMessage = true;
                          message = "حدث خطأ أثناء ارسال الرابط";
                        });
                      }
                    },
                    child: Text(
                      "استعادة كلمة المرور",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "وسيلة دخول اخري",
                    style: TextStyle(color: AppColors.primary),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            await AuthService().signInWithGoogle();
                          } catch (e) {
                    
                            print(e);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.roundBackground,
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: Image.asset("assets/imgs/google.png"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
