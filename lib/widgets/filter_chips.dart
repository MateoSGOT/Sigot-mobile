import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';

/// Chips de filtro de la app: alineados al mismo margen (16px) que el buscador
/// y las tarjetas, con selección animada en píldora esmeralda.
class SigotFilterChips extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  const SigotFilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: labels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final sel = i == selected;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(i);
              },
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.ease,
                padding: EdgeInsets.symmetric(
                    horizontal: sel ? 12 : 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.32)
                        : const Color(0x14111827),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sel)
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(Icons.check,
                            size: 15, color: AppColors.primaryStrong),
                      ),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel
                            ? AppColors.primaryStrong
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
