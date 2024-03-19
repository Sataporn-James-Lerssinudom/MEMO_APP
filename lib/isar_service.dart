import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../collections/image_post.dart';
import '../collections/memo_note.dart';

final isarService = IsarService();

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [
          MemoNoteSchema,
          ImagePostSchema,
        ], // TODO: Add schemas here
        directory: dir.path,
        inspector: true,
      );
      return isar;
    }
    return Future.value(Isar.getInstance());
  }

  Future<List<MemoNote>> getAllMemos() async {
    final isar = await db;
    IsarCollection<MemoNote> memoNotesCollection = isar.collection<MemoNote>();
    final memoNotes = memoNotesCollection.where().findAll();
    return memoNotes;
  }

  Future<void> addNewMemo(MemoNote newMemo) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.memoNotes.putSync(newMemo));
  }

  Future<void> updateMemo(int id, MemoNote updatedMemo) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final memoToUpdate = await isar.memoNotes.get(id);
      if (memoToUpdate != null) {
        await isar.memoNotes.put(updatedMemo);
      } else {
        if (kDebugMode) {
          print('Memo with ID not found.');
        }
      }
    });
  }

  Future<void> deleteMemo(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final success = await isar.memoNotes.delete(id);
      if (kDebugMode) {
        print('Memo deleted: $success');
      }
    });
  }

  Future<List<MemoNote>> findMemosWithFilter(MemoType type) async {
    final isar = await db;
    final result = await isar.memoNotes.filter().typeEqualTo(type).findAll();
    return result;
  }

  Future<List<ImagePost>> getAllImages() async {
    final isar = await db;
    IsarCollection<ImagePost> imagePostsCollection = isar.collection<ImagePost>();
    final imagePosts = imagePostsCollection.where().findAll();
    return imagePosts;
  }

  Future<void> addNewImage(ImagePost newImage) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.imagePosts.putSync(newImage));
  }

  Future<void> updateImages(int id, ImagePost updatedImage) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final imageToUpdate = await isar.imagePosts.get(id);
      if (imageToUpdate != null) {
        await isar.imagePosts.put(updatedImage);
      } else {
        if (kDebugMode) {
          print('Image with ID not found.');
        }
      }
    });
  }
}