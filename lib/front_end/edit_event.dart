/* イベント情報の編集、削除ページ */

import 'package:flutter/material.dart';

class EditEventScreen extends StatefulWidget {
  final String eventTitle; // 編集するイベントのタイトル
  final VoidCallback onDelete; // 削除時のコールバック関数

  EditEventScreen({required this.eventTitle, required this.onDelete});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベントを編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'イベント名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 入力内容を戻して画面を閉じる
                Navigator.pop(context, _titleController.text);
              },
              child: Text('保存'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.onDelete(); // 削除処理を実行
                Navigator.pop(context, null); // 削除時は null を返す
              },
              child: Text('削除'),
            ),
          ],
        ),
      ),
    );
  }
}
