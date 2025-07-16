import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChange;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  }) : super(key: key);

  List<int?> _buildPageNumbers() {
    List<int?> pages = [];
    if (totalPages <= 7) {
      for (int i = 1; i <= totalPages; i++) pages.add(i);
    } else {
      pages.add(1);
      if (currentPage > 4) pages.add(null); // ...
      int start = currentPage - 1;
      int end = currentPage + 1;
      if (start < 2) start = 2;
      if (end > totalPages - 1) end = totalPages - 1;
      for (int i = start; i <= end; i++) pages.add(i);
      if (currentPage < totalPages - 3) pages.add(null); // ...
      pages.add(totalPages);
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    // Paleta moderna
    const Color primary = Color(0xFF1e40af);
    const Color accent = Color(0xFF059669);
    const Color bgCard = Color(0xFFFFFFFF);
    const Color bgMuted = Color(0xFFf1f5f9);
    const Color textPrimary = Color(0xFF0f172a);
    const Color textMuted = Color(0xFF64748b);
    const Color border = Color(0xFFe2e8f0);
    const Color borderFocus = Color(0xFF3b82f6);

    final pages = _buildPageNumbers();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: currentPage > 1 ? bgMuted : bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border, width: 1),
                ),
                child: Icon(Icons.chevron_left, color: currentPage > 1 ? primary : border, size: 22),
              ),
            ),
          ),
          ...pages.map((page) {
            if (page == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text('...', style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
              );
            }
            final bool isCurrent = page == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: isCurrent ? accent : bgCard,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: isCurrent ? null : () => onPageChange(page),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isCurrent ? accent : border, width: 1.2),
                      boxShadow: isCurrent
                          ? [BoxShadow(color: accent.withOpacity(0.13), blurRadius: 8, offset: Offset(0,2))]
                          : [],
                    ),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? Colors.white : primary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          // Botón siguiente
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: currentPage < totalPages ? bgMuted : bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border, width: 1),
                ),
                child: Icon(Icons.chevron_right, color: currentPage < totalPages ? primary : border, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
