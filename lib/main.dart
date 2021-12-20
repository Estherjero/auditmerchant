import 'package:auditmerchant/providers/auth_provider.dart';
import 'package:auditmerchant/providers/merchant_provider.dart';
import 'package:auditmerchant/widgets/form_screen.dart';
import 'package:auditmerchant/widgets/list_screen.dart';
import 'package:auditmerchant/widgets/login_screen.dart';
import 'package:auditmerchant/widgets/pattern_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MerchantProvider>(
          create: (_) => MerchantProvider(null),
          update: (ctx, auth, _) => MerchantProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Audit Merchant',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColorLight: Colors.blue.shade50,
          textTheme: TextTheme(
            headline1: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            headline2: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
            headline3: TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            headline4: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
            headline5: TextStyle(
              color: Colors.black,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
            subtitle1: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            subtitle2: TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
            button: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
            bodyText1: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            bodyText2: TextStyle(
              color: Colors.black,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        home: LoginScreen(),
        routes: {
          '/login': (ctx) => LoginScreen(),
          '/list': (ctx) => ListScreen(),
          '/form': (ctx) => FormScreen(),
          '/pattern': (ctx) => PatternScreen(),
        },
      ),
    );
  }
}
