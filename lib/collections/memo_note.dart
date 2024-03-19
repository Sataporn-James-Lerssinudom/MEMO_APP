import 'package:isar/isar.dart';

part 'memo_note.g.dart';

@collection
@Name('Memo_Notes')
class MemoNote {
  @Name('memoId')
  Id id = Isar.autoIncrement;
  late String title;
  late String content;
  @Index()
  @enumerated
  late MemoType type;
  late DateTime createdAt;
  late DateTime lastEditedAt;

  MemoNote(this.title) {
    content = "";
    type = MemoType.general;
    createdAt = DateTime.now();
    lastEditedAt = createdAt;
  }

  void editMemo(String title, String content) {
    this.title = title;
    this.content = content;
    lastEditedAt = DateTime.now();
  }

  void changeTypeTo(MemoType type) {
    this.type = type;
  }
}

enum MemoType {
  general('General'),
  important('Important'),
  deleted('Deleted');

  const MemoType(this.type);
  final String type;
}

// TODO: Run below command whenever this has changed
/*
 * flutter pub run build_runner build
 */