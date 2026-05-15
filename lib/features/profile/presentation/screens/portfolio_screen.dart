import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import '../providers/profile_provider.dart';

/// Worker portfolio management: list images, upload more, delete.
class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  bool _uploading = false;

  Future<void> _refresh() async {
    final me = ref.read(currentProfileProvider).valueOrNull;
    if (me != null) {
      ref.invalidate(workerPortfolioProvider(me.id));
    }
  }

  Future<void> _addImage() async {
    final me = ref.read(currentProfileProvider).valueOrNull;
    if (me == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .addPortfolioImage(workerId: me.id, filePath: picked.path);
      await _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: AppColors.neonRed),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _delete(String imageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Delete photo?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This will permanently remove the photo.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.neonRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref
          .read(profileRepositoryProvider)
          .deletePortfolioImage(imageId);
      await _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: AppColors.neonRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentProfileProvider).valueOrNull;
    if (me == null) {
      return const Scaffold(body: Center(child: LoadingShimmer()));
    }
    final imagesAsync = ref.watch(workerPortfolioProvider(me.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _addImage,
        icon: _uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.bgDark),
              )
            : const Icon(Icons.add_photo_alternate),
        label: const Text('Add'),
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.bgDark,
      ),
      body: imagesAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (images) {
          if (images.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined,
                            color: AppColors.textSecondary, size: 64),
                        SizedBox(height: 16),
                        Text('No portfolio photos yet',
                            style: TextStyle(
                                color: AppColors.textPrimary, fontSize: 16)),
                        SizedBox(height: 6),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            'Add photos of your previous work so customers can see what you do.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: images.length,
              itemBuilder: (ctx, i) {
                final img = images[i];
                final url = img['image_url'] as String?;
                final id = img['id'] as String;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: url == null
                          ? Container(color: AppColors.bgSurface)
                          : Image.network(url, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.white, size: 18),
                          onPressed: () => _delete(id),
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
