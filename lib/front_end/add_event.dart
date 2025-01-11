/* ユーザの任意の予定追加ページ */

import 'package:flutter/material.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate; // 選択された日付を受け取る

  AddEventScreen({required this.selectedDate});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベントを追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '選択した日付: ${widget.selectedDate.toLocal()}'.split(' ')[0],
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
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
                if (_titleController.text.isNotEmpty) {
                  Navigator.pop(context, _titleController.text); // 入力値を返す
                }
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
