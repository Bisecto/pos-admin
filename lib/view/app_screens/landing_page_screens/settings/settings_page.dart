import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../res/app_colors.dart';
import '../../../../utills/app_validator.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../widgets/form_button.dart';
import '../../../widgets/form_input.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to update the password
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          await user.updatePassword(_passwordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully!')),
          );
          _passwordController.clear();
          _confirmPasswordController.clear();
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkModeBackgroundContainerColor,
      // appBar: AppBar(
      //   title: const Text('Change Password'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextStyles.textHeadings(textValue: 'Change password'),
                SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                  label: 'New Password',
                  isPasswordField: true,
                  borderColor: AppColors.canvasColor,
                  backgroundColor: AppColors.darkModeBackgroundContainerColor,
                  validator: AppValidator.validateTextfield,
                  // Use your own validation logic
                  controller: _passwordController,
                  hint: 'Enter new password',
                  widget: Icon(Icons.lock_outline),
                  width: 250,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  label: 'Confirm Password',
                  isPasswordField: true,
                  borderColor: AppColors.canvasColor,
                  backgroundColor: AppColors.darkModeBackgroundContainerColor,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  controller: _confirmPasswordController,
                  hint: 'Confirm new password',
                  widget: Icon(Icons.lock_outline),
                  width: 250,
                ),
                const SizedBox(height: 16),
                FormButton(
                  onPressed: _changePassword,
                  text: 'Change Password',
                  borderColor: AppColors.canvasColor,
                  bgColor: AppColors.canvasColor,
                  textColor: AppColors.white,
                  borderRadius: 10,
                  width: 250,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
