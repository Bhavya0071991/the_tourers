import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../home/data/models/home_banner.dart';
import '../../../home/data/repositories/home_banner_repository.dart';
import '../../../home/providers/home_banner_provider.dart';

class AdminBannersPage extends ConsumerStatefulWidget {
  const AdminBannersPage({super.key});

  @override
  ConsumerState<AdminBannersPage> createState() => _AdminBannersPageState();
}

class _AdminBannersPageState extends ConsumerState<AdminBannersPage> {
  @override
  Widget build(BuildContext context) {
    final bannersState = ref.watch(allHomeBannersProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allHomeBannersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.bebas(
                    'MANAGE BANNERS',
                    fontSize: 32,
                    letterSpacing: 2.0,
                    color: textColor,
                  ),
                  BrutalistHoverWidget(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: surfaceColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: BorderSide(color: textColor, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _showBannerDialog(context, null);
                      },
                      icon: const Icon(Icons.add),
                      label: AppText.spaceMono(
                        'ADD BANNER',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              bannersState.when(
                data: (banners) {
                  if (banners.isEmpty) {
                    return AppText.spaceMono(
                      'No banners found. Add one above.',
                      color: textColor.withValues(alpha: 0.5),
                    );
                  }
                  return _buildBannersTable(banners, textColor, surfaceColor);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannersTable(
    List<HomeBanner> banners,
    Color textColor,
    Color surfaceColor,
  ) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: textColor),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppText.spaceMono(
                    'IMG',
                    color: surfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: AppText.spaceMono(
                    'TITLE & SUBTITLE',
                    color: surfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AppText.spaceMono(
                    'STATUS',
                    color: surfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AppText.spaceMono(
                    'ORDER',
                    color: surfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AppText.spaceMono(
                    'ACTIONS',
                    color: surfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...banners.map((banner) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(top: BorderSide(color: textColor, width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: textColor, width: 1),
                      ),
                      child: AppImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bebas(
                          banner.title,
                          color: textColor,
                          fontSize: 20,
                          maxLines: 1,
                        ),
                        AppText.spaceMono(
                          banner.subtitle,
                          color: textColor,
                          fontSize: 12,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: banner.isActive ? Colors.green : Colors.red,
                        border: Border.all(color: textColor, width: 2),
                      ),
                      child: AppText.spaceMono(
                        banner.isActive ? 'ACTIVE' : 'INACTIVE',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: AppText.spaceMono(
                      banner.orderIndex.toString(),
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: textColor),
                          onPressed: () {
                            _showBannerDialog(context, banner);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteBanner(banner);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _deleteBanner(HomeBanner banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 2,
          ),
          borderRadius: BorderRadius.zero,
        ),
        title: AppText.bebas('DELETE BANNER?', fontSize: 24),
        content: AppText.spaceMono(
          'Are you sure you want to delete this banner?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText.spaceMono('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2,
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: AppText.spaceMono('DELETE', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(homeBannerRepositoryProvider).deleteBanner(banner.id);
        ref.invalidate(allHomeBannersProvider);
        ref.invalidate(homeBannersProvider);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Banner deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showBannerDialog(BuildContext context, HomeBanner? banner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BannerDialog(banner: banner),
    ).then((_) {
      ref.invalidate(allHomeBannersProvider);
      ref.invalidate(homeBannersProvider);
    });
  }
}

class _BannerDialog extends ConsumerStatefulWidget {
  final HomeBanner? banner;

  const _BannerDialog({this.banner});

  @override
  ConsumerState<_BannerDialog> createState() => _BannerDialogState();
}

class _BannerDialogState extends ConsumerState<_BannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _linkController = TextEditingController();
  final _orderController = TextEditingController(text: '0');
  bool _isActive = true;

  XFile? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _titleController.text = widget.banner!.title;
      _subtitleController.text = widget.banner!.subtitle;
      _linkController.text = widget.banner!.linkTarget ?? '';
      _orderController.text = widget.banner!.orderIndex.toString();
      _isActive = widget.banner!.isActive;
      _existingImageUrl = widget.banner!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _linkController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality:
          85, // Compresses file size significantly while retaining high visual quality
      maxWidth:
          1920, // Prevents massive 4K+ images from taking up unnecessary space
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(homeBannerRepositoryProvider);
      String imageUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        final ext = _selectedImage!.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';

        final bytes = await _selectedImage!.readAsBytes();

        String mimeType = 'image/jpeg';
        if (ext.toLowerCase() == 'png') mimeType = 'image/png';
        if (ext.toLowerCase() == 'webp') mimeType = 'image/webp';

        imageUrl = await repo.uploadBannerImage(
          bytes,
          fileName,
          contentType: mimeType,
        );
      }

      final banner = HomeBanner(
        id: widget.banner?.id ?? '', // backend gen uuid if creating
        imageUrl: imageUrl,
        title: _titleController.text,
        subtitle: _subtitleController.text,
        linkTarget: _linkController.text.isEmpty ? null : _linkController.text,
        isActive: _isActive,
        orderIndex: int.tryParse(_orderController.text) ?? 0,
        createdAt: widget.banner?.createdAt ?? DateTime.now(),
      );

      if (widget.banner == null) {
        await repo.createBanner(banner);
      } else {
        await repo.updateBanner(banner);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    final textColor = Theme.of(context).colorScheme.onSurface;

    final linkOptions = [
      {'name': 'Default (Men\'s)', 'value': ''},
      {'name': 'Men\'s Category', 'value': '/category/mens'},
      {'name': 'Women\'s Category', 'value': '/category/womens'},
      {'name': 'Kids Category', 'value': '/category/kids'},
      {'name': 'Portraits', 'value': '/portraits'},
      {'name': 'About Us', 'value': '/about'},
      {'name': 'AI Generator', 'value': '/generator'},
    ];

    if (!linkOptions.any((opt) => opt['value'] == _linkController.text)) {
      linkOptions.add({
        'name': 'Custom: ${_linkController.text}',
        'value': _linkController.text,
      });
    }

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: textColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      title: AppText.bebas(
        widget.banner == null ? 'ADD BANNER' : 'EDIT BANNER',
        fontSize: 24,
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: textColor, width: 2),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: _selectedImage != null
                        ? (kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ))
                        : (_existingImageUrl != null
                              ? AppImage(
                                  imageUrl: _existingImageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate, size: 40),
                                      SizedBox(height: 8),
                                      AppText.spaceMono('CLICK TO UPLOAD'),
                                    ],
                                  ),
                                )),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Subtitle required' : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _linkController.text,
                  decoration: const InputDecoration(
                    labelText: 'Link Target',
                    border: OutlineInputBorder(),
                  ),
                  items: linkOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt['value'],
                      child: Text(opt['name']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _linkController.text = val;
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _orderController,
                        decoration: const InputDecoration(
                          labelText: 'Order Index',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Is Active'),
                        value: _isActive,
                        onChanged: (val) {
                          setState(() {
                            _isActive = val ?? true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SAVE'),
        ),
      ],
    );
  }
}
