import 'dart:convert';

import 'package:assignment/core/modules/auth/view/login.dart';
import 'package:assignment/core/modules/home/view/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_login/linkedin_login.dart';

import '../../../../utils/constants.dart';
import '../../../../utils/smart_prefs.dart';
import '../../../components/routing/slide_routing_transition.dart';

class AuthProvider extends ChangeNotifier {
  var smartPrefs = SmartPrefs();
  FacebookLogin facebookLogin = FacebookLogin();

  Future<UserCredential> signInWithGoogle() async {
    // trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();

    // obtain the auth details from request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // create a new credential
    final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    // once signed in, return the user credential
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    print("login with fb running");
    final FacebookLoginResult result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    print("--->>>>> ${result.status.toString()}");
    switch (result.status) {
      case FacebookLoginStatus.cancel:
        print("--->>>>error msg ${result.error}");

        break;
      case FacebookLoginStatus.error:
        print("--->>>>error msg ${result.error}");
        break;
      case FacebookLoginStatus.success:
        try {
          final FacebookAccessToken? accessToken = result.accessToken;
          final graphResponse = await http.get(Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=email,name,picture&access_token=${accessToken?.token}'));
          final profile = jsonDecode(graphResponse.body);
          print("---->> profile $profile");
          await loginWithFacebook(result, context);
        } catch (e) {
          print(e);
        }
        break;
    }
  }

  Future<void> signInWithLinkedIn(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (final BuildContext context) => LinkedInUserWidget(
          appBar: AppBar(
            title: const Text('OAuth User'),
          ),
          destroySession: smartPrefs.isLogin,
          redirectUrl: redirectUrl,
          clientId: clientId,
          clientSecret: clientSecret,
          projection: const [
            ProjectionParameters.id,
            ProjectionParameters.localizedFirstName,
            ProjectionParameters.localizedLastName,
            ProjectionParameters.firstName,
            ProjectionParameters.lastName,
            ProjectionParameters.profilePicture,
          ],
          onError: (final UserFailedAction e) {
            print('Error: ${e.toString()}');
            print('Error: ${e.stackTrace.toString()}');
          },
          onGetUserProfile: (final UserSucceededAction linkedInUser) {
            print(
              'Access token ${linkedInUser.user.token.accessToken}',
            );

            print('User id: ${linkedInUser.user.userId}');
            addLinkedInUserToDb(linkedInUser.user, context);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> addLinkedInUserToDb(
      LinkedInUserModel? user, BuildContext context) async {
    if (user != null) {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: user.userId)
          .get();
      List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;

      if (documentSnapshot.isEmpty) {
        FirebaseFirestore.instance.collection("users").doc(user.userId).set({
          "id": user.userId,
          "name": "${user.localizedFirstName} ${user.localizedLastName}",
          "email": user.email?.elements![0].handleDeep?.emailAddress,
          "photo": user.profilePicture?.displayImageContent?.elements![0]
              .identifiers![0].identifier,
        });
        smartPrefs.setUserId("${user.userId}");
        smartPrefs.setFullName(
            "${user.localizedFirstName} ${user.localizedLastName}");
        smartPrefs.setUserEmail(
            "${user.email?.elements![0].handleDeep?.emailAddress}");
        smartPrefs.setImageUrl(
            "${user.profilePicture?.displayImageContent?.elements![0].identifiers![0].identifier}");
        smartPrefs.setIsLogin(true);
        Navigator.pushReplacement(
          context,
          SlideRightRoute(widget: HomeScreen()),
        );
      } else {
        smartPrefs.setUserId(documentSnapshot[0]["id"]);
        smartPrefs.setFullName(documentSnapshot[0]["name"] ?? '');
        smartPrefs.setUserEmail(documentSnapshot[0]["email"] ?? '');
        smartPrefs.setImageUrl(documentSnapshot[0]["photo"] ?? '');
        smartPrefs.setIsLogin(true);
        Navigator.pushReplacement(
          context,
          SlideRightRoute(widget: HomeScreen()),
        );
      }
    } else {
      print("Please Check your internet Connection");
    }
  }

  Future loginWithFacebook(
      FacebookLoginResult result, BuildContext context) async {
    final FacebookAccessToken? accessToken = result.accessToken;
    print(" ---->>> user IDDD--->>  ${accessToken?.userId}");

    AuthCredential credential =
        FacebookAuthProvider.credential(accessToken!.token);
    print(" ---->>> user credential IDDD--->>  ${credential.providerId}");

    User? user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    await addUserToDb(user, context);
  }

  Future<void> addUserToDb(User? user, BuildContext context) async {
    if (user != null) {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: user.uid)
          .get();
      List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;

      if (documentSnapshot.isEmpty) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "id": user.uid,
          "name": user.displayName,
          "email": user.email,
          "photo": user.photoURL,
        });
        smartPrefs.setUserId(user.uid);
        smartPrefs.setFullName(user.displayName!);
        smartPrefs.setUserEmail(user.email!);
        smartPrefs.setImageUrl(user.photoURL!);
        smartPrefs.setIsLogin(true);
        Navigator.pushAndRemoveUntil(
            context,
            SlideRightRoute(widget: HomeScreen()),
            (Route<dynamic> route) => false);
      } else {
        smartPrefs.setUserId(documentSnapshot[0]["id"]);
        smartPrefs.setFullName(documentSnapshot[0]["name"] ?? '');
        smartPrefs.setUserEmail(documentSnapshot[0]["email"] ?? '');
        smartPrefs.setImageUrl(documentSnapshot[0]["photo"] ?? '');
        smartPrefs.setIsLogin(true);
        Navigator.pushAndRemoveUntil(
            context,
            SlideRightRoute(widget: HomeScreen()),
            (Route<dynamic> route) => false);
      }
    } else {
      print("Please Check your internet Connection");
    }
  }

  signOutFromGoogleAcc(context) async {
    // google sign out
    GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
    smartPrefs.clear();
    Navigator.pushAndRemoveUntil(
        context,
        SlideRightRoute(widget: const Login()),
        (Route<dynamic> route) => false);
    debugPrint("google sign out");
  }
}
