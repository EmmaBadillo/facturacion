import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/client_service.dart';
import '../services/user_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  
  const ProfileScreen({super.key, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Client? _client;
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdate; // Para controlar actualizaciones recientes

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }
  Future<void> _loadClientData() async {
    if (_lastUpdate != null && 
        DateTime.now().difference(_lastUpdate!).inSeconds < 10) {
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final client = await ClientService.getCurrentClient();
      
      setState(() {
        _client = client;
        _isLoading = false;
        if (client == null) {
          _error = 'No se pudo cargar la información del perfil. Verifica tu conexión y que tengas una sesión activa.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar el perfil: ${e.toString()}';
      });
    }
  }

  Future<void> _forceRefreshClientData() async {
    _lastUpdate = null; 
    _clearImageCache();
    await _loadClientData();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await UserService.logout();
        
        if (mounted) {
          if (widget.onLogout != null) {
            // Cerrar todas las pantallas abiertas y regresar a main
            Navigator.of(context).popUntil((route) => route.isFirst);
            // Llamar al callback que maneja el logout en main.dart
            widget.onLogout!();
          } else {
            // Si no hay callback, mostrar error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: No se pudo cerrar sesión correctamente'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Limpia el caché de imágenes para forzar la recarga
  void _clearImageCache() {
    try {
      // Limpiar el caché de imágenes de red
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    // Paleta moderna
    const Color primary = Color(0xFF1e40af);
    const Color accent = Color(0xFF059669);
    const Color bgCard = Color(0xFFFFFFFF);
    const Color bgMuted = Color(0xFFf1f5f9);
    const Color textPrimary = Color(0xFF0f172a);
    const Color textSecondary = Color(0xFF475569);
    const Color textMuted = Color(0xFF64748b);
    const Color border = Color(0xFFe2e8f0);
    const Color error = Color(0xFFef4444);

    return Scaffold(
      backgroundColor: bgMuted,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _forceRefreshClientData,
            tooltip: 'Recargar perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _buildBodyModern(primary, accent, bgCard, border, textPrimary, textSecondary, textMuted, error),
    );
  }

  Widget _buildBodyModern(Color primary, Color accent, Color bgCard, Color border, Color textPrimary, Color textSecondary, Color textMuted, Color error) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: accent),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: error),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: error.withOpacity(0.18)),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _forceRefreshClientData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_client == null) {
      return Center(
        child: Text(
          'No se pudo cargar la información del perfil',
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: accent,
      onRefresh: _forceRefreshClientData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header moderno con avatar y datos principales
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary.withOpacity(0.98), accent.withOpacity(0.93)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileAvatarModern(primary, accent, bgCard, border, textPrimary, textSecondary),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_client!.firstName} ${_client!.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _client!.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.93),
                            fontSize: 14,
                          ),
                        ),
                        if (_client!.clientId != 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ID: ${_client!.clientId}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Información personal
            _buildSectionModern(
              title: 'Información Personal',
              children: [
                _buildInfoItemModern('Cédula', _client!.cedula, textPrimary, textMuted),
                _buildInfoItemModern('Nombre', _client!.firstName, textPrimary, textMuted),
                _buildInfoItemModern('Apellido', _client!.lastName, textPrimary, textMuted),
                _buildInfoItemModern('Email', _client!.email, textPrimary, textMuted),
                _buildInfoItemModern('Teléfono', _client!.phone, textPrimary, textMuted),
                _buildInfoItemModern('Dirección', _client!.address, textPrimary, textMuted),
              ],
              bgCard: bgCard,
              border: border,
            ),
            const SizedBox(height: 30),

            // Acciones
            _buildSectionModern(
              title: 'Acciones',
              children: [
                _buildActionButtonModern(
                  icon: Icons.edit,
                  title: 'Editar Perfil',
                  subtitle: 'Actualizar información personal',
                  onTap: () => _navigateToEditProfile(),
                  primary: primary,
                  accent: accent,
                  textMuted: textMuted,
                ),
                _buildActionButtonModern(
                  icon: Icons.lock,
                  title: 'Cambiar Contraseña',
                  subtitle: 'Actualizar contraseña de acceso',
                  onTap: () => _navigateToChangePassword(),
                  primary: primary,
                  accent: accent,
                  textMuted: textMuted,
                ),
              ],
              bgCard: bgCard,
              border: border,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileAvatarModern(Color primary, Color accent, Color bgCard, Color border, Color textPrimary, Color textSecondary) {
    if (_client?.picture != null && _client!.picture!.isNotEmpty) {
      final imageUrl = _client!.picture!.contains('?')
          ? '${_client!.picture}&t=${DateTime.now().millisecondsSinceEpoch}'
          : '${_client!.picture}?t=${DateTime.now().millisecondsSinceEpoch}';
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: accent,
            width: 2.5,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: bgCard,
          radius: 34,
          child: ClipOval(
            child: Image.network(
              imageUrl,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              headers: {
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                'Pragma': 'no-cache',
                'Expires': '0',
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      color: accent,
                      strokeWidth: 2.0,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildInitialsAvatarModern(accent, bgCard, textPrimary);
              },
            ),
          ),
        ),
      );
    } else {
      return _buildInitialsAvatarModern(accent, bgCard, textPrimary);
    }
  }

  Widget _buildInitialsAvatarModern(Color accent, Color bgCard, Color textPrimary) {
    return CircleAvatar(
      backgroundColor: accent,
      radius: 34,
      child: Text(
        _client!.firstName.isNotEmpty && _client!.lastName.isNotEmpty
            ? '${_client!.firstName[0]}${_client!.lastName[0]}'
            : 'U',
        style: TextStyle(
          color: bgCard,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionModern({
    required String title,
    required List<Widget> children,
    required Color bgCard,
    required Color border,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: bgCard == Colors.white ? Color(0xFF1e40af) : Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 13),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: border.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItemModern(String label, String value, Color textPrimary, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: textMuted,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No especificado',
              style: TextStyle(
                color: textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonModern({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primary,
    required Color accent,
    required Color textMuted,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: primary,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No especificado',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.accentColor,
              size: 26,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _navigateToEditProfile() async {
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(client: _client!),
      ),
    );
    if (result != null) {
      if (result is Client) {
        // Limpiar caché de imágenes antes de actualizar
        _clearImageCache();
        
        setState(() {
          _client = result;
          _lastUpdate = DateTime.now(); // Marcar que acabamos de actualizar
        });
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _forceRefreshClientData();
          }
        });
        
        
        // Notificar a la pantalla anterior que hubo cambios
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } else if (result == true) {
        // Comportamiento antiguo (por si acaso)
        await _loadClientData();
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  Future<void> _navigateToChangePassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    // Verificar si el cliente tiene una foto de perfil
    if (_client?.picture != null && _client!.picture!.isNotEmpty) {
      
      // Agregar timestamp para evitar el caché
      final imageUrl = _client!.picture!.contains('?') 
          ? '${_client!.picture}&t=${DateTime.now().millisecondsSinceEpoch}'
          : '${_client!.picture}?t=${DateTime.now().millisecondsSinceEpoch}';
      
      
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accentColor,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: AppColors.backgroundLight,
          radius: 30,
          child: ClipOval(
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              // Evitar caché
              cacheWidth: null,
              cacheHeight: null,
              headers: {
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                'Pragma': 'no-cache',
                'Expires': '0',
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                      strokeWidth: 2.0,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Si hay error cargando la imagen, mostrar iniciales
                return _buildInitialsAvatar();
              },
            ),
          ),
        ),
      );
    } else {
      // Si no hay foto, mostrar iniciales
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      backgroundColor: AppColors.accentColor,
      radius: 30,
      child: Text(
        _client!.firstName.isNotEmpty && _client!.lastName.isNotEmpty
            ? '${_client!.firstName[0]}${_client!.lastName[0]}'
            : 'U',
        style: TextStyle(
          color: AppColors.backgroundLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AppColors {
  static const Color primaryColor = Color(0xFF1A237E); // Azul oscuro
  static const Color accentColor = Color(0xFF43A047);  // Verde contable
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color secondaryColor = Color(0xFFE3E6EA);
  static const Color borderColor = Color(0xFFB0BEC5);
  static const Color textPrimary = Color(0xFF222B45);
  static const Color textSecondary = Color(0xFF7B8194);
}
