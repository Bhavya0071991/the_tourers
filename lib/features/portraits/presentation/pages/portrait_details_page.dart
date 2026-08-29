import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../../../home/presentation/widgets/footer_section.dart';
import '../../../home/presentation/widgets/promo_banner.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../providers/portraits_provider.dart';
import '../widgets/room_visualizer_widget.dart';

class PortraitDetailsPage extends ConsumerStatefulWidget {
  final String portraitId;

  const PortraitDetailsPage({super.key, required this.portraitId});

  @override
  ConsumerState<PortraitDetailsPage> createState() =>
      _PortraitDetailsPageState();
}

class _PortraitDetailsPageState extends ConsumerState<PortraitDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _galleryKey = GlobalKey();

  void _scrollToGallery() {
    if (_galleryKey.currentContext != null) {
      Scrollable.ensureVisible(
        _galleryKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildResponsiveColumn(bool isDesktop, int flex, Widget child) {
    if (isDesktop) {
      return Expanded(flex: flex, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final designAsync = ref.watch(portraitByIdProvider(widget.portraitId));
    final customizerState = ref.watch(portraitCustomizerProvider);
    final customizerNotifier = ref.read(portraitCustomizerProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const PromoBanner(),
          const WebConstrainedBox(child: CustomAppBar(isTransparent: false)),
          Expanded(
            child: designAsync.when(
              data: (design) {
                if (design == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText.bebas(
                          'PORTRAIT DESIGN NOT FOUND',
                          fontSize: 24,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          child: AppText.spaceMono('GO BACK'),
                        ),
                      ],
                    ),
                  );
                }

                // Add to Bag action handler
                void addToBag() async {
                  try {
                    final size = customizerState.selectedSize;
                    final frame = customizerState.selectedFrame;
                    final productModel = design.toProduct(
                      selectedSize: size,
                      selectedFrame: frame,
                    );

                    await ref
                        .read(cartProvider.notifier)
                        .addItem(
                          productModel.toMap(),
                          size,
                          customText: 'Frame: $frame',
                        );

                    if (context.mounted) {
                      AppSnackBar.show(
                        context,
                        'SECURE ADD: DESIGN [${design.name}] ($size / $frame FRAME) TO BAG!',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppSnackBar.show(
                        context,
                        'ERROR ADDING PRINT TO BAG: $e',
                      );
                    }
                  }
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── BREADCRUMB / BACK HEADER ───
                      WebConstrainedBox(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 64.0 : 24.0,
                          vertical: 24.0,
                        ),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.arrow_back,
                                color: theme.colorScheme.onSurface,
                                size: 16,
                              ),
                              label: AppText.spaceMono(
                                'BACK TO PRINT LAB',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                side: BorderSide(
                                  color: theme.colorScheme.onSurface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Edition badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.neonAccent.withValues(
                                  alpha: 0.1,
                                ),
                                border: Border.all(
                                  color: AppTheme.neonAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: AppTheme.neonAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  AppText.spaceMono(
                                    'LIMITED EDITION',
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

                      // ─── MAIN TWO-COLUMN LAYOUT ───
                      WebConstrainedBox(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 64.0 : 24.0,
                        ),
                        child: Flex(
                          direction: isDesktop
                              ? Axis.horizontal
                              : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT: Interactive Room Visualizer
                            _buildResponsiveColumn(
                              isDesktop,
                              5,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RoomVisualizerWidget(
                                    imageUrl: design.imageUrl,
                                    selectedSize: customizerState.selectedSize,
                                    selectedFrame:
                                        customizerState.selectedFrame,
                                  ),
                                  const SizedBox(height: 24),
                                  // Mini-gallery preview (Desktop Only)
                                  if (isDesktop) _buildMiniGallery(context),
                                ],
                              ),
                            ),

                            if (isDesktop)
                              const SizedBox(width: 64)
                            else
                              const SizedBox(height: 48),

                            // RIGHT: Product Customizer + Purchase
                            _buildResponsiveColumn(
                              isDesktop,
                              4,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category Tag
                                  Container(
                                    color: theme.colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: AppText.spaceMono(
                                      'THEME // ${design.category}'
                                          .toUpperCase(),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.surface,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Title
                                  AppText.bebas(
                                    design.name,
                                    fontSize: isDesktop ? 48 : 34,
                                    letterSpacing: 2.0,
                                  ),
                                  const SizedBox(height: 4),

                                  // Designer credit line
                                  Row(
                                    children: [
                                      AppText.spaceMono(
                                        'BY ',
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                      AppText.spaceMono(
                                        design.designerName.toUpperCase(),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.neonAccent,
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: AppTheme.neonAccent.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Price tag row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        design.price,
                                        style: GoogleFonts.spaceMono(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      if (design.originalPrice != null) ...[
                                        const SizedBox(width: 12),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                          child: Text(
                                            design.originalPrice!,
                                            style: GoogleFonts.spaceMono(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.35),
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: AppSizes.p24),
                                  Divider(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.08),
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: AppSizes.p24),

                                  // Description
                                  AppText.spaceMono(
                                    design.description,
                                    fontSize: 13,
                                    height: 1.7,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),

                                  const SizedBox(height: AppSizes.p32),

                                  // ─── STEP 1: FRAME STYLE ───
                                  _buildSectionLabel(
                                    context,
                                    '01',
                                    'SELECT FRAME STYLE',
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children:
                                        [
                                          'Canvas',
                                          'Posters',
                                          'Black Frame',
                                        ].map((frame) {
                                          final isSelected =
                                              customizerState.selectedFrame ==
                                              frame;
                                          return BrutalistHoverWidget(
                                            shadowColor:
                                                theme.colorScheme.onSurface,
                                            offset: const Offset(3, 3),
                                            child: InkWell(
                                              onTap: () => customizerNotifier
                                                  .updateFrame(frame),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? theme
                                                            .colorScheme
                                                            .onSurface
                                                      : theme
                                                            .colorScheme
                                                            .surface,
                                                  border: Border.all(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (frame == 'Canvas') ...[
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: AppTheme
                                                                  .neonAccent,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                    ],
                                                    AppText.spaceMono(
                                                      frame.toUpperCase(),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isSelected
                                                          ? theme
                                                                .colorScheme
                                                                .surface
                                                          : theme
                                                                .colorScheme
                                                                .onSurface,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),

                                  const SizedBox(height: AppSizes.p32),

                                  // ─── STEP 2: SIZE SELECTION ───
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildSectionLabel(
                                        context,
                                        '02',
                                        'SELECT DIMENSIONS',
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppTheme.neonAccent
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: AppText.spaceMono(
                                          'FREE MOUNTING',
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                          color: AppTheme.neonAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: ['A4', 'A3', 'A2'].map((size) {
                                      final isSelected =
                                          customizerState.selectedSize == size;

                                      String dimensionDesc = '21.0 x 29.7 CM';
                                      if (size == 'A3') {
                                        dimensionDesc = '29.7 x 42.0 CM';
                                      }
                                      if (size == 'A2') {
                                        dimensionDesc = '42.0 x 59.4 CM';
                                      }

                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: BrutalistHoverWidget(
                                            shadowColor:
                                                theme.colorScheme.onSurface,
                                            offset: const Offset(3, 3),
                                            child: InkWell(
                                              onTap: () => customizerNotifier
                                                  .updateSize(size),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? theme
                                                            .colorScheme
                                                            .onSurface
                                                      : theme
                                                            .colorScheme
                                                            .surface,
                                                  border: Border.all(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    AppText.spaceMono(
                                                      size,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isSelected
                                                          ? theme
                                                                .colorScheme
                                                                .surface
                                                          : theme
                                                                .colorScheme
                                                                .onSurface,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    AppText.spaceMono(
                                                      dimensionDesc,
                                                      fontSize: 8,
                                                      color: isSelected
                                                          ? theme
                                                                .colorScheme
                                                                .surface
                                                                .withValues(
                                                                  alpha: 0.6,
                                                                )
                                                          : theme
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                  alpha: 0.6,
                                                                ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: AppSizes.p48),
                                  // ─── ADD TO BAG CTA (Desktop Only) ───
                                  if (isDesktop) ...[
                                    BrutalistHoverWidget(
                                    shadowColor: AppTheme.neonAccent,
                                    offset: const Offset(6, 6),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: addToBag,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.onSurface,
                                          foregroundColor:
                                              theme.colorScheme.surface,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 22,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AppText.bebas(
                                              'ADD TO BAG',
                                              fontSize: 20,
                                              letterSpacing: 2.0,
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              Icons.arrow_forward,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: AppSizes.p48),

                                  // Mini-gallery preview (Mobile Only)
                                  if (!isDesktop) ...[
                                    _buildMiniGallery(context),
                                    const SizedBox(height: AppSizes.p48),
                                  ],

                                  // ─── DESIGNER SEAL CARD ───
                                  _buildDesignerSeal(
                                    context,
                                    design.designerName,
                                    design.designerBio,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.p64),

                      // ─── MORE VIEWS / GALLERY SECTION ───
                      Container(
                        key: _galleryKey,
                        child: _buildGallerySection(context, design, isDesktop),
                      ),

                      const SizedBox(height: AppSizes.p64),
                      const FooterSection(),
                    ],
                  ),
                ),
              ),
                if (!isDesktop)
                  _buildMobileBottomBar(
                    context,
                    design,
                    customizerState,
                    addToBag,
                  ),
              ],
            );
              },
              loading: () => const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error loading details: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP LABEL BUILDER ──────────────────────────────────────
  Widget _buildSectionLabel(BuildContext context, String number, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: theme.colorScheme.onSurface),
          child: AppText.spaceMono(
            number,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.surface,
          ),
        ),
        const SizedBox(width: 10),
        AppText.spaceMono(
          label,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ],
    );
  }

  // ─── DESIGNER SEAL ───────────────────────────────────────────
  Widget _buildDesignerSeal(BuildContext context, String designer, String bio) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.colorScheme.onSurface, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: theme.colorScheme.onSurface,
            child: Row(
              children: [
                const Icon(
                  Icons.verified,
                  color: AppTheme.neonAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                AppText.spaceMono(
                  'CERTIFIED DESIGN BY ${designer.toUpperCase()}',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.surface,
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.spaceMono(
                  bio,
                  fontSize: 11,
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 20),

                // Authenticity + Signature Row
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.spaceMono(
                            'AUTHENTICITY',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.neonAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AppText.spaceMono(
                                '100% VERIFIED',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neonAccent,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Cursive signature
                      Row(
                        children: [
                          AppText.spaceMono(
                            'SIGN: ',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.25,
                            ),
                          ),
                          Text(
                            designer,
                            style: GoogleFonts.greatVibes(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── GALLERY SECTION ─────────────────────────────────────────
  Widget _buildGallerySection(
    BuildContext context,
    dynamic design,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);

    // Hardcoded dummy gallery images for now until backend supports it
    final List<String> dummyGalleryImages = [
      'https://images.unsplash.com/photo-1594026112284-02bb6f3352fe?q=80&w=2670&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?q=80&w=2564&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?q=80&w=2680&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=2669&auto=format&fit=crop',
    ];

    return WebConstrainedBox(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bebas(
            'MORE VIEWS',
            fontSize: isDesktop ? 36 : 28,
            letterSpacing: 2.0,
          ),
          const SizedBox(height: 8),
          AppText.spaceMono(
            'LIFESTYLE & DETAIL SHOTS',
            fontSize: 12,
            letterSpacing: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              childAspectRatio: 1.5,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: dummyGalleryImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(24),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 4),
                              color: theme.colorScheme.surface,
                            ),
                            child: InteractiveViewer(
                              child: Image.network(
                                dummyGalleryImages[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -20,
                            right: -20,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.pureBlack,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface,
                      width: 2,
                    ),
                  ),
                  child: Image.network(
                    dummyGalleryImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── MINI GALLERY (Conditionally Placed) ───────────────────
  Widget _buildMiniGallery(BuildContext context) {
    final theme = Theme.of(context);
    final dummyGalleryImages = [
      'https://images.unsplash.com/photo-1594026112284-02bb6f3352fe?q=80&w=2670&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?q=80&w=2564&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?q=80&w=2680&auto=format&fit=crop',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.spaceMono(
              'LIFESTYLE PREVIEWS',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            InkWell(
              onTap: _scrollToGallery,
              child: AppText.spaceMono(
                'VIEW ALL',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: dummyGalleryImages.map((img) {
            return Expanded(
              child: GestureDetector(
                onTap: _scrollToGallery,
                child: Container(
                  height: 90,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface,
                      width: 1,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── STICKY BOTTOM BAR (Mobile/Tablet) ─────────────────────────
  Widget _buildMobileBottomBar(
    BuildContext context,
    dynamic design,
    dynamic customizerState,
    VoidCallback addToBag,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.spaceMono(
                    'TOTAL',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        design.price,
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (design.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            design.originalPrice!,
                            style: GoogleFonts.spaceMono(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.35),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Add to Bag Button
            Expanded(
              child: BrutalistHoverWidget(
                shadowColor: AppTheme.neonAccent,
                offset: const Offset(4, 4),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: addToBag,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface,
                      foregroundColor: theme.colorScheme.surface,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText.bebas(
                          'ADD TO BAG',
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
