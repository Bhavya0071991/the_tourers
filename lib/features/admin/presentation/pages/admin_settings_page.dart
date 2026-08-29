import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/admin_info_card.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  bool _orderAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bebas(
            AppStrings.adminSettingsTitle,
            fontSize: 32,
            letterSpacing: 2.0,
            color: textColor,
          ),
          const SizedBox(height: 16),
          AppText.spaceMono(
            AppStrings.adminSettingsDesc,
            fontSize: 12,
            color: textColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 48),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  children: [
                    AdminInfoCard(
                      title: AppStrings.adminSetStoreProfile,
                      content: Column(
                        children: [
                          _buildTextField(
                            label: AppStrings.adminSetStoreName,
                            initialValue: 'THE TOURERS',
                            textColor: textColor,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            label: AppStrings.adminSetContactEmail,
                            initialValue: 'admin@thetourers.com',
                            textColor: textColor,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            label: AppStrings.adminSetSupportPhone,
                            initialValue: '+91 9876543210',
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Right Column
              Expanded(
                child: Column(
                  children: [
                    AdminInfoCard(
                      title: AppStrings.adminSetGeneralSettings,
                      content: Column(
                        children: [
                          _buildTextField(
                            label: AppStrings.adminSetCurrency,
                            initialValue: 'INR (₹)',
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 55),
                    AdminInfoCard(
                      title: AppStrings.adminSetNotifications,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.spaceMono(
                            AppStrings.adminSetOrderAlerts,
                            fontSize: 14,
                          ),
                          Switch(
                            value: _orderAlertsEnabled,
                            onChanged: (val) =>
                                setState(() => _orderAlertsEnabled = val),
                            activeThumbColor: textColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),
          BrutalistHoverWidget(
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved successfully')),
                );
              },
              child: Container(
                width: 250,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: textColor, width: 2),
                ),
                child: Center(
                  child: AppText.bebas(
                    AppStrings.adminSetSaveBtn,
                    fontSize: 20,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Color textColor,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.spaceMono(
          label,
          fontSize: 10,
          color: textColor.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          obscureText: obscureText,
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 14,
            color: textColor,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: textColor, width: 2),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: textColor, width: 2),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ],
    );
  }
}
