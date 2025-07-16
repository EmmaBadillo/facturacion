import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  const RegisterScreen({Key? key, required this.onRegisterSuccess}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      await UserService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cedula: _cedulaController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      setState(() {
        _success = 'Usuario registrado correctamente. Puede iniciar sesión ahora.';
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onRegisterSuccess();
        }
      });
    } catch (e) {
      String errorMsg = e.toString();
      final RegExp errorRegExp = RegExp(r'''{['"]?(error|Error|ERROR)['"]?\s*:\s*['"]?([^'"}]+)['"]?}''');
      final match = errorRegExp.firstMatch(errorMsg);
      if (match != null && match.groupCount >= 2) {
        errorMsg = match.group(2)!;
      }
      setState(() {
        _error = errorMsg;
      });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // Validación de cédula ecuatoriana
  String? validateEcuadorianCedula(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese la cédula';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'La cédula debe tener 10 dígitos';
    final province = int.tryParse(value.substring(0, 2));
    final thirdDigit = int.tryParse(value.substring(2, 3));
    if (province == null || province < 1 || province > 24) return 'Provincia inválida en la cédula';
    if (thirdDigit == null || thirdDigit > 6) return 'Tercer dígito inválido en la cédula';
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(value[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    int verifier = int.parse(value[9]);
    int expected = (sum % 10 == 0) ? 0 : 10 - (sum % 10);
    if (verifier != expected) return 'Cédula ecuatoriana inválida';
    return null;
  }

  // Validación de teléfono ecuatoriano
  String? validateEcuadorianPhone(String? value) {
    if (value == null || value.isEmpty) return null; // Opcional
    if (!RegExp(r'^09\d{8}$').hasMatch(value)) return 'Teléfono ecuatoriano inválido (debe iniciar con 09 y tener 10 dígitos)';
    return null;
  }

  // Validación de nombres/apellidos (solo letras y espacios)
  String? validateName(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) return 'Ingrese $fieldName';
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) return '$fieldName solo debe contener letras';
    return null;
  }

  // Validación de contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese la contraseña';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    if (value.length > 10) return 'La contraseña no debe superar los 10 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe tener al menos una letra mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Debe tener al menos una letra minúscula';
    if (!RegExp(r'[!@#\$&*~_\-.,;:?¿¡]').hasMatch(value)) return 'Debe tener al menos un carácter especial';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Modern color palette based on CSS variables
    const Color primaryColor = Color(0xFF1e40af); // --primary
    const Color primaryHover = Color(0xFF1d4ed8); // --primary-hover
    const Color accentColor = Color(0xFF059669); // --accent
    const Color backgroundColor = Color(0xFFf8fafc); // --bg-main
    const Color cardColor = Color(0xFFffffff); // --bg-card
    const Color textPrimary = Color(0xFF0f172a); // --text-primary
    const Color textSecondary = Color(0xFF475569); // --text-secondary
    const Color borderColor = Color(0xFFe2e8f0); // --border
    const Color errorColor = Color(0xFFef4444); // --error

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_outlined,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Crear nueva cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Complete sus datos para registrarse',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Form fields
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Mín. 6 caracteres',
                      prefixIcon: Icon(Icons.lock_outlined, color: primaryColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cedulaController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Cédula',
                      hintText: '0123456789',
                      prefixIcon: Icon(Icons.badge_outlined, color: primaryColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    validator: validateEcuadorianCedula,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nombres',
                      hintText: 'Juan Carlos',
                      prefixIcon: Icon(Icons.person_outlined, color: primaryColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => validateName(value, fieldName: 'los nombres'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Apellidos',
                      hintText: 'Pérez González',
                      prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => validateName(value, fieldName: 'los apellidos'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Dirección (opcional)',
                      hintText: 'Av. Siempre Viva 742',
                      prefixIcon: Icon(Icons.home_outlined, color: primaryColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLines: 2,
                    validator: (value) => Validators.address(value, isRequired: false),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Teléfono (opcional)',
                      hintText: '0987654321',
                      prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: validateEcuadorianPhone,
                  ),
                  const SizedBox(height: 24),
                  // Mensajes
                  if (_error != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: errorColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: errorColor, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_success != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, 
                               color: accentColor, 
                               size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _success!,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Botón
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              ),
                            )
                          : const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
