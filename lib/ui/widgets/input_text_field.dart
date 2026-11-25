import 'package:material_ui/material_ui.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final bool readOnly;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final void Function(String?)? onSaved;
  final VoidCallback? onTap;
  final String? hintText;
  final Widget? suffixIcon;

  const CustomTextField({
    required this.label,
    this.isPassword = false,
    this.readOnly = false,
    this.keyboardType,
    this.controller,
    this.validator,
    this.onSaved,
    this.onTap,
    this.hintText,
    this.suffixIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
