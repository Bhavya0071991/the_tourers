import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/promo_marquee_provider.dart';

class PromoBanner extends ConsumerStatefulWidget {
  const PromoBanner({super.key});

  @override
  ConsumerState<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends ConsumerState<PromoBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100), // Slower, more readable marquee
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promoAsyncValue = ref.watch(promoMarqueeProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Black background
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width > 900 ? 10.0 : 6.0,
      ),
      child: promoAsyncValue.when(
        data: (marquee) {
          if (marquee == null || !marquee.isActive || marquee.text.isEmpty) {
            return const SizedBox.shrink();
          }
          final promos = <String>[marquee.text];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: FractionalTranslation(
                    translation: Offset(-_controller.value * 0.5, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBannerBlock(context, promos),
                        _buildBannerBlock(context, promos),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white, // Since primary is black
            ),
          ),
        ),
        error: (err, stack) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBannerBlock(BuildContext context, List<String> promos) {
    // Generate enough repeated sequences to comfortably span the screen
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (index) {
        final promoText = promos[index % promos.length];
        return _buildBannerItem(context, promoText);
      }),
    );
  }

  Widget _buildBannerItem(BuildContext context, String text) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded, // Premium dynamic icon
            color: Theme.of(context).colorScheme.surface,
            size: isDesktop ? 14 : 10,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceMono(
                color: Theme.of(context).colorScheme.surface,
                fontSize: isDesktop ? 11 : 8,
                fontWeight: FontWeight.w700,
                letterSpacing: isDesktop ? 2.5 : 1.5,
              ),
              children: _buildEmojiSpans(text, isDesktop),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildEmojiSpans(String text, bool isDesktop) {
    // Basic regex to match most common emojis including fire 🔥
    final RegExp emojiRegex = RegExp(
      r'([\u2600-\u27BF]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF])',
    );

    final List<TextSpan> spans = [];
    text.splitMapJoin(
      emojiRegex,
      onMatch: (m) {
        spans.add(
          TextSpan(
            text: m.group(0),
            style: GoogleFonts.spaceMono(
              fontSize: isDesktop ? 8 : 6, // Smaller size for emojis
            ),
          ),
        );
        return '';
      },
      onNonMatch: (n) {
        spans.add(TextSpan(text: n));
        return '';
      },
    );
    return spans;
  }
}
