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
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color borderGray = Color(0xFFB0BEC5);

    final pages = _buildPageNumbers();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: primaryBlue, size: 22),
            tooltip: 'Anterior',
            onPressed: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
          ),
          ...pages.map((page) {
            if (page == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text('...', style: TextStyle(color: borderGray, fontSize: 13)),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ElevatedButton(
                onPressed: page == currentPage ? null : () => onPageChange(page),
                style: ElevatedButton.styleFrom(
                  backgroundColor: page == currentPage ? accentGreen : Colors.white,
                  foregroundColor: page == currentPage ? Colors.white : primaryBlue,
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                  elevation: page == currentPage ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: borderGray),
                  ),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }).toList(),
          IconButton(
            icon: Icon(Icons.chevron_right, color: primaryBlue, size: 22),
            tooltip: 'Siguiente',
            onPressed: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}
