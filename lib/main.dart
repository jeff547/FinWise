import 'package:fin_wise/pages/title.dart';
import 'package:fin_wise/services/db.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fin_wise/services/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();

  SystemChannels.textInput.invokeMethod('TextInput.hide');

  Get.put(UserRepository());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (context) => AuthService()),
        ChangeNotifierProvider<FinancialsProvider>(
            create: (context) => FinancialsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinWise',
      home: TitlePage(),
    );
  }
}
