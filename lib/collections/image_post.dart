import 'package:isar/isar.dart';

part 'image_post.g.dart';

@collection
@Name('Image_Posts')
class ImagePost {
  @Name('imageId')
  Id id = Isar.autoIncrement;
  late String path;
  late int like;

  ImagePost(this.path) {
    like = 0;
  }

  void setLike(int like) {
    this.like = like;
  }
}

// TODO: Run below command whenever this has changed
/*
 * flutter pub run build_runner build
 */