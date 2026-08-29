import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../home/data/models/collection_model.dart';
import '../../../home/data/repositories/collection_repository.dart';

class AdminCollectionsPage extends ConsumerStatefulWidget {
  const AdminCollectionsPage({super.key});

  @override
  ConsumerState<AdminCollectionsPage> createState() =>
      _AdminCollectionsPageState();
}

class _AdminCollectionsPageState extends ConsumerState<AdminCollectionsPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final collectionsState = ref.watch(collectionsProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(collectionsProvider);
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
                    'MANAGE COLLECTIONS',
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
                        _showCollectionDialog(context, null);
                      },
                      icon: const Icon(Icons.add),
                      label: AppText.spaceMono(
                        'ADD COLLECTION',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              collectionsState.when(
                data: (collections) {
                  if (collections.isEmpty) {
                    return AppText.spaceMono(
                      'No collections found. Add one above.',
                      color: textColor.withValues(alpha: 0.5),
                    );
                  }
                  return _buildCollectionsTable(
                    collections,
                    textColor,
                    surfaceColor,
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: AppText.spaceMono('Error: $e', color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionsTable(
    List<CollectionModel> collections,
    Color textColor,
    Color surfaceColor,
  ) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: textColor, width: 2)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(textColor),
          headingTextStyle: TextStyle(
            color: surfaceColor,
            fontFamily: 'SpaceMono',
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: TextStyle(color: textColor, fontFamily: 'SpaceMono'),
          columns: const [
            DataColumn(label: Text('IMAGE')),
            DataColumn(label: Text('TITLE')),
            DataColumn(label: Text('SUBTITLE')),
            DataColumn(label: Text('COUNT')),
            DataColumn(label: Text('SORT ORDER')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: collections.map((collection) {
            return DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: textColor),
                      ),
                      child: AppImage(
                        imageUrl: collection.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(collection.title)),
                DataCell(Text(collection.subtitle)),
                DataCell(Text(collection.count)),
                DataCell(Text(collection.sortOrder.toString())),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            _showCollectionDialog(context, collection),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteCollection(collection.id),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _deleteCollection(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: AppText.bebas('DELETE COLLECTION', fontSize: 24),
        content: AppText.spaceMono(
          'Are you sure you want to delete this collection?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText.spaceMono('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: AppText.spaceMono('DELETE', color: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(collectionRepositoryProvider).deleteCollection(id);
        ref.invalidate(collectionsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Collection deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting collection: $e')),
          );
        }
      }
    }
  }

  Future<void> _showCollectionDialog(
    BuildContext context,
    CollectionModel? collection,
  ) async {
    final isEditing = collection != null;
    final titleController = TextEditingController(text: collection?.title);
    final subtitleController = TextEditingController(
      text: collection?.subtitle,
    );
    final countController = TextEditingController(text: collection?.count);
    final sortOrderController = TextEditingController(
      text: collection?.sortOrder.toString() ?? '0',
    );

    String imageUrl = collection?.imageUrl ?? '';
    dynamic selectedFile; // File (mobile) or Uint8List (web)
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage() async {
              final XFile? image = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                if (kIsWeb) {
                  final bytes = await image.readAsBytes();
                  setState(() {
                    selectedFile = bytes;
                  });
                } else {
                  setState(() {
                    selectedFile = File(image.path);
                  });
                }
              }
            }

            Future<void> save() async {
              if (titleController.text.isEmpty ||
                  countController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title and Count are required')),
                );
                return;
              }

              if (imageUrl.isEmpty && selectedFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select an image')),
                );
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                final repo = ref.read(collectionRepositoryProvider);

                String finalImageUrl = imageUrl;

                if (selectedFile != null) {
                  final fileName =
                      '${DateTime.now().millisecondsSinceEpoch}_${titleController.text.replaceAll(' ', '_')}.jpg';
                  finalImageUrl = await repo.uploadCollectionImage(
                    fileName,
                    selectedFile,
                  );
                }

                final newCollection = CollectionModel(
                  id: isEditing ? collection.id : '',
                  title: titleController.text,
                  subtitle: subtitleController.text,
                  count: countController.text,
                  imageUrl: finalImageUrl,
                  sortOrder: int.tryParse(sortOrderController.text) ?? 0,
                );

                if (isEditing) {
                  await repo.updateCollection(newCollection);
                } else {
                  await repo.addCollection(newCollection);
                }

                ref.invalidate(collectionsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                setState(() {
                  isLoading = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving collection: $e')),
                  );
                }
              }
            }

            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: AppText.bebas(
                isEditing ? 'EDIT COLLECTION' : 'ADD COLLECTION',
                fontSize: 24,
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                          child: selectedFile != null
                              ? (kIsWeb
                                    ? Image.memory(
                                        selectedFile,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        selectedFile,
                                        fit: BoxFit.cover,
                                      ))
                              : (imageUrl.isNotEmpty
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text('Upload Collection Image'),
                                        ],
                                      )),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title (e.g. All products)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                          labelText:
                              'Subtitle (e.g. Check out all our products)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: countController,
                        decoration: const InputDecoration(
                          labelText: 'Count (e.g. 175)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: sortOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sort Order (e.g. 0)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: AppText.spaceMono('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  onPressed: isLoading ? null : save,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : AppText.spaceMono('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
