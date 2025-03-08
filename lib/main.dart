import 'package:fin_wise/pages/title.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fin_wise/services/socials_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  SystemChannels.textInput.invokeMethod('TextInput.hide');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(),
        ),
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
