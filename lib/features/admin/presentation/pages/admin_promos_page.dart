import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../providers/admin_promos_provider.dart';

class AdminPromosPage extends ConsumerStatefulWidget {
  const AdminPromosPage({super.key});

  @override
  ConsumerState<AdminPromosPage> createState() => _AdminPromosPageState();
}

class _AdminPromosPageState extends ConsumerState<AdminPromosPage> {
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isCreating = false;
  DateTime? _selectedExpiryDate;

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _createPromoCode() async {
    final code = _codeController.text.trim().toUpperCase();
    final discountStr = _discountController.text.trim();

    if (code.isEmpty || discountStr.isEmpty) {
      AppSnackBar.show(context, 'PLEASE FILL ALL FIELDS');
      return;
    }

    final discount = double.tryParse(discountStr);
    if (discount == null || discount <= 0 || discount > 50) {
      AppSnackBar.show(context, 'DISCOUNT CANNOT EXCEED 50%');
      return;
    }

    setState(() => _isCreating = true);

    try {
      await Supabase.instance.client.from('promo_codes').insert({
        'code': code,
        'discount_percentage': discount,
        'is_active': true,
        'expiry_date': _selectedExpiryDate?.toIso8601String(),
      });

      _codeController.clear();
      _discountController.clear();
      _selectedExpiryDate = null;
      ref.invalidate(adminPromosProvider);

      if (mounted) {
        AppSnackBar.show(context, 'PROMO CODE CREATED SUCESSFULLY');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, 'ERROR CREATING CODE: $e');
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _togglePromoStatus(String id, bool currentStatus) async {
    try {
      await Supabase.instance.client
          .from('promo_codes')
          .update({'is_active': !currentStatus})
          .eq('id', id);

      ref.invalidate(adminPromosProvider);
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'FAILED TO UPDATE STATUS');
    }
  }

  Future<void> _deletePromoCode(String id) async {
    try {
      await Supabase.instance.client.from('promo_codes').delete().eq('id', id);

      ref.invalidate(adminPromosProvider);
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'FAILED TO DELETE PROMO CODE');
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(adminPromosProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bebas(
            'MANAGE PROMO CODES',
            fontSize: 32,
            letterSpacing: 2.0,
            color: textColor,
          ),
          const SizedBox(height: 32),

          // Create Form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: textColor, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bebas(
                  'CREATE NEW PROMO',
                  fontSize: 24,
                  color: textColor,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppField(
                        controller: _codeController,
                        hintText: 'PROMO CODE (E.G. DIWALI20)',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: AppField(
                        controller: _discountController,
                        hintText: 'DISCOUNT % (MAX 50)',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed > 50) {
                            _discountController.text = '50';
                            AppSnackBar.show(
                              context,
                              'DISCOUNT CANNOT EXCEED 50%',
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          if (date != null) {
                            setState(() => _selectedExpiryDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor, width: 2),
                          ),
                          child: AppText.spaceMono(
                            _selectedExpiryDate == null
                                ? 'SET EXPIRY (OPTIONAL)'
                                : _selectedExpiryDate.toString().split(' ')[0],
                            fontSize: 10,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    BrutalistHoverWidget(
                      child: InkWell(
                        onTap: _isCreating ? null : _createPromoCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: textColor,
                            border: Border.all(color: textColor, width: 2),
                          ),
                          child: _isCreating
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: surfaceColor,
                                  ),
                                )
                              : AppText.bebas(
                                  'CREATE',
                                  fontSize: 16,
                                  color: surfaceColor,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // List
          AppText.bebas('ACTIVE PROMO CODES', fontSize: 24, color: textColor),
          const SizedBox(height: 16),

          promosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
            data: (promos) {
              if (promos.isEmpty) {
                return AppText.spaceMono('No promo codes found.');
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: textColor, width: 2),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: promos.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: textColor, height: 1, thickness: 2),
                  itemBuilder: (context, index) {
                    final promo = promos[index];
                    final isActive = promo['is_active'] as bool;

                    return Container(
                      color: isActive
                          ? Colors.transparent
                          : textColor.withValues(alpha: 0.1),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        title: AppText.bebas(
                          promo['code'],
                          fontSize: 24,
                          color: isActive
                              ? textColor
                              : textColor.withValues(alpha: 0.5),
                        ),
                        subtitle: AppText.spaceMono(
                          '${promo['discount_percentage']}% OFF  |  USED: ${promo['times_used']} TIMES${promo['expiry_date'] != null ? '  |  EXP: ${promo['expiry_date'].toString().split('T')[0]}' : ''}',
                          fontSize: 12,
                          color: isActive
                              ? textColor
                              : textColor.withValues(alpha: 0.5),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: isActive,
                              onChanged: (_) =>
                                  _togglePromoStatus(promo['id'], isActive),
                              activeThumbColor: Colors.greenAccent,
                              activeTrackColor: Colors.green.withValues(
                                alpha: 0.3,
                              ),
                              inactiveThumbColor: textColor.withValues(
                                alpha: 0.5,
                              ),
                              inactiveTrackColor: surfaceColor,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deletePromoCode(promo['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
