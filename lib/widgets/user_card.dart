import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/user_model.dart';
import 'package:haweel/services/user_service.dart';

class UserCard extends StatefulWidget {
  final String title;
  final uid;
  const UserCard( {super.key, this.uid , this.title = ""});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late Future<UserModel?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UserService().getUser(widget.uid);
    
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: FutureBuilder<UserModel?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData) {
            return SizedBox();
          }

          final user = snapshot.data!;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 245, 237, 255),
                  ),
                  child: ListTile(
                    leading: user.image != null ? CircleAvatar(
                      backgroundImage: NetworkImage(user.image!),
                    ):Container(),

                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    trailing: user.membership == 0
                        ? Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.roundBackground,
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
                              color: Color.fromARGB(59, 255, 128, 55),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: Icon(
                              Icons.bolt,
                              size: 32,
                              color: const Color.fromARGB(255, 255, 128, 55),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(97, 255, 208, 55),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: Icon(
                              Icons.verified,
                              size: 32,
                              color: const Color.fromARGB(255, 255, 174, 0),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
