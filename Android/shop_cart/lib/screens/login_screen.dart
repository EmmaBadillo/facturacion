import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/cart_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final void Function() onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _showPassword = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await UserService.login(_emailController.text, _passwordController.text);
      CartService.resetOrdersEndpoint();
      widget.onLoginSuccess();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      if (errorMessage.contains('Credenciales incorrectas')) {
        errorMessage = 'Email o contraseña incorrectos. Verifica tus datos.';
      } else if (errorMessage.contains('error de red')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
      } else if (errorMessage.contains('Connection failed') || errorMessage.contains('SocketException')) {
        errorMessage = 'No se puede conectar al servidor. Verifica tu conexión a internet.';
      }
      setState(() {
        _error = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modern color palette based on your CSS variables
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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textPrimary), // Add this line for black text
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          hintStyle: TextStyle(color: textSecondary),
                          prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                          filled: true,
                          fillColor: backgroundColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: errorColor),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Ingresa tu correo' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        style: TextStyle(color: textPrimary), // Add this line for black text
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(color: textSecondary),
                          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                              color: primaryColor,
                            ),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                          filled: true,
                          fillColor: backgroundColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: errorColor),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Ingresa tu contraseña' : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
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
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(
                                onRegisterSuccess: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                        child: const Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
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
