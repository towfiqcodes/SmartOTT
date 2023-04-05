import 'package:assignment/core/modules/auth/provider/auth_provider.dart';
import 'package:assignment/core/modules/auth/view/login.dart';
import 'package:assignment/core/modules/home/view/home_screen.dart';
import 'package:assignment/utils/smart_prefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'core/modules/home/provider/home_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('SmartOTTPrefs');
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var smartPrefs = SmartPrefs();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: smartPrefs.isLogin ? const HomeScreen() : const Login(),
      ),
    );
  }
}
