import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/router/app_paths.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../product/providers/product_provider.dart';
import '../../../product/domain/entities/product.dart';
import '../../../../core/widgets/app_image.dart';
import '../../providers/storage_provider.dart';

class AdminAddProductPage extends ConsumerStatefulWidget {
  final String? productId;

  const AdminAddProductPage({super.key, this.productId});

  @override
  ConsumerState<AdminAddProductPage> createState() =>
      _AdminAddProductPageState();
}

class _AdminAddProductPageState extends ConsumerState<AdminAddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController(text: 'NEW');

  String _selectedGender = 'mens';
  String _selectedCategory = 'design';

  final List<_ColorVariantData> _colorVariants = [];
  _ImageData? _designImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Defer reading provider until after init
      Future.microtask(() async {
        try {
          final product = await ref.read(productByIdProvider(widget.productId!).future);
          if (product != null) {
            if (!mounted) return;
            setState(() {
              _nameController.text = product.name;
              _priceController.text = product.price.replaceAll('₹', '');
              _originalPriceController.text =
                  product.originalPrice?.replaceAll('₹', '') ?? '';
              _descriptionController.text = product.description ?? '';
              _tagController.text = product.tag ?? '';
              _selectedGender = product.gender;
              _selectedCategory = product.category;

              if (product.colorImages.isNotEmpty) {
                product.colorImages.forEach((color, urls) {
                  _colorVariants.add(_ColorVariantData(color, urls.map((url) => _ImageData(url: url)).toList()));
                });
              } else if (product.images.isNotEmpty) {
                _colorVariants.add(_ColorVariantData('Black', product.images.map((url) => _ImageData(url: url)).toList()));
              } else if (product.image != null) {
                _colorVariants.add(_ColorVariantData('Black', [_ImageData(url: product.image!)]));
              }
              if (product.designImage != null) {
                _designImage = _ImageData(url: product.designImage!);
              }
            });
          }
        } catch (e) {
          // Product not found
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImages(int variantIndex) async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1080,
      );

      if (selectedImages.isNotEmpty) {
        if (_colorVariants[variantIndex].images.length + selectedImages.length > 10) {
          if (!context.mounted) return;
          AppSnackBar.show(context, 'You can only upload up to 10 images.');
          return;
        }

        for (var image in selectedImages) {
          if (!context.mounted) continue;
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Theme.of(context).colorScheme.surface,
                toolbarWidgetColor: Theme.of(context).colorScheme.onSurface,
                lockAspectRatio: true,
              ),
              IOSUiSettings(
                title: 'Crop Image',
                aspectRatioLockEnabled: true,
                resetAspectRatioEnabled: false,
                aspectRatioPickerButtonHidden: true,
              ),
              WebUiSettings(
                context: context,
                presentStyle: WebPresentStyle.page,
              ),
            ],
          );

          if (croppedFile != null) {
            final bytes = await croppedFile.readAsBytes();
            _colorVariants[variantIndex].images.add(
              _ImageData(bytes: bytes, extension: image.name.split('.').last),
            );
          }
        }
        setState(() {});
      }
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(context, 'Failed to pick images: $e');
    }
  }

  Future<void> _pickDesignImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (selectedImage != null) {
        final bytes = await selectedImage.readAsBytes();
        setState(() {
          _designImage = _ImageData(
            bytes: bytes,
            extension: selectedImage.name.split('.').last,
          );
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(context, 'Failed to pick design image: $e');
    }
  }

  void _removeImage(int variantIndex, int imageIndex) {
    setState(() {
      _colorVariants[variantIndex].images.removeAt(imageIndex);
    });
  }
  
  void _addColorVariant() {
    setState(() {
      _colorVariants.add(_ColorVariantData('Color ${_colorVariants.length + 1}', []));
    });
  }

  void _removeColorVariant(int index) {
    setState(() {
      _colorVariants.removeAt(index);
    });
  }


  void _removeDesignImage() {
    setState(() {
      _designImage = null;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_colorVariants.isEmpty || _colorVariants.any((v) => v.images.length < 2)) {
        AppSnackBar.show(context, 'Please add at least one color variant and upload at least 2 images for each.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        Map<String, List<String>> uploadedColorImages = {};
        for (var variant in _colorVariants) {
          List<String> variantUrls = [];
          for (var img in variant.images) {
            if (img.isNetwork) {
              variantUrls.add(img.url!);
            } else if (img.bytes != null) {
              final ext = img.extension ?? 'png';
              final fileName = 'products/${const Uuid().v4()}.$ext';
              final publicUrl = await ref
                  .read(storageRepositoryProvider)
                  .uploadBinary('product-images', fileName, img.bytes!);
              variantUrls.add(publicUrl);
            }
          }
          uploadedColorImages[variant.name] = variantUrls;
        }
        List<String> uploadedUrls = uploadedColorImages.values.first; // Fallback for 'images'


        String? designUrl;
        if (_designImage != null) {
          if (_designImage!.isNetwork) {
            designUrl = _designImage!.url;
          } else if (_designImage!.bytes != null) {
            final ext = _designImage!.extension ?? 'png';
            final fileName = 'designs/${const Uuid().v4()}.$ext';

            designUrl = await ref
                .read(storageRepositoryProvider)
                .uploadBinary('qikink-designs', fileName, _designImage!.bytes!);
          }
        }

        final product = Product(
          id: isEditing ? widget.productId! : '',
          name: _nameController.text.trim(),
          price: '₹${_priceController.text.trim()}',
          originalPrice: _originalPriceController.text.isNotEmpty
              ? '₹${_originalPriceController.text.trim()}'
              : null,
          description: _descriptionController.text.trim(),
          image: uploadedUrls.first,
          images: uploadedUrls,
          colorImages: uploadedColorImages,
          designImage: designUrl,
          tag: _tagController.text.trim(),
          gender: _selectedGender,
          category: _selectedCategory,
        );

        if (isEditing) {
          await ref.read(productOperationsProvider.notifier).updateProduct(product);
          if (!context.mounted) return;
          AppSnackBar.show(context, 'Product updated successfully!');
        } else {
          await ref.read(productOperationsProvider.notifier).addProduct(product);
          if (!context.mounted) return;
          AppSnackBar.show(context, 'Product added successfully!');
        }

        if (context.mounted) context.go(AppPaths.adminProducts);
      } catch (e) {
        if (!context.mounted) return;
        AppSnackBar.show(context, 'Failed to save product: $e');
      } finally {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteProduct() async {
    if (!isEditing) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(productOperationsProvider.notifier).deleteProduct(widget.productId!);
      if (!context.mounted) return;
      AppSnackBar.show(context, 'Product deleted successfully!');
      context.go(AppPaths.adminProducts);
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(context, 'Failed to delete product: $e');
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.go(AppPaths.adminProducts),
        ),
        title: AppText.bebas(
          isEditing ? 'EDIT PRODUCT' : 'ADD NEW PRODUCT',
          fontSize: 24,
          color: textColor,
          letterSpacing: 1.5,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: textColor, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('PRODUCT NAME', textColor),
                _buildTextField(
                  _nameController,
                  'e.g. OVERSIZED GRAPHIC TEE',
                  textColor,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('PRICE (₹)', textColor),
                          _buildTextField(
                            _priceController,
                            'e.g. 1499',
                            textColor,
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(
                            'ORIGINAL PRICE (₹) (Optional)',
                            textColor,
                          ),
                          _buildTextField(
                            _originalPriceController,
                            'e.g. 1999',
                            textColor,
                            isNumber: true,
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('GENDER', textColor),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: textColor, width: 2),
                              color: surfaceColor,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: textColor,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'mens',
                                    child: Text(
                                      'MENS',
                                      style: TextStyle(fontFamily: 'SpaceMono'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'womens',
                                    child: Text(
                                      'WOMENS',
                                      style: TextStyle(fontFamily: 'SpaceMono'),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedGender = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CATEGORY', textColor),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: textColor, width: 2),
                              color: surfaceColor,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: textColor,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'design',
                                    child: Text(
                                      'DESIGN',
                                      style: TextStyle(fontFamily: 'SpaceMono'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'quotes',
                                    child: Text(
                                      'QUOTES',
                                      style: TextStyle(fontFamily: 'SpaceMono'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'anime',
                                    child: Text(
                                      'ANIME',
                                      style: TextStyle(fontFamily: 'SpaceMono'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'custom',
                                    child: Text(
                                      'CUSTOM',
                                      style: TextStyle(fontFamily: 'SpaceMono'),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCategory = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('TAG', textColor),
                          _buildTextField(
                            _tagController,
                            'e.g. DESIGNS, CUSTOM',
                            textColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Color Variants Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('COLOR VARIANTS', textColor),
                    BrutalistHoverWidget(
                      shadowColor: textColor.withValues(alpha: 0.2),
                      offset: const Offset(2, 2),
                      child: ElevatedButton.icon(
                        onPressed: _addColorVariant,
                        icon: Icon(Icons.add, color: surfaceColor),
                        label: AppText.spaceMono(
                          'ADD COLOR',
                          color: surfaceColor,
                          fontWeight: FontWeight.bold,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ...List.generate(_colorVariants.length, (variantIndex) {
                  final variant = _colorVariants[variantIndex];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: textColor, width: 2),
                      color: surfaceColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: ['Black', 'White', 'Grey', 'Navy', 'Red', 'Green'].contains(variant.name) ? variant.name : 'Black',
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down, color: textColor),
                                  items: ['Black', 'White', 'Grey', 'Navy', 'Red', 'Green'].map((colorName) {
                                    return DropdownMenuItem(
                                      value: colorName,
                                      child: AppText.spaceMono(colorName, color: textColor),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => variant.name = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeColorVariant(variantIndex),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText.spaceMono('Images (${variant.images.length}/10)', fontSize: 12, color: textColor),
                            TextButton.icon(
                              onPressed: () => _pickImages(variantIndex),
                              icon: Icon(Icons.upload, size: 16, color: textColor),
                              label: AppText.spaceMono('UPLOAD', fontSize: 12, color: textColor),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (variant.images.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: variant.images.length,
                            itemBuilder: (context, imgIndex) {
                              final img = variant.images[imgIndex];
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: textColor, width: 2),
                                    ),
                                    child: img.isNetwork
                                        ? AppImage(imageUrl: img.url!, fit: BoxFit.cover)
                                        : Image.memory(img.bytes!, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: InkWell(
                                      onTap: () => _removeImage(variantIndex, imgIndex),
                                      child: Container(
                                        color: textColor,
                                        padding: const EdgeInsets.all(2),
                                        child: Icon(Icons.close, color: surfaceColor, size: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Design Image Picker Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('TRANSPARENT DESIGN (PNG)', textColor),
                        AppText.spaceMono(
                          'Upload the raw design file for Qikink printing.',
                          fontSize: 12,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                    BrutalistHoverWidget(
                      shadowColor: textColor.withValues(alpha: 0.2),
                      offset: const Offset(2, 2),
                      child: ElevatedButton.icon(
                        onPressed: _pickDesignImage,
                        icon: Icon(Icons.upload_file, color: surfaceColor),
                        label: AppText.spaceMono(
                          _designImage != null
                              ? 'CHANGE DESIGN'
                              : 'UPLOAD DESIGN',
                          color: surfaceColor,
                          fontWeight: FontWeight.bold,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_designImage != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: textColor, width: 2),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: _designImage!.isNetwork
                              ? AppImage(
                                  imageUrl: _designImage!.url!,
                                  fit: BoxFit.contain,
                                )
                              : Image.memory(
                                  _designImage!.bytes!,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: _removeDesignImage,
                            child: Container(
                              color: textColor,
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                color: surfaceColor,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                _buildLabel('DESCRIPTION', textColor),
                _buildTextField(
                  _descriptionController,
                  'Enter product description...',
                  textColor,
                  maxLines: 4,
                ),
                const SizedBox(height: 48),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: BrutalistHoverWidget(
                        shadowColor: textColor.withValues(alpha: 0.2),
                        offset: const Offset(4, 4),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textColor,
                            foregroundColor: surfaceColor,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: surfaceColor,
                                    strokeWidth: 2,
                                  ),
                                )
                              : AppText.bebas(
                                  isEditing ? 'UPDATE PRODUCT' : 'SAVE PRODUCT',
                                  fontSize: 24,
                                  letterSpacing: 2.0,
                                ),
                        ),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: BrutalistHoverWidget(
                          shadowColor: Colors.red.withValues(alpha: 0.2),
                          offset: const Offset(4, 4),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _deleteProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : AppText.bebas(
                                    'DELETE',
                                    fontSize: 24,
                                    letterSpacing: 2.0,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppText.spaceMono(
        text,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    Color color, {
    bool isNumber = false,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 14,
          color: color.withValues(alpha: 0.3),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }
}

class _ColorVariantData {
  String name;
  List<_ImageData> images;
  _ColorVariantData(this.name, this.images);
}

class _ImageData {
  final String? url;
  final Uint8List? bytes;
  final String? extension;

  _ImageData({this.url, this.bytes, this.extension});

  bool get isNetwork => url != null;
}
