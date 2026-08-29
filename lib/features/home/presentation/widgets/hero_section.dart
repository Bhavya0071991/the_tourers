import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/hero_view_model.dart';
import '../../providers/home_banner_provider.dart';

class HeroSection extends ConsumerStatefulWidget {
  const HeroSection({super.key});

  @override
  ConsumerState<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<HeroSection> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 900;

    // Listen to changes in the provider to trigger page animation
    ref.listen<HeroState>(heroViewModelProvider, (previous, next) {
      if (previous?.currentPage != next.currentPage &&
          _pageController.hasClients) {
        // If the PageController is not already animating to or at the target page
        if (_pageController.page?.round() != next.currentPage) {
          _pageController.animateToPage(
            next.currentPage,
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOutQuart,
          );
        }
      }
    });

    final currentPage = ref.watch(
      heroViewModelProvider.select((state) => state.currentPage),
    );

    // Edge-to-edge full height aesthetic
    final sectionHeight = isDesktop
        ? screenSize.height * 0.85
        : screenSize.height * 0.70;

    final bannersAsync = ref.watch(homeBannersProvider);

    return SizedBox(
      height: sectionHeight,
      width: double.infinity,
      child: bannersAsync.when(
        data: (banners) {
          if (banners.isEmpty) {
            return Container(
              color: Colors.black87,
              child: Center(
                child: AppText.bebas(
                  'NO BANNERS',
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            );
          }

          return Stack(
            children: [
              // 1. Background Parallax Carousel
              PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(), // Allow manual swipe
                onPageChanged: (index) {
                  // Update state when manually swiping
                  ref.read(heroViewModelProvider.notifier).setPage(index);
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final isActive = currentPage == index;
                  final banner = banners[index];

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double pageOffset = 0.0;
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        pageOffset = _pageController.page ?? 0.0;
                      } else {
                        pageOffset = currentPage.toDouble();
                      }

                      // Parallax effect calculation
                      final double offset = index - pageOffset;
                      final double parallaxOffset =
                          offset * (isDesktop ? 300 : 150);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Translate horizontally based on scroll offset
                          Transform.translate(
                            offset: Offset(parallaxOffset, 0),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 1.0,
                                end: isActive ? 1.08 : 1.0,
                              ),
                              duration: const Duration(seconds: 10),
                              curve: Curves.easeOutCubic,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: AppImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                memCacheWidth: isDesktop ? 1600 : 800,
                              ),
                            ),
                          ),

                          // Subtle gradient overlay (bottom to top)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.9),
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.4, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              // 2. Editorial Content Overlay with flutter_animate
              Positioned(
                left: isDesktop ? 80.0 : 24.0,
                top: isDesktop ? 80.0 : 64.0,
                child: SizedBox(
                  width: isDesktop
                      ? 700
                      : MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.bebas(
                            banners[currentPage % banners.length].title,
                            textAlign: TextAlign.left,
                            fontSize: isDesktop ? 80 : 38,
                            height: 0.85,
                            letterSpacing: isDesktop ? 4.0 : 2.0,
                            color: Colors.white,
                          )
                          .animate(key: ValueKey('title_$currentPage'))
                          .fadeIn(duration: 1000.ms, curve: Curves.easeOut)
                          .blurY(
                            begin: 10,
                            end: 0,
                            duration: 1000.ms,
                            curve: Curves.easeOut,
                          )
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 1000.ms,
                            curve: Curves.easeOutQuart,
                          ),

                      const SizedBox(height: AppSizes.p16),

                      AppText.spaceMono(
                            banners[currentPage % banners.length].subtitle,
                            fontSize: isDesktop ? 18 : 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: isDesktop ? 1.5 : 0.8,
                          )
                          .animate(key: ValueKey('subtitle_$currentPage'))
                          .fadeIn(duration: 800.ms, delay: 300.ms)
                          .slideX(
                            begin: -0.1,
                            end: 0,
                            duration: 800.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ),

              // Floating Character Image (Positioned directly above Explore Button)
              Positioned(
                left: isDesktop ? 80.0 : 24.0,
                bottom: isDesktop ? 150.0 : 130.0,
                child:
                    Image.asset(
                          'assets/images/himachali_boy.png',
                          height: isDesktop ? 170 : 60,
                          fit: BoxFit.contain,
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .slideY(
                          begin: -0.05,
                          end: 0.05,
                          duration: 2000.ms,
                          curve: Curves.easeInOutSine,
                        ),
              ),

              // 3. Explore Button (Bottom Left)
              Positioned(
                left: isDesktop ? 80.0 : 24.0,
                bottom: isDesktop ? 80.0 : 64.0,
                child:
                    OutlinedButton(
                          onPressed: () {
                            final link = banners[currentPage % banners.length]
                                .linkTarget;
                            if (link != null && link.isNotEmpty) {
                              context.go(link);
                            } else {
                              context.go(AppPaths.categoryId('mens'));
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.black;
                              }
                              return Colors.white;
                            }),
                            backgroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.white;
                              }
                              return Colors.transparent;
                            }),
                            side: WidgetStateProperty.all(
                              const BorderSide(color: Colors.white, width: 2),
                            ),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
                                horizontal: isDesktop ? 48 : 32,
                                vertical: isDesktop ? 24 : 16,
                              ),
                            ),
                            shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          child: AppText.spaceMono(
                            AppStrings.exploreBtn.toUpperCase(),
                            fontSize: isDesktop ? 16 : 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 600.ms)
                        .scaleXY(
                          begin: 0.95,
                          end: 1.0,
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                        ),
              ),

              // 4. Navigation Arrows (Tablet/Desktop)
              if (screenSize.width >= 768 && banners.length > 1) ...[
                Positioned(
                  left: 24,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNavButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: () {
                        final prevIndex =
                            currentPage == 0 ? banners.length - 1 : currentPage - 1;
                        ref.read(heroViewModelProvider.notifier).setPage(prevIndex);
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNavButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: () {
                        final nextIndex = (currentPage + 1) % banners.length;
                        ref.read(heroViewModelProvider.notifier).setPage(nextIndex);
                      },
                    ),
                  ),
                ),
              ],

              // 5. Animated "Scroll Down" Indicator
              if (isDesktop)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.spaceMono(
                        'SCROLL',
                        fontSize: 10,
                        letterSpacing: 3.0,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Container(
                            width: 2,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.7),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .slideY(
                            begin: -0.2,
                            end: 0.5,
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          )
                          .fade(begin: 0.0, end: 1.0, duration: 750.ms)
                          .then(delay: 0.ms)
                          .fade(begin: 1.0, end: 0.0, duration: 750.ms),
                    ],
                  ),
                ),

              // 4. Progressive Navigation Indicators
              Positioned(
                right: isDesktop ? 80.0 : 24.0,
                bottom: isDesktop ? 80.0 : 32.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(banners.length, (index) {
                    final isActive = currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.only(left: 12),
                      height: 2,
                      width: isActive ? 48 : 16,
                      alignment: Alignment.centerLeft,
                      color: Colors.white.withValues(alpha: 0.3),
                      child: isActive
                          ? TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 6),
                              builder: (context, value, child) {
                                return FractionallySizedBox(
                                  widthFactor: value,
                                  child: Container(color: Colors.white),
                                );
                              },
                            )
                          : const SizedBox(),
                    );
                  }),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, st) => const Center(child: Text('Failed to load banners')),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        splashRadius: 24,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
