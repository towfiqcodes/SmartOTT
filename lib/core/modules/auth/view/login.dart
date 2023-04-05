import 'package:assignment/core/components/custom_text.dart';
import 'package:assignment/utils/app_assets/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Image.asset(
              AppAssets.loginScreenCoverImg,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const CustomText(
            text: "Login",
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(
            height: 10,
          ),
          const CustomText(
            text: "Get logged in for better experience",
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            height: 55,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OutlinedButton(
              onPressed: () {
                _googleLogin();
              },
              /*style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xffFF5A34)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),*/
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.icGoogle,
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const CustomText(
                      text: "Google",
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const CustomText(
            text: "OR,",
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            height: 55,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signInWithFacebook(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xff4267B2)),
                elevation: MaterialStateProperty.all(1),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.icFacebook,
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const CustomText(
                      text: "Facebook",
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const CustomText(
            text: "OR,",
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            height: 55,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signInWithLinkedIn(context);
                setState(() {});
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xff0A66C2)),
                elevation: MaterialStateProperty.all(1),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.icLinkedin,
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const CustomText(
                      text: "Linkedin",
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _googleLogin() {
    setState(() {
      context.read<AuthProvider>().signInWithGoogle().then((value) async {
        context.read<AuthProvider>().addUserToDb(value.user, context);
      });
    });
  }
}
