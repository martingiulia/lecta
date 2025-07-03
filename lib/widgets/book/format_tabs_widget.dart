import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_detail_provider.dart';
import '../../core/theme.dart';
import '../../core/app_icon.dart';

/// Widget per la selezione dei formati di lettura (Carta, Ebook, Audio)
class FormatTabsWidget extends StatelessWidget {
  const FormatTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookDetailProvider>(
      builder: (context, provider, child) {
        List<String> formats = ['Carta', 'Ebook', 'Audio'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.darkSurface
                      : AppTheme.lightSurface,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: List.generate(formats.length, (index) {
                  final format = formats[index];
                  final isSelected = provider.selectedFormatIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => provider.selectFormat(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              _getFormatIcon(format),
                              size: 23,
                              color: isSelected
                                  ? AppTheme.lightSurface
                                  : (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black87
                                        : AppTheme.lightSurface),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              format,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.lightSurface
                                    : (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : AppTheme.lightSurface),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Metodo helper per ottenere l'icona appropriata per ogni formato
  AppIconType _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'carta':
        return AppIconType.menuBook;
      case 'ebook':
        return AppIconType.tabletMac;
      case 'audio':
        return AppIconType.headphones;
      default:
        return AppIconType.book;
    }
  }
}
