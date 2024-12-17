import 'package:flutter/material.dart';
import 'package:pks_sem5_p8/models/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  void register() async {
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final name = nameController.text;
    if (password != confirmPassword) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Ошибка"),
              content: Text("Пароли не совпадают"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ясно"))
              ],
            );
          });
      return;
    }
    try {
      AuthResponse response = await authService.Register(email, password, name);
      // final user = response.user;
      // // if (user != null) {
      // //     await Supabase.instance.client.from('profiles').insert({"id": user.id, "name": name});
      // // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Ошибка: $e")));
      }
    }
    ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Регистрация успешна! Войдите в аккаунт")));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Регистрация"),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(label: Text("Имя")),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(label: Text("Эл. почта")),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(label: Text("Пароль")),
            obscureText: true,
          ),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(label: Text("Пароль (повторите)")),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () {
              register();
            },
            child: Text("Зарегистрироваться"),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
