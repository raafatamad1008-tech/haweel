// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/providers/auth_providers.dart';
import 'package:haweel/providers/message_provider.dart';
import 'package:haweel/widgets/chat_input.dart';

class ContractChatPage extends ConsumerWidget {
  final ContractModel contract;

  const ContractChatPage({super.key, required this.contract});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(contract.id));
    final currentUserAsync = ref.watch(currentUserDataProvider);

    
    // final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.roundBackground,
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
SizedBox(width: 20,),
                    Text("المراسلة", style: TextStyle(fontSize: 24)),
                    Spacer(),

                    // Container(
                    //       decoration: BoxDecoration(
                    //         color: AppColors.roundBackground,
                    //         borderRadius: BorderRadius.all(
                    //           Radius.circular(100),
                    //         ),
                    //       ),
                    //       child: Stack(
                    //         children: [
                    //           IconButton(
                    //             icon: Icon(FluentIcons.alert_24_regular),
                    //             onPressed: () {
                    //               Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                   builder: (context) => NotificationsPage(),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //           StreamBuilder<QuerySnapshot>(
                    //             stream: FirebaseFirestore.instance
                    //                 .collection("notifications_log")
                    //                 .where(
                    //                   Filter.or(
                    //                     Filter("user_id", isEqualTo: userId),
                    //                     Filter("is_global", isEqualTo: true),
                    //                   ),
                    //                 )
                    //                 .where("is_read", isEqualTo: false)
                    //                 .snapshots(),
                    //             builder: (context, snapshot) {
                    //               if (!snapshot.hasData)
                    //                 return const SizedBox();

                    //               int count = snapshot.data!.docs.length;

                    //               print(count);

                    //               if (count == 0) return const SizedBox();

                    //               return Container(
                    //                 padding: const EdgeInsets.all(6),
                    //                 decoration: const BoxDecoration(
                    //                   color: Colors.red,
                    //                   shape: BoxShape.circle,
                    //                 ),
                    //                 child: Text(
                    //                   count.toString(),
                    //                   style: const TextStyle(
                    //                     color: Colors.white,
                    //                   ),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Expanded(

              child: Container(
                padding: EdgeInsets.symmetric(horizontal:  16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 244, 230, 255),
                ),
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
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
                                    "لا توجد رسائل",
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
            
                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                      
                          return Container(
                            padding: EdgeInsets.all(2),
                            margin: EdgeInsets.only(bottom:  10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400
                                )
                              ]
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(msg.senderImage),
                              ),
                              title: Text(msg.senderName),
                              subtitle: Text(msg.text),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(e.toString()),
                ),
              ),
            ),

            currentUserAsync.when(
              data: (user) {

                if (user == null) {
                  return const SizedBox();
                }

                

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal:  16.0),
                  child: ChatInput(
                    contractId: contract.id,
                    senderId: user.uid,
                    senderName: user.name,
                    senderImage: user.image!,
                    receiverId: contract.executorId,
                    contract: contract,
                  ),
                );
              },

              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),

              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
