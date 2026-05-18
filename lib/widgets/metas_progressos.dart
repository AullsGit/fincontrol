import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../modelos/meta.dart';

class CartaoProgressoMeta extends StatelessWidget {
  final Meta meta;

  const CartaoProgressoMeta({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final cor = meta.concluida
        ? AppTheme.successGreen
        : meta.percentagem >= 80
        ? AppTheme.warningOrange
        : AppTheme.accentBlue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(meta.emoji ?? '🎯', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(meta.nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Text(
                  '${meta.percentagem.toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: cor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 8,
              percent: meta.progresso,
              backgroundColor: Colors.grey.shade200,
              progressColor: cor,
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppFormatters.formatMZN(meta.valorActual),
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(AppFormatters.formatMZN(meta.valorAlvo),
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}