import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../isar_service.dart';
import '../collections/image_post.dart';
import '../widgets/app_drawer.dart';

final layoutProvider = StateProvider((ref) => true);
final listProvider = StateProvider((ref) => 0);
final indexProvider = StateProvider((ref) => 0);
final countProvider = StateProvider((ref) => 0);
final player = AudioPlayer();
List<ImagePost> allImages = [];

class PageFileHome extends ConsumerWidget {
  const PageFileHome({super.key});

  void playSound(String source) async {
    await player.release();
    await player.play(AssetSource(source));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> loadAllImages() async {
      allImages = await isarService.getAllImages();
      ref.read(listProvider.notifier).state = allImages.length;
      ref.read(countProvider.notifier).state = allImages[ref.read(indexProvider)].like;
    }
    return FutureBuilder<void>(
      future: loadAllImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildContent(context, ref);
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('File App')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    void changeLayout() {
      ref.read(layoutProvider.notifier).state ^= true;
    }

    void switchImage(int increment) {
      int listLength = allImages.length;
      int targetIndex = (ref.read(indexProvider) + increment + listLength) % listLength;
      ref.read(indexProvider.notifier).state = targetIndex;
    }

    void updateImageLike(int newCount) {
      ImagePost updatedImage = allImages[ref.read(indexProvider)];
      updatedImage.setLike(newCount);
      isarService.updateImages(updatedImage.id, updatedImage);
      ref.read(countProvider.notifier).state = newCount;
    }

    Future<void> saveImageToAssetFolder(XFile pickedFile) async {
      File imageFile = File(pickedFile.path);
      final savedImage = await imageFile.copy('assets/images/${pickedFile.name}');
      if (kDebugMode) {
        print('Image saved to asset folder: ${savedImage.path}');
      }
    }

    Future<void> uploadImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        ImagePost newImage = ImagePost('assets/images/${pickedFile.name}');
        allImages.add(newImage);
        isarService.addNewImage(newImage);
        saveImageToAssetFolder(pickedFile);
        int listLength = allImages.length;
        ref.read(indexProvider.notifier).state = listLength - 1;
        ref.read(listProvider.notifier).state = listLength;
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('File App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: uploadImage,
            tooltip: 'Upload new image',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: ref.watch(layoutProvider)
                  ? const Icon(Icons.image)
                  : const Icon(Icons.window),
              onPressed: changeLayout,
              tooltip: 'Change layout',
            ),
          ),
        ],
      ),
      body: ref.watch(layoutProvider)
        ? ref.read(listProvider) == 0
          ? const Center(child: SizedBox(child: Text('No image')))
          : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 4.0, // Spacing between columns
              mainAxisSpacing: 4.0, // Spacing between rows
            ),
            itemCount: ref.watch(listProvider),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  ref.read(indexProvider.notifier).state = index;
                  changeLayout();
                },
                child: Image.file(
                  File(allImages[index].path),
                  fit: BoxFit.cover,
                ),
              );
            },
          )
        : ref.read(listProvider) == 0
          ? const Center(child: SizedBox(child: Text('No image')))
          : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () {
                        switchImage(-1);
                      },
                    ),
                    const SizedBox(width: 10.0),
                    SizedBox(
                      width: 400.0,
                      height: 400.0,
                      child:
                      Image.file(
                        File(allImages[ref.watch(indexProvider)].path),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () {
                        switchImage(1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Consumer(
                  builder: (context, ref, _) {
                    return Text(
                      'Likes: ${ref.watch(countProvider)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      floatingActionButton: ref.watch(layoutProvider) || ref.read(listProvider) == 0
        ? null
        : Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                final newCount = allImages[ref.read(indexProvider)].like - 1;
                if (newCount >= 0) {
                  updateImageLike(newCount);
                  playSound('sounds/voice_dislike.mp3'); // Play sound effect
                }
              },
              tooltip: 'Dislike',
              child: const Icon(Icons.thumb_down),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                final newCount = allImages[ref.read(indexProvider)].like + 1;
                if (newCount <= 10) {
                  updateImageLike(newCount);
                  playSound('sounds/voice_like.mp3'); // Play sound effect
                }
              },
              tooltip: 'Like',
              child: const Icon(Icons.thumb_up),
            ),
          ],
        ),
      drawer: const AppDrawer(selectedIndex: 1),
    );
  }
}