import 'package:flutter/material.dart';

class LoginTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("تسجيل الدخول", style: TextStyle(fontSize: 32)),
              SizedBox(height: 30),
              TextField(decoration: InputDecoration(labelText: "البريد")),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(labelText: "كلمة المرور"),
                obscureText: true,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("دخول"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}