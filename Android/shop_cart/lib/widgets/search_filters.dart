import 'package:flutter/material.dart';
import '../models/category.dart';

class SearchFilters extends StatelessWidget {
  final List<Category> categories;
  final Function(String) onSearch;
  final Function(String?) onCategoryChange;
  final String searchTerm;
  final String? selectedCategory;
  final TextEditingController searchController;
  final VoidCallback onClearFilters;

  const SearchFilters({
    super.key,
    required this.categories,
    required this.onSearch,
    required this.onCategoryChange,
    required this.searchTerm,
    required this.selectedCategory,
    required this.searchController,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    // Paleta contable
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color borderGray = Color(0xFFB0BEC5);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cardGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Buscador
          Expanded(
            flex: 2,
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.black, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: borderGray, size: 18),
                suffixIcon: searchTerm.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: borderGray, size: 18),
                        onPressed: () {
                          searchController.clear();
                          onSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                isDense: true,
              ),
              onSubmitted: onSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 8),
          // Categoría
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory ?? '',
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Todas', style: TextStyle(fontSize: 13, color: Colors.black)),
                  ),
                  ...categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id.toString(),
                      child: Text(category.name, style: const TextStyle(fontSize: 13, color: Colors.black)),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  onCategoryChange(newValue == '' ? null : newValue);
                },
                icon: Icon(Icons.arrow_drop_down, color: borderGray, size: 18),
                style: const TextStyle(color: Colors.black, fontSize: 13),
                dropdownColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón limpiar
          SizedBox(
            height: 32,
            width: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onClearFilters,
                child: Icon(Icons.refresh, color: accentGreen, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene un valor válido para el dropdown, evitando errores de valores no encontrados
  String _getValidSelectedCategory() {
    // Si selectedCategory es null o vacío, retornar el valor por defecto
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      return '';
    }
    
    final categoryExists = categories.any((category) => category.id.toString() == selectedCategory);
    
    if (categoryExists) {
      return selectedCategory!;
    } else {
      // Si no existe, retornar el valor por defecto
      return '';
    }
  }
}
