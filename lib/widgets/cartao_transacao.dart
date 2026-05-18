import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../modelos/gasto.dart';

class CartaoTransacao extends StatelessWidget {
  final Gasto gasto;
  final VoidCallback? onDelete;

  const CartaoTransacao({super.key, required this.gasto, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cor = gasto.ehDespesa ? AppTheme.dangerRed : AppTheme.successGreen;
    final emoji = AppConstants.categoryEmojis[gasto.categoria] ?? '📦';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(
          gasto.descricao.isNotEmpty ? gasto.descricao : gasto.categoria,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${gasto.categoria} • ${AppFormatters.formatDateShort(gasto.data)}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${gasto.ehDespesa ? '-' : '+'}${AppFormatters.formatMZN(gasto.valor)}',
                  style: TextStyle(
                    color: cor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (!gasto.sincronizado)
                  const Text('⏳ offline',
                      style: TextStyle(fontSize: 9, color: Colors.orange)),
              ],
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}