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
    // Paleta contable
    const Color primaryBlue = Color(0xFF1A237E); // Azul oscuro
    const Color accentGreen = Color(0xFF43A047); // Verde contable
    const Color lightGray = Color(0xFFF5F5F5);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color borderGray = Color(0xFFB0BEC5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de usuario'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: lightGray,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            color: cardGray,
            shadowColor: borderGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: borderGray, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 22.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 54, color: accentGreen),
                    const SizedBox(height: 16),
                    Text(
                      'Crear nueva cuenta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los campos marcados con * son obligatorios',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico *',
                        hintText: 'ejemplo@correo.com',
                        prefixIcon: Icon(Icons.email_outlined, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderGray),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 12),
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Contraseña *',
                        hintText: 'Mínimo 6, máximo 10 caracteres',
                        prefixIcon: Icon(Icons.lock_outlined, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderGray),
                        ),
                      ),
                      obscureText: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 12),
                    // Cedula
                    TextFormField(
                      controller: _cedulaController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Cédula *',
                        hintText: '0123456789',
                        prefixIcon: Icon(Icons.badge_outlined, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderGray),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      validator: validateEcuadorianCedula,
                    ),
                    const SizedBox(height: 12),
                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Nombres *',
                        hintText: 'Juan Carlos',
                        prefixIcon: Icon(Icons.person_outlined, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderGray),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => validateName(value, fieldName: 'los nombres'),
                    ),
                    const SizedBox(height: 12),
                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Apellidos *',
                        hintText: 'Pérez González',
                        prefixIcon: Icon(Icons.person_outline, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderGray),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => validateName(value, fieldName: 'los apellidos'),
                    ),
                    const SizedBox(height: 12),
                    // Address
                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Dirección (opcional)',
                        hintText: 'Av. Siempre Viva 742',
                        prefixIcon: Icon(Icons.home_outlined, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderGray),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      maxLines: 2,
                      validator: (value) => Validators.address(value, isRequired: false),
                    ),
                    const SizedBox(height: 12),
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Teléfono (opcional)',
                        hintText: '0987654321',
                        prefixIcon: Icon(Icons.phone_outlined, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderGray),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: validateEcuadorianPhone,
                    ),
                    const SizedBox(height: 20),
                    // Mensajes
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_success != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: accentGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _success!,
                                style: TextStyle(
                                  color: accentGreen,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Botón
                    _isLoading
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: accentGreen,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _register,
                              icon: const Icon(Icons.person_add),
                              label: const Text('Registrarse'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
