import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/fade_in_slide_widget.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../../../home/presentation/widgets/footer_section.dart';
import '../../../home/presentation/widgets/promo_banner.dart';
import '../../providers/portraits_provider.dart';
import '../../domain/entities/portrait_design.dart';
import '../widgets/portrait_card.dart';

// StateProvider to handle the current category filter selection
final portraitCategoryFilterProvider =
    StateProvider.autoDispose<String>((ref) => 'ALL');

class PortraitPrintsPage extends ConsumerWidget {
  const PortraitPrintsPage({super.key});

  Widget _buildResponsiveColumn(bool isDesktop, int flex, Widget child) {
    if (isDesktop) {
      return Expanded(flex: flex, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(portraitCategoryFilterProvider);
    final filters = const ['ALL', 'HERITAGE', 'CYBERPUNK', 'STREET ART'];
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final designsAsync = ref.watch(portraitListProvider(selectedFilter));

    int crossAxisCount = 1;
    if (screenWidth > 1200) {
      crossAxisCount = 3;
    } else if (screenWidth > 800) {
      crossAxisCount = 2;
    }

    return Scaffold(
      body: Column(
        children: [
          // 1. Marquee Promo Banner
          const PromoBanner(),

          // 2. Navigation App Bar
          const WebConstrainedBox(child: CustomAppBar(isTransparent: false)),

          // 3. Scrollable Content Body
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── MINIMALISTIC HERO & FILTER SECTION ───
                  _buildHeaderAndFilters(context, ref, isDesktop, filters, selectedFilter, designsAsync),

                  // ─── PRINTS GRID ───
                  WebConstrainedBox(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64.0 : 24.0,
                      vertical: 32.0,
                    ),
                    child: designsAsync.when(
                      data: (designs) {
                        if (designs.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(64.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.15),
                                  width: 2),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.palette_outlined,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  AppText.spaceMono(
                                    'NO PORTRAITS IN THIS CATEGORY YET.',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: designs.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: AppSizes.p32,
                            mainAxisSpacing: AppSizes.p48,
                          ),
                          itemBuilder: (context, index) {
                            return FadeInSlideWidget(
                              delay: Duration(milliseconds: index * 120),
                              child: PortraitCard(design: designs[index]),
                            );
                          },
                        );
                      },
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Container(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text('Error loading portraits: $err',
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.p32),

                  // ─── PREMIUM GUARANTEE STRIP ───
                  _buildGuaranteeStrip(context, isDesktop),

                  const SizedBox(height: AppSizes.p64),

                  // ─── DESIGNER SPOTLIGHT (Enhanced) ───
                  _buildDesignerSpotlight(context, isDesktop),

                  const SizedBox(height: AppSizes.p64),

                  // Footer Section
                  const FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER AND FILTERS ──────────────────────────────────────────
  Widget _buildHeaderAndFilters(BuildContext context, WidgetRef ref, bool isDesktop,
      List<String> filters, String selectedFilter, AsyncValue<List<PortraitDesign>> designsAsync) {
    final theme = Theme.of(context);
    return WebConstrainedBox(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: 48.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Giant Header Title
          AppText.bebas(
            'PORTRAIT LAB',
            fontSize: isDesktop ? 96 : 56,
            height: 0.9,
            letterSpacing: 4.0,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: AppSizes.p16),

          // Description Subtitle matching brutalist constraints
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: AppText.spaceMono(
              'Tactile, premium paper prints capturing vintage colonial heritage '
              'motifs and cybernetic street graphics. Hand-signed and certified '
              'by lead artist Pranxhu.',
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSizes.p48),

          // Filter Row - Custom Interactive Brutalist Chips
          AppText.spaceMono(
            'FILTER BY THEME',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: AppSizes.p16),

          // Horizontal scrollable brutalist chip filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: filters.map((f) {
                final isSelected = f == selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    bottom: 8.0,
                  ),
                  child: InkWell(
                    onTap: () =>
                        ref.read(portraitCategoryFilterProvider.notifier).state = f,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28.0,
                        vertical: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.surface,
                        border: Border.all(
                          color: theme.colorScheme.onSurface,
                          width: 3.0,
                        ),
                      ),
                      child: AppText.spaceMono(
                        f,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? theme.colorScheme.surface
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSizes.p32),

          // Product Count indicator
          designsAsync.maybeWhen(
            data: (designs) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.spaceMono(
                  'SHOWING ${designs.length} DESIGNS',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                Container(
                  height: 2,
                  width: 100,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSizes.p16),
        ],
      ),
    );
  }

  // ─── PREMIUM GUARANTEE STRIP ─────────────────────────────────
  Widget _buildGuaranteeStrip(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    final items = [
      {'icon': Icons.verified_outlined, 'text': 'AUTHENTICATED'},
      {'icon': Icons.local_shipping_outlined, 'text': 'FREE SHIPPING'},
      {'icon': Icons.shield_outlined, 'text': 'DAMAGE PROTECTION'},
      {'icon': Icons.workspace_premium_outlined, 'text': 'CERTIFICATE OF AUTHENTICITY'},
    ];

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: 24.0,
      ),
      child: WebConstrainedBox(
        child: Wrap(
          spacing: isDesktop ? 48 : 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: items.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                AppText.spaceMono(
                  item['text'] as String,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── DESIGNER SPOTLIGHT (PREMIUM EDITION) ────────────────────
  Widget _buildDesignerSpotlight(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.onSurface,
      child: Stack(
        children: [
          // Subtle diagonal accent lines
          Positioned(
            left: isDesktop ? 80 : 20,
            top: -40,
            bottom: -40,
            child: Transform.rotate(
              angle: 0.12,
              child: Container(
                width: isDesktop ? 60 : 30,
                color: AppTheme.neonAccent.withValues(alpha: 0.04),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64.0 : 24.0,
              vertical: 80.0,
            ),
            child: WebConstrainedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header with accent bar
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        color: AppTheme.neonAccent,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.spaceMono(
                            'MEET THE CREATOR',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                            color: AppTheme.neonAccent.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 4),
                          AppText.bebas(
                            'DESIGNER SPOTLIGHT',
                            fontSize: isDesktop ? 36 : 26,
                            letterSpacing: 2.0,
                            color: theme.colorScheme.surface,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Two-column layout
                  Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Designer Info
                      _buildResponsiveColumn(
                        isDesktop,
                        3,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name with neon accent
                            AppText.bebas(
                              'PRANSHU',
                              fontSize: isDesktop ? 80 : 52,
                              letterSpacing: 6.0,
                              color: AppTheme.neonAccent,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.surface
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: AppText.spaceMono(
                                'CREATIVE DIRECTOR & HEAD OF PRINT LAB',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: theme.colorScheme.surface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 28),
                            AppText.spaceMono(
                              'Pranxhu is an independent visual designer specializing in brutalist '
                              'prints and regional cultural textures. Leveraging high-grain '
                              'photographic elements, colloquial typefaces, and bold ink halftones, '
                              'his work exists at the intersection of classical structure and '
                              'street-level industrial disruption.',
                              fontSize: 14,
                              color: theme.colorScheme.surface,
                              height: 1.7,
                            ),
                            const SizedBox(height: 36),

                            // Stats grid
                            Wrap(
                              spacing: isDesktop ? 32 : 24,
                              runSpacing: 24,
                              children: [
                                _buildDesignerStat(
                                    context, '50+', 'DESIGNS\nCREATED'),
                                _buildDesignerStat(
                                    context, '100%', 'HAND\nSIGNED'),
                                _buildDesignerStat(
                                    context, 'LTD', 'EDITION\nONLY'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop)
                        const SizedBox(width: 80)
                      else
                        const SizedBox(height: 48),

                      // Signature + Certification Card
                      _buildResponsiveColumn(
                        isDesktop,
                        2,
                        Column(
                          children: [
                            // Signature Block
                            BrutalistHoverWidget(
                              shadowColor: AppTheme.neonAccent,
                              offset: const Offset(8, 8),
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  border: Border.all(
                                      color: theme.colorScheme.onSurface,
                                      width: 3),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 1,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.2),
                                        ),
                                        const SizedBox(width: 12),
                                        AppText.spaceMono(
                                          'CERTIFICATION SIGNATURE',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.0,
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 20,
                                          height: 1,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.2),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 28),

                                    // Stylized Signature Placeholder
                                    Container(
                                      height: 110,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.08),
                                          width: 1.5,
                                        ),
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Cursive signature text
                                          Text(
                                            'Pranxhu',
                                            style: GoogleFonts.greatVibes(
                                              fontSize: 52,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          AppText.spaceMono(
                                            '[ DUMMY IMAGE / SIGNATURE ACTIVE ]',
                                            fontSize: 8,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Seal description
                                    AppText.spaceMono(
                                      'Each print is physically inspected, '
                                      'embossed, and hand-signed by Pranxhu '
                                      'before packaging.',
                                      fontSize: 11,
                                      textAlign: TextAlign.center,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.55),
                                      height: 1.5,
                                    ),
                                    const SizedBox(height: 20),

                                    // Verification bar
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.08),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.verified,
                                            size: 14,
                                            color: AppTheme.neonAccent,
                                          ),
                                          const SizedBox(width: 6),
                                          AppText.spaceMono(
                                            'VERIFIED AUTHENTIC',
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: AppTheme.neonAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignerStat(
      BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.surface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bebas(
            value,
            fontSize: 28,
            letterSpacing: 2.0,
            color: AppTheme.neonAccent,
          ),
          const SizedBox(height: 4),
          AppText.spaceMono(
            label,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            height: 1.4,
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─── MARQUEE WIDGET ────────────────────────────────────────────
/// A simple auto-scrolling horizontal marquee for premium brand feel.
class _MarqueeWidget extends StatefulWidget {
  final Widget child;

  const _MarqueeWidget({required this.child});

  @override
  State<_MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<_MarqueeWidget>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(_scroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _animController.repeat();
      }
    });
  }

  void _scroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = maxScroll * _animController.value;
      _scrollController.jumpTo(currentScroll);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          widget.child,
          widget.child,
        ],
      ),
    );
  }
}
