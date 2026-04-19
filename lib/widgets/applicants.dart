import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/models/user_model.dart';
import 'package:haweel/providers/applicants_provider.dart';
import 'package:haweel/services/user_service.dart';
import 'package:haweel/widgets/applicant_dialog.dart';

class Applicants extends StatefulWidget {
  final ContractModel contract;
  const Applicants({super.key, required this.contract});

  @override
  State<Applicants> createState() => _ApplicantsState();
}

class _ApplicantsState extends State<Applicants> {

   final userId =  FirebaseAuth.instance.currentUser!.uid;
   
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              Text(
                                "المتقدمين",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 10),

                      if (widget.contract.status == 0)
                        Container(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final applicants = ref.watch(
                                applicantsProvider(widget.contract.id),
                              );

                              return applicants.when(
                                data: (data) {
                                  // print("Applicants count: ${data.length}");

                                  if (data.isEmpty) {
                                    return const Text("لا يوجد متقدمون بعد");
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      final applicant = data[index];

                                      return FutureBuilder<UserModel?>(
                                        future: UserService().getUser(
                                          applicant.userId,
                                        ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const ListTile(
                                              title: Text("جاري التحميل"),
                                            );
                                          }

                                          final user = snapshot.data!;

                                          return Card(
                                            elevation: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: const Color.fromARGB(
                                                  255,
                                                  244,
                                                  236,
                                                  255,
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    user.image!,
                                                  ),
                                                ),

                                                title: Text(user.name),

                                                subtitle: Text(user.city),

                                                trailing: user.membership == 0
                                                    ? Container(
                                                        padding: EdgeInsets.all(
                                                          8,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .roundBackground,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  100,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.new_releases,
                                                          size: 32,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      )
                                                    : user.membership == 1
                                                    ? Container(
                                                        padding: EdgeInsets.all(
                                                          8,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Color.fromARGB(
                                                            59,
                                                            255,
                                                            128,
                                                            55,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  100,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.bolt,
                                                          size: 32,
                                                          color:
                                                              const Color.fromARGB(
                                                                255,
                                                                255,
                                                                128,
                                                                55,
                                                              ),
                                                        ),
                                                      )
                                                    : Container(
                                                        padding: EdgeInsets.all(
                                                          8,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Color.fromARGB(
                                                            97,
                                                            255,
                                                            208,
                                                            55,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  100,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.verified,
                                                          size: 32,
                                                          color:
                                                              const Color.fromARGB(
                                                                255,
                                                                255,
                                                                174,
                                                                0,
                                                              ),
                                                        ),
                                                      ),

                                                onTap: () {
                                                  if(userId == widget.contract.uid){

                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                      
                                                          ApplicantDialog(
                                                            applicant: applicant,
                                                            contractId: widget.contract.id,
                                                          ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },

                                loading: () => CircularProgressIndicator(),

                                error: (e, _) => Text(e.toString()),
                              );
                            },
                          ),
                        ),

                      
      ],
    );
  }
}