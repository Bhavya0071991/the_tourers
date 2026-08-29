import 'package:dummy_epod/features/admin/providers/customer_provider.dart';
import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_snackbar.dart';

import '../../../../features/auth/providers/auth_provider.dart';

class AdminCustomersPage extends ConsumerWidget {
  const AdminCustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isSuperAdmin = ref.watch(authProvider).value?.role == 'super_admin';
    final customersAsync = ref.watch(customerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bebas(
            AppStrings.adminCustomersManagement,
            fontSize: 32,
            letterSpacing: 2.0,
            color: textColor,
          ),
          const SizedBox(height: 16),
          AppText.spaceMono(
            AppStrings.adminCustomersDesc,
            fontSize: 12,
            color: textColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 32),

          // Search Field
          AppField(
            hintText: 'SEARCH CUSTOMERS (ID, NAME, EMAIL)',
            onChanged: (val) {},
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: textColor, width: 2),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(color: textColor),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppText.spaceMono(
                          AppStrings.adminColCustomerId,
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: AppText.spaceMono(
                          AppStrings.adminColName,
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: AppText.spaceMono(
                          AppStrings.adminColEmail,
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: AppText.spaceMono(
                          AppStrings.adminColJoinedDate,
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: AppText.spaceMono(
                          AppStrings.adminColTotalOrders,
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: AppText.spaceMono(
                          'ROLE',
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rows
                ...customersAsync.when(
                  data: (customers) {
                    if (customers.isEmpty) {
                      return [
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: AppText.spaceMono(
                              'NO CUSTOMERS FOUND',
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ];
                    }
                    return customers.map((customer) {
                      return BrutalistHoverWidget(
                        child: InkWell(
                          onTap: () => context.go(
                            AppPaths.adminCustomerDetails(customer.id),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border(
                                top: BorderSide(color: textColor, width: 2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: AppText.spaceMono(
                                    customer.id,
                                    color: textColor,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AppText.spaceMono(
                                    customer.name,
                                    color: textColor,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: AppText.spaceMono(
                                    customer.email,
                                    color: textColor,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AppText.spaceMono(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(customer.joinedAt),
                                    color: textColor,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AppText.spaceMono(
                                    customer.totalOrders.toString(),
                                    color: textColor,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: isSuperAdmin
                                      ? DropdownButton<String>(
                                          value: customer.role,
                                          underline: const SizedBox(),
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: textColor,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'SpaceMono',
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                          onChanged: (String? newValue) async {
                                            if (newValue != null &&
                                                newValue != customer.role) {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  insetPadding:
                                                      const EdgeInsets.all(24),
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth: 400,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          32,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.surface,
                                                      border: Border.all(
                                                        color: textColor,
                                                        width: 3,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: textColor,
                                                          offset: const Offset(
                                                            6,
                                                            6,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'CONFIRM ROLE CHANGE',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'BebasNeue',
                                                            fontSize: 32,
                                                            letterSpacing: 2.0,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Text(
                                                          'Are you sure you want to change the user role to ${newValue.toUpperCase()}?',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'SpaceMono',
                                                            fontSize: 14,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 32,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                              child: Text(
                                                                'CANCEL',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'SpaceMono',
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 16,
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    textColor,
                                                                foregroundColor:
                                                                    Theme.of(
                                                                      context,
                                                                    ).scaffoldBackgroundColor,
                                                                shape: const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero,
                                                                ),
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          24,
                                                                      vertical:
                                                                          16,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                'YES, CHANGE IT',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'SpaceMono',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );

                                              if (confirm != true) return;

                                              try {
                                                await ref
                                                    .read(
                                                      customerProvider.notifier,
                                                    )
                                                    .updateRole(
                                                      customer.id,
                                                      newValue,
                                                    );
                                                if (context.mounted) {
                                                  AppSnackBar.show(
                                                    context,
                                                    'Role updated successfully to ${newValue.toUpperCase()}',
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  AppSnackBar.show(
                                                    context,
                                                    'Failed to update role: $e',
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          items:
                                              <String>[
                                                'user',
                                                'admin',
                                                'super_admin',
                                              ].map<DropdownMenuItem<String>>((
                                                String value,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value.toUpperCase(),
                                                  ),
                                                );
                                              }).toList(),
                                        )
                                      : AppText.spaceMono(
                                          customer.role.toUpperCase(),
                                          color: textColor,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  },
                  loading: () => [
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (error, stack) => [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: AppText.spaceMono(
                          'Error loading customers: $error',
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
