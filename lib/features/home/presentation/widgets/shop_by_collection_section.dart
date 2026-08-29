import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/models/collection_model.dart';

class ShopByCollectionSection extends ConsumerStatefulWidget {
  const ShopByCollectionSection({super.key});

  @override
  ConsumerState<ShopByCollectionSection> createState() =>
      _ShopByCollectionSectionState();
}

class _ShopByCollectionSectionState extends ConsumerState<ShopByCollectionSection> {
  final ScrollController _scrollController = ScrollController();


  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 260,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 260,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final primaryColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    final collectionsAsync = ref.watch(collectionsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p32),
      width: double.infinity,
      child: WebConstrainedBox(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64.0 : 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText.bebas(
                    'SHOP BY COLLECTION',
                    fontSize: isDesktop ? 42 : 28,
                    letterSpacing: 2.0,
                    color: primaryColor,
                  ),
                  if (isDesktop)
                    Row(
                      children: [
                        _buildArrowButton(
                          icon: Icons.chevron_left,
                          onPressed: _scrollLeft,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                        ),
                        const SizedBox(width: AppSizes.p16),
                        _buildArrowButton(
                          icon: Icons.chevron_right,
                          onPressed: _scrollRight,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // Horizontal List
            SizedBox(
              height: isDesktop ? 320 : 250,
              child: collectionsAsync.when(
                data: (collections) {
                  if (collections.isEmpty) {
                    return Center(
                      child: AppText.spaceMono(
                        'No collections available.',
                        color: primaryColor,
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64.0 : 16.0),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSizes.p16),
                        child: _CollectionCard(
                          data: collections[index],
                          isDesktop: isDesktop,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: AppText.spaceMono(
                    'Failed to load collections',
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color primaryColor,
    required Color surfaceColor,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p8),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor, width: 2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryColor),
      ),
    );
  }
}

class _CollectionCard extends StatefulWidget {
  final CollectionModel data;
  final bool isDesktop;

  const _CollectionCard({
    required this.data,
    required this.isDesktop,
  });

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.onSurface;
    final width = widget.isDesktop ? 250.0 : 190.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primaryColor,
            width: _isHovered ? 3 : 2, // Brutalist thick borders
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              widget.data.imageUrl,
              fit: BoxFit.cover,
            ),
            // Dark Gradient Overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Text Content
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText.spaceMono(
                          widget.data.title,
                          fontSize: widget.isDesktop ? 18 : 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AppText.spaceMono(
                        widget.data.count,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText.spaceMono(
                          widget.data.subtitle,
                          fontSize: widget.isDesktop ? 12 : 10,
                          color: Colors.white70,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        transform: Matrix4.translationValues(
                          _isHovered ? 4.0 : 0.0,
                          0,
                          0,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
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
    ),
    );
  }
}
