/* ユーザの任意の予定追加ページ */

import 'package:flutter/material.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate; // 選択された日付が入る変数

  AddEventScreen({
    required this.selectedDate
    });

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  // 各項目用のテキストコントローラー
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

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
            TextField(
              controller: _startTimeController,
              decoration: InputDecoration(
                labelText: '開始時間 (例: 10:00)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _endTimeController,
              decoration: InputDecoration(
                labelText: '終了時間 (例: 12:00)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: '場所',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // 保存ボタン
            ElevatedButton(
              onPressed: () {
                // タイトルの入力があった場合のみ保存可能
                if (_titleController.text.isNotEmpty) {
                  final newEvent = {
                    'title': _titleController.text,
                    'startTime': _startTimeController.text,
                    'endTime': _endTimeController.text,
                    'location': _locationController.text,
                    'memo': _memoController.text,
                    'date': widget.selectedDate.toIso8601String(),
                  };
                  Navigator.pop(context, newEvent); // 入力データを戻す
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
