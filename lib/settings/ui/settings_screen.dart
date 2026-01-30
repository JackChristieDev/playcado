import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/l10n/app_localizations.dart';
import 'package:playcado/theme/app_theme.dart';
import 'package:playcado/theme/bloc/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Color> _availableColors = [
    AppTheme.avocadoGreen,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blueGrey,
  ];

  static String _getColorName(BuildContext context, Color color) {
    final l10n = AppLocalizations.of(context)!;
    final colorMap = {
      AppTheme.avocadoGreen: 'Avocado',
      Colors.deepPurple: l10n.colorDeepPurple,
      Colors.indigo: l10n.colorIndigo,
      Colors.blue: l10n.colorBlue,
      Colors.lightBlue: l10n.colorLightBlue,
      Colors.teal: l10n.colorTeal,
      Colors.green: l10n.colorGreen,
      Colors.orange: l10n.colorOrange,
      Colors.deepOrange: l10n.colorDeepOrange,
      Colors.red: l10n.colorRed,
      Colors.pink: l10n.colorPink,
      Colors.purple: l10n.colorPurple,
      Colors.blueGrey: l10n.colorBlueGrey,
    };

    return colorMap[color] ?? l10n.colorCustom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.l10n.appearance,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.appThemeColor,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.selectAColorToCustomizeTheAppsLookAndFeel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableColors.map((color) {
                          final isSelected =
                              state.themeColor.toARGB32() == color.toARGB32();
                          return GestureDetector(
                            onTap: () {
                              context.read<ThemeBloc>().add(
                                ChangeThemeColor(color),
                              );
                            },
                            child: Tooltip(
                              message: _getColorName(context, color),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          width: 2.5,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
