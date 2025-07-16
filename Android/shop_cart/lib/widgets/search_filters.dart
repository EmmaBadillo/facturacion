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
    // Paleta moderna
    const Color primary = Color(0xFF1e40af);
    const Color accent = Color(0xFF059669);
    const Color bgCard = Color(0xFFFFFFFF);
    const Color bgInput = Color(0xFFFFFFFF);
    const Color bgMuted = Color(0xFFf1f5f9);
    const Color textPrimary = Color(0xFF0f172a);
    const Color textSecondary = Color(0xFF475569);
    const Color textMuted = Color(0xFF64748b);
    const Color border = Color(0xFFe2e8f0);
    const Color borderFocus = Color(0xFF3b82f6);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: border.withOpacity(0.08),
            blurRadius: 10,
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
              style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(fontSize: 14, color: textMuted, fontWeight: FontWeight.w400),
                prefixIcon: const Icon(Icons.search, color: textMuted, size: 20),
                suffixIcon: searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: textMuted, size: 18),
                        onPressed: () {
                          searchController.clear();
                          onSearch('');
                        },
                        splashRadius: 18,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: borderFocus, width: 1.5),
                ),
                filled: true,
                fillColor: bgInput,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                isDense: true,
              ),
              onSubmitted: onSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 10),
          // Categoría
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory ?? '',
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Todas', style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id.toString(),
                        child: Text(category.name, style: const TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
                      );
                    }),
                  ],
                  onChanged: (String? newValue) {
                    onCategoryChange(newValue == '' ? null : newValue);
                  },
                  icon: const Icon(Icons.arrow_drop_down, color: textMuted, size: 20),
                  style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  dropdownColor: bgInput,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón limpiar
          SizedBox(
            height: 36,
            width: 36,
            child: Material(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onClearFilters,
                child: const Icon(Icons.refresh, color: accent, size: 22),
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
