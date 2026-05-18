import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../modelos/dica.dart';

class CartaoDicas extends StatelessWidget {
  final Dica dica;
  final bool feita;
  final VoidCallback? onToggle;

  const CartaoDicas({
    super.key,
    required this.dica,
    this.feita = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: feita
                ? AppTheme.successGreen.withOpacity(0.1)
                : AppTheme.accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(dica.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          dica.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            decoration: feita ? TextDecoration.lineThrough : null,
            color: feita ? Colors.grey : null,
          ),
        ),
        subtitle: feita
            ? null
            : Text(
          dica.descricao,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onToggle != null
            ? GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: feita
                  ? AppTheme.successGreen.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              feita ? 'Feito' : 'A fazer',
              style: TextStyle(
                color: feita
                    ? AppTheme.successGreen
                    : AppTheme.warningOrange,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
            : null,
      ),
    );
  }
}