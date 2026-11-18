import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/login_user_page.dart';
import 'package:flutter_application_2/screen/register_user_page.dart';
import 'package:flutter_application_2/screen/user_page.dart';
import 'package:flutter_application_2/screen/contrasena_user.dart';
import 'package:flutter_application_2/screen/blog_page.dart';
import 'package:flutter_application_2/screen/add_blog_page.dart';
import 'package:flutter_application_2/screen/profile_page.dart';
import 'package:flutter_application_2/screen/mapa_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi aplicacion',
      initialRoute: '/login',
      routes: {
        '/blog':(context) => const BlogPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/users': (context) => const UsersPage(),
        '/recover-password': (context) => const RecoverPasswordPage(),
        '/add_blog':(context) => const AddBlogPage(),
        '/profile':(context) => const ProfilePage(),
        '/mapa':(context) => const MapaPage(),
      },
    );
  }
}