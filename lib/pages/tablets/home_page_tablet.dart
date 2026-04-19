import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/pages/tablets/profile_page.dart';
import 'package:haweel/providers/contract_provider.dart';
import 'package:haweel/widgets/bottom_navigation_bar_tablet.dart';
import 'package:haweel/widgets/notifications_icon.dart';
import 'package:haweel/widgets/project_card_widget_tablet.dart';

class HomePageTablet extends StatefulWidget {
  const HomePageTablet({super.key});

  @override
  State<HomePageTablet> createState() => _HomePageTabletState();
}

class _HomePageTabletState extends State<HomePageTablet> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(message.data);
      // final type = message.data["type"];
      // final id = message.data["id"];

      // if (type == "message") {
      //    Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => ContractChatPage(
      //               contract: widget.contract,
      //             ),
      //           ),
      //         );
      // }

      // if (type == "contract") {
      //   Navigator.pushNamed(context, "/contract", arguments: id);
      // }
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: buildBottomBarTablet(context, userId),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(user?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            final image = data["image"] ?? '';

                            return GestureDetector(
                              onTap: () => _navigateToProfile(),
                              child: Column(
                                children: [
                                  if (image.isNotEmpty)
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.roundBackground,
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  if (image.isEmpty)
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.roundBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        FluentIcons.person_24_regular,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        Spacer(),
                        Image.asset("assets/imgs/logo.png", height: 120),
                        Spacer(),
                        NotificationsIcon(context, userId),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 500,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("app_banner")
                          .doc("main")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const SizedBox();
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;

                        if (data == null) {
                          return const SizedBox();
                        }

                        final image = data["image"] ?? "";
                        final enabled = data["enabled"] ?? false;

                        if (!enabled || image.isEmpty) {
                          return const SizedBox();
                        }

                        return Container(
                          height: 205,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(image),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Container(
                  //   height: 205,
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //       image: AssetImage("assets/imgs/add.png"),
                  //       fit: BoxFit.fitWidth,
                  //     ),
                  //   ),
                  // ),
                  Row(
                    children: [
                      Text(
                        "اخر العقود المنشورة",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final contracts = ref.watch(contractsProvider);

                        return contracts.when(
                          data: (data) {
                            // لا توجد عقود
                            if (data.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 70,
                                      color: Colors.grey.shade400,
                                    ),

                                    const SizedBox(height: 16),

                                    Text(
                                      "لا توجد عقود",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      "اضغط على زر + لإضافة أول عقد",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // عرض العقود
                            return SizedBox(
                              width: 500,
                              child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final contract = data[index];

                                  return ProjectCardWidgetTablet(
                                    context,
                                    contract: contract,
                                    currentUserId: userId,
                                  );
                                },
                              ),
                            );
                          },

                          // أثناء التحميل
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),

                          // في حال وجود خطأ
                          error: (e, _) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red.shade300,
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  "حدث خطأ أثناء تحميل العقود",
                                  style: TextStyle(fontSize: 16),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  e.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
