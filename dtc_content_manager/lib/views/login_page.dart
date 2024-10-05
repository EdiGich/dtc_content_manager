// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/login_controller.dart';

// class LoginPage extends StatelessWidget {
//   final LoginController loginController = Get.put(LoginController());

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Obx(() {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 controller: passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                 ),
//                 obscureText: true,
//               ),
//               SizedBox(height: 32),
//               loginController.isLoading.value
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: () {
//                         final username = emailController.text.trim();
//                         final password = passwordController.text.trim();
//                         if (username.isNotEmpty && password.isNotEmpty) {
//                           loginController.login(username, password);
//                         } else {
//                           Get.snackbar(
//                             'Error',
//                             'Please enter both username and password',
//                             snackPosition: SnackPosition.BOTTOM,
//                           );
//                         }
//                       },
//                       child: Text('Login'),
//                     ),
//               SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   // Handle forgot password
//                 },
//                 child: Text('Forgot Password?'),
//               ),
//               SizedBox(height: 16),
//               loginController.errorMessage.value.isNotEmpty
//                   ? Text(
//                       loginController.errorMessage.value,
//                       style: TextStyle(color: Colors.red),
//                     )
//                   : SizedBox(),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }

// ---------------------------------------------------------------

// lib/pages/login_page.dart

// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtc_content_manager/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => loginController.username.value = value,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) => loginController.password.value = value,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Obx(() => loginController.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => loginController.login(),
                    child: Text('Login'),
                  )),
          ],
        ),
      ),
    );
  }
}
