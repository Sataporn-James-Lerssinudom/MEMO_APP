import 'package:flutter/material.dart';
import '../isar_service.dart';
import '../collections/memo_note.dart';
import '../pages/page_memo_edit.dart';
import '../widgets/app_drawer.dart';

class PageMemoHome extends StatefulWidget {
  const PageMemoHome({super.key});

  @override
  State<PageMemoHome> createState() => _PageMemoHomeState();
}

class _PageMemoHomeState extends State<PageMemoHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MemoNote> allMemos = [];
  List<MemoNote> justMemos = [];
  List<MemoNote> starMemos = [];
  List<MemoNote> binMemos = [];

  @override
  void initState() {
    super.initState();
    loadAllMemos();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      // Update UI based on the newly selected tab index
    });
  }

  void loadAllMemos() async {
    allMemos = await isarService.getAllMemos();
    updateMemos(isJustChanged: true, isStarChanged: true, isBinChanged: true);
    setState(() {
      // Update UI based on the newly loaded memo
    });
  }

  // To modify listview if item number is changed
  void updateMemos({bool isJustChanged = false, bool isStarChanged = false, bool isBinChanged = false}) {
    if (isJustChanged) {
      justMemos = allMemos.where((element) => element.type != MemoType.deleted).toList();
    }
    if (isStarChanged) {
      starMemos = justMemos.where((element) => element.type == MemoType.important).toList();
    }
    if (isBinChanged) {
      binMemos = allMemos.where((element) => element.type == MemoType.deleted).toList();
    }
  }

  void addMemo() async {
    String newTitle = 'New memo';
    MemoNote newMemo = MemoNote(newTitle);   // Create memo
    isarService.addNewMemo(newMemo);   // Update database
    int index = allMemos.length;   // Point memo
    allMemos.add(newMemo);   // Add memo to list
    setState(() {
      updateMemos(isJustChanged: true);
    });
    showAddMemoWindow(index);   // Write memo
  }

  void showAddMemoWindow(int index) {
    TextEditingController textController = TextEditingController(text: allMemos[index].title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Memo\'s Title'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter memo\'s title'),
            maxLength: 50,
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                MemoNote editedMemo = allMemos[index];   // Point memo
                editedMemo.title = textController.text;   // Edit memo
                isarService.updateMemo(editedMemo.id, editedMemo);   // Update database
                setState(() {
                  // Update UI based on the newly added memo
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> editMemo(int index) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PageMemoEdit(memo: allMemos[index])
        ),
    );

    if (context.mounted) {
      MemoNote editedMemo = allMemos[index];   // Point memo
      isarService.updateMemo(editedMemo.id, editedMemo);   // Update database
      setState(() {
        // Update UI based on the newly edited memo
      });
    }
  }

  void markImportantMemo(int index) {
    MemoNote editedMemo = allMemos[index];   // Point memo
    if (editedMemo.type == MemoType.general) {
      editedMemo.changeTypeTo(MemoType.important);   // Add in star list
    } else {
      editedMemo.changeTypeTo(MemoType.general);   // Remove from star list
    }
    isarService.updateMemo(editedMemo.id, editedMemo);   // Update database
    setState(() {
      updateMemos(isStarChanged: true);
    });
  }

  void deleteMemo(int index) {
    MemoNote deletedMemo = allMemos[index];   // Point memo
    deletedMemo.changeTypeTo(MemoType.deleted);   // Add to bin list
    isarService.updateMemo(deletedMemo.id, deletedMemo);   // Update database
    setState(() {
      updateMemos(isJustChanged: true, isStarChanged: true, isBinChanged: true);
    });
  }

  void restoreMemo(int index) {
    MemoNote restoredMemo = allMemos[index];   // Point memo
    restoredMemo.changeTypeTo(MemoType.general);   // Add to list
    isarService.updateMemo(restoredMemo.id, restoredMemo);   // Update database
    setState(() {
      updateMemos(isJustChanged: true, isBinChanged: true);
    });
  }

  void deleteMemoForever(int index) {
    isarService.deleteMemo(allMemos[index].id);   // Update database
    allMemos.removeAt(index);   // Remove from bin
    setState(() {
      updateMemos(isBinChanged: true);
    });
  }

  void deleteAllMemosForever() {
    for (MemoNote memo in binMemos) {
      deleteMemoForever(allMemos.indexOf(memo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.note),
              text: 'Memos',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Important',
            ),
            Tab(
              icon: Icon(Icons.delete),
              text: 'Trash',
            ),
          ],
        ),
        actions: <Widget>[
          if (_tabController.index == 0) // Check if Memo tab is active
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: addMemo,
                tooltip: 'Add new memo',
              ),
            ),
          if (_tabController.index == 2) // Check if Deleted tab is active
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: deleteAllMemosForever,
                tooltip: 'Clear trash',
              ),
            )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReorderableListView.builder(
            itemCount: justMemos.length,
            itemBuilder: (context, index) {
              return ListTile(
                key: Key('$index'),
                title: Text(justMemos[index].title),
                onTap: () {
                  editMemo(allMemos.indexOf(justMemos[index]));
                },
                tileColor: index % 2 == 0 ? oddItemColor : evenItemColor,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: justMemos[index].type == MemoType.important
                        ? const Icon(Icons.star, color: Colors.deepOrange)
                        : const Icon(Icons.star),
                      onPressed: () {
                        markImportantMemo(allMemos.indexOf(justMemos[index]));
                      },
                      tooltip: 'Mark as important',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteMemo(allMemos.indexOf(justMemos[index]));
                        },
                        tooltip: 'Move to trash',
                      ),
                    ),
                  ],
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = justMemos.removeAt(oldIndex);
                justMemos.insert(newIndex, item);
              });
            },
          ),
          ReorderableListView.builder(
            itemCount: starMemos.length,
            itemBuilder: (context, index) {
              return ListTile(
                key: Key('$index'),
                title: Text(starMemos[index].title),
                onTap: () {
                  editMemo(allMemos.indexOf(starMemos[index]));
                },
                tileColor: index % 2 == 0 ? oddItemColor : evenItemColor,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: IconButton(
                        icon: const Icon(Icons.star, color: Colors.deepOrange),
                        onPressed: () {
                          markImportantMemo(allMemos.indexOf(starMemos[index]));
                        },
                        tooltip: 'Mark not important',
                      ),
                    ),
                  ],
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = starMemos.removeAt(oldIndex);
                starMemos.insert(newIndex, item);
              });
            },
          ),
          ReorderableListView.builder(
            itemCount: binMemos.length,
            itemBuilder: (context, index) {
              return ListTile(
                key: Key('$index'),
                title: Text(binMemos[index].title),
                tileColor: index % 2 == 0 ? oddItemColor : evenItemColor,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: () {
                        restoreMemo(allMemos.indexOf(binMemos[index]));
                      },
                      tooltip: 'Move to memos',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                          deleteMemoForever(allMemos.indexOf(binMemos[index]));
                        },
                        tooltip: 'Delete forever',
                      ),
                    ),
                  ],
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = binMemos.removeAt(oldIndex);
                binMemos.insert(newIndex, item);
              });
            },
          ),
        ],
      ),
      drawer: const AppDrawer(selectedIndex: 0),
    );
  }
}