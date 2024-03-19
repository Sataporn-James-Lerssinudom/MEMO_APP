import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../collections/memo_note.dart';

class PageMemoEdit extends StatelessWidget {
  const PageMemoEdit({super.key, required this.memo});
  final MemoNote memo; // Passing data

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController(
        text: memo.title);
    TextEditingController contentController = TextEditingController(
        text: memo.content);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0), // Add padding to the top
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Memo\'s title',
                border: InputBorder.none, // Hide the bottom line
              ),
              maxLength: 50,
              // Limit the title to 50 characters
              maxLines: 1,
              // Limit to a single line
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 56.0), // Add padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Created at:  ${DateFormat('yyyy-MM-dd HH:mm').format(memo.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
                Text(
                  'Last Edited: ${DateFormat('yyyy-MM-dd HH:mm').format(memo.lastEditedAt)}',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      hintText: 'Add text here',
                    ),
                    maxLines: null, // Allow multiple lines of text
                  ),
                ),
                const SizedBox(height: 10.0), // Spacer
              ],
            ),
          ),
          Positioned(
            left: 16.0, // Add left padding
            right: 16.0, // Add right padding
            bottom: 16.0, // Add bottom padding
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1.0, left: 1.0), // Add padding to the bottom and left
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Save title and content
                      memo.editMemo(titleController.text, contentController.text);
                      Navigator.pop(context, memo);
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 10.0), // Add spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}