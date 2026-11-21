import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  @override
  void dispose() {

    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> registrarUsuario() async {
  final mensaje = authService.validarRegistro(
    nombre: nombreController.text.trim(),
    correo: correoController.text.trim(),
    password: passwordController.text,
    confirmarpassword: passwordController.text,
  );

  if (mensaje != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFE74C3C),
        content: Text(mensaje),
      ),
    );
    return;
  }

  try {
    // Petición a la API por medio del servicio
    await authService.registrarUsuario(
      nombre: nombreController.text.trim(),
      correo: correoController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario ${nombreController.text} registrado en la base de datos'),
        backgroundColor: const Color(0xFF18BC9C),
      ),
    );

    // Regresar a la pantalla anterior o reiniciar formulario
    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: const Color(0xFFE74C3C),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      body: AuthBackground(

        child: Center(

          child: AuthCard(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(
                  Icons.person_add,
                  size: 65,
                  color:
                      Color(0xFF18BC9C),
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'CREAR CUENTA',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                CustomTextField(
                  controller:
                      nombreController,

                  label:
                      'Nombre completo',

                  prefixIcon:
                      Icons.person,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      correoController,

                  label:
                      'Correo electrónico',

                  prefixIcon:
                      Icons.email,

                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      passwordController,

                  label:
                      'Contraseña',

                  prefixIcon:
                      Icons.lock,

                  obscureText: true,
                ),

                const SizedBox(
                  height: 25,
                ),

                PrimaryButton(
                  text: 'REGISTRARME',
                  onPressed:
                      registrarUsuario,
                ),

                const SizedBox(
                  height: 15,
                ),

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF18BC9C),
                  ),

                  child: const Text(
                    'Ya tengo una cuenta',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}