import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../home/data/models/promo_marquee.dart';
import '../../../home/data/repositories/promo_marquee_repository.dart';
import '../../../home/providers/promo_marquee_provider.dart';

class AdminMarqueePage extends ConsumerStatefulWidget {
  const AdminMarqueePage({super.key});

  @override
  ConsumerState<AdminMarqueePage> createState() => _AdminMarqueePageState();
}

class _AdminMarqueePageState extends ConsumerState<AdminMarqueePage> {
  final _textController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initialize(PromoMarquee? marquee) {
    if (_isInitialized) return;
    if (marquee != null) {
      _textController.text = marquee.text;
      _isActive = marquee.isActive;
    } else {
      _textController.text = 'FREE SHIPPING ON ALL ORDERS';
      _isActive = true;
    }
    _isInitialized = true;
  }

  Future<void> _saveMarquee() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marquee text cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(promoMarqueeRepositoryProvider);
      final marquee = PromoMarquee(
        text: _textController.text.trim(),
        isActive: _isActive,
      );

      await repo.updateMarquee(marquee);
      
      // Invalidate the provider so the home page updates instantly
      ref.invalidate(promoMarqueeProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marquee updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating marquee: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final marqueeState = ref.watch(promoMarqueeProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bebas(
              'MANAGE MARQUEE',
              fontSize: 32,
              letterSpacing: 2.0,
              color: textColor,
            ),
            const SizedBox(height: 32),
            marqueeState.when(
              data: (marquee) {
                // Initialize controllers once
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _initialize(marquee);
                  if (mounted) setState(() {}); // Trigger rebuild to show values
                });

                return Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border.all(color: textColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: textColor,
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.spaceMono('MARQUEE TEXT', fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 🔥 50% OFF FLASH SALE 🔥',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      AppText.spaceMono('STATUS', fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: AppText.spaceMono('Is Active (Visible on Home Page)'),
                        value: _isActive,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _isActive = val;
                            });
                          }
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: textColor,
                        checkColor: surfaceColor,
                      ),
                      const SizedBox(height: 32),
                      BrutalistHoverWidget(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textColor,
                            foregroundColor: surfaceColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            side: BorderSide(color: textColor, width: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 24,
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : _saveMarquee,
                          child: _isLoading
                              ? CircularProgressIndicator(color: surfaceColor)
                              : AppText.spaceMono(
                                  'SAVE MARQUEE',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}
