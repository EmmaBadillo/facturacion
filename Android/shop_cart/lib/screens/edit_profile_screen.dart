import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/client.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  final Client client;

  const EditProfileScreen({
    super.key,
    required this.client,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _newProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _cedulaController.text = widget.client.cedula;
    _firstNameController.text = widget.client.firstName;
    _lastNameController.text = widget.client.lastName;
    _emailController.text = widget.client.email;
    _phoneController.text = widget.client.phone;
    _addressController.text = widget.client.address;
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paleta contable
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color lightGray = Color(0xFFF5F5F5);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color borderGray = Color(0xFFB0BEC5);

    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: _isLoading ? borderGray : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderGray.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: accentGreen, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Puedes actualizar tu nombre, apellido, teléfono y dirección. La cédula y email no se pueden modificar.',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Sección de foto de perfil
              _buildProfilePictureSectionContable(),
              const SizedBox(height: 22),

              // Formulario
              _buildFormSectionContable(),
              const SizedBox(height: 28),

              // Botones de acción
              _buildActionButtonsContable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSectionContable() {
    const Color accentGreen = Color(0xFF43A047);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color primaryBlue = Color(0xFF1A237E);

    final currentImageUrl = _newProfileImageUrl ?? widget.client.picture;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardGray),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor: accentGreen.withOpacity(0.10),
                backgroundImage: currentImageUrl != null && currentImageUrl.isNotEmpty
                    ? NetworkImage(currentImageUrl)
                    : null,
                child: currentImageUrl == null || currentImageUrl.isEmpty
                    ? Icon(Icons.person, size: 54, color: accentGreen)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: accentGreen,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: _isUploadingImage
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _isUploadingImage ? null : _selectAndUploadProfilePicture,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Toca el ícono de cámara para cambiar tu foto',
            style: TextStyle(
              color: primaryBlue,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSectionContable() {
    const Color cardGray = Color(0xFFE3E6EA);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Personal',
            style: TextStyle(
              color: Color(0xFF1A237E),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Cédula (Solo lectura)
          _buildReadOnlyField(
            controller: _cedulaController,
            label: 'Cédula',
            icon: Icons.badge,
            helperText: 'Este campo no se puede modificar',
          ),
          const SizedBox(height: 16),

          // Nombre (Editable)
          _buildTextFieldContable(
            controller: _firstNameController,
            label: 'Nombre',
            icon: Icons.person,
            validator: (value) => _validateName(value, fieldName: 'El nombre'),
          ),
          const SizedBox(height: 16),

          // Apellido (Editable)
          _buildTextFieldContable(
            controller: _lastNameController,
            label: 'Apellido',
            icon: Icons.person_outline,
            validator: (value) => _validateName(value, fieldName: 'El apellido'),
          ),
          const SizedBox(height: 16),

          // Email (Solo lectura)
          _buildReadOnlyField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            helperText: 'Este campo no se puede modificar',
          ),
          const SizedBox(height: 16),

          // Teléfono (Opcional)
          _buildTextFieldContable(
            controller: _phoneController,
            label: 'Teléfono (opcional)',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: _validatePhone,
          ),
          const SizedBox(height: 16),

          // Dirección (Opcional)
          _buildTextFieldContable(
            controller: _addressController,
            label: 'Dirección (opcional)',
            icon: Icons.location_on,
            maxLines: 2,
            validator: (value) => Validators.address(value, isRequired: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldContable({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color borderGray = Color(0xFFB0BEC5);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: !_isLoading,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accentGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: primaryBlue),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: primaryBlue),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          enabled: false, // Campo de solo lectura
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.backgroundLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
            ),
            labelStyle: TextStyle(color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  helperText,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtonsContable() {
    const Color accentGreen = Color(0xFF43A047);
    const Color borderGray = Color(0xFFB0BEC5);

    return Column(
      children: [
        // Botón Guardar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveProfile,
            icon: _isLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: const Text(
              'Guardar Cambios',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón Cancelar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel, color: borderGray),
            label: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: borderGray,
              side: BorderSide(color: borderGray),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final clientId = widget.client.clientId;
      final url = Uri.parse('https://api-sable-eta.vercel.app/api/clients');
      final body = jsonEncode({
        "clientId": clientId,
        "cedula": _cedulaController.text.trim(),
        "email": _emailController.text.trim(),
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "address": _addressController.text.trim(),
        "phone": _phoneController.text.trim(),
      });

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['error'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Perfil actualizado correctamente.'),
              backgroundColor: Color(0xFF43A047), // accentGreen
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop(true); // Puedes pasar el cliente actualizado si lo necesitas
        }
      } else {
        final errorMsg = data['error'] ?? 'Error desconocido al actualizar el perfil.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectAndUploadProfilePicture() async {
    try {
      // Mostrar opciones para seleccionar fuente
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Mostrar progreso detallado
      _showProgressDialog();

      // Usar el servicio de imágenes para solo subir la imagen (sin actualizar BD)
      final imageUrl = await ImageService.selectAndUploadImageOnly(source: source);
      
      // Cerrar diálogo de progreso
      if (mounted) Navigator.of(context).pop();
      
      if (imageUrl != null) {
        
        setState(() {
          _newProfileImageUrl = imageUrl;
        });
        
        // Mostrar mensaje que indica que la imagen está lista para guardar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto subida exitosamente. Presiona "Guardar" para actualizar tu perfil.'),
            backgroundColor: AppColors.accentColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de progreso si está abierto
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      String errorMessage = e.toString();
      
      // Mostrar mensaje de error más específico
      if (errorMessage.contains('comunicación') || errorMessage.contains('no está disponible')) {
        _showChannelErrorDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar foto: ${errorMessage.replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: AppColors.backgroundLight,
              onPressed: _selectAndUploadProfilePicture,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            const Text('Procesando imagen...'),
            const SizedBox(height: 8),
            Text(
              'Verificando plugin, seleccionando imagen y subiendo al servidor',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showChannelErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Error de Comunicación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hay un problema de comunicación con el plugin de imagen.'),
            const SizedBox(height: 16),
            const Text('Para solucionarlo:'),
            const SizedBox(height: 8),
            const Text('1. Reinicia la aplicación completamente'),
            const Text('2. Verifica que los permisos estén habilitados'),
            const Text('3. Intenta usar una fuente diferente (cámara/galería)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _testImagePickerPlugin();
            },
            child: Text('Diagnóstico', style: TextStyle(color: AppColors.accentColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showTroubleshootingDialog();
            },
            child: Text('Ver Ayuda', style: TextStyle(color: AppColors.accentColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _selectAndUploadProfilePicture();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.backgroundLight,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            const Text('Solución de Problemas'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Si tienes problemas para seleccionar una imagen:'),
              const SizedBox(height: 16),
              _buildTroubleshootingStep('1', 'Verifica los permisos'),
              _buildTroubleshootingStep('2', 'Reinicia la aplicación'),
              _buildTroubleshootingStep('3', 'Libera espacio de almacenamiento'),
              _buildTroubleshootingStep('4', 'Prueba con la otra fuente (cámara/galería)'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.accentColor, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Si el problema persiste, contacta al soporte técnico.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Seleccionar foto',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿De dónde quieres seleccionar la foto?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cámara'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentColor),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galería'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentColor),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _testImagePickerPlugin() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundLight,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              const SizedBox(height: 16),
              const Text('Ejecutando diagnóstico...'),
            ],
          ),
        ),
      );

      // Ejecutar pruebas de diagnóstico
      final results = <String>[];
      
      // Prueba 1: Verificar disponibilidad
      try {
        final isAvailable = await ImageService.isImagePickerAvailable();
        results.add('✓ Plugin disponible: ${isAvailable ? 'SÍ' : 'NO'}');
      } catch (e) {
        results.add('✗ Error verificando plugin: $e');
      }

      // Prueba 2: Intentar inicialización
      try {
        final initialized = await ImageService.initializeImagePicker();
        results.add('✓ Inicialización: ${initialized ? 'EXITOSA' : 'FALLIDA'}');
      } catch (e) {
        results.add('✗ Error en inicialización: $e');
      }

      // Cerrar diálogo de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultados
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundLight,
            title: Row(
              children: [
                Icon(Icons.bug_report, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text('Diagnóstico'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: results.map((result) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(result),
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      // Cerrar diálogo de progreso
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en diagnóstico: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateName(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    final nameRegExp = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$");
    if (!nameRegExp.hasMatch(value.trim())) {
      return '$fieldName solo debe contener letras y espacios';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    final phone = value.trim();
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'El teléfono solo debe contener números';
    }
    if (phone.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    }
    if (!phone.startsWith('09')) {
      return 'El teléfono debe empezar con 09 (celular Ecuador)';
    }
    return null;
  }
}
