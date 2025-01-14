/* イベント情報の編集、削除ページ */

import 'package:flutter/material.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> eventData; // 編集するイベントのデータ
  final Function(Map<String, dynamic>) onSave; // 保存時のコールバック関数
  final VoidCallback onDelete; // 削除時のコールバック関数

  EditEventScreen({
    required this.eventData, 
    required this.onSave,
    required this.onDelete
  });

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _locationController;
  late TextEditingController _memoController;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventData['title']);
    _startTimeController =
        TextEditingController(text: widget.eventData['startTime']);
    _endTimeController = TextEditingController(text: widget.eventData['endTime']);
    _locationController = TextEditingController(text: widget.eventData['location']);
    _memoController = TextEditingController(text: widget.eventData['memo']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベントを編集'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.onDelete(); // 削除処理を実行
              Navigator.pop(context); // 前の画面に戻る
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'イベント名'),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _startTimeController,
              decoration: InputDecoration(labelText: '開始時間'),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _endTimeController,
              decoration: InputDecoration(labelText: '終了時間'),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: '場所'),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(labelText: 'メモ'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onDelete(); // 削除処理を実行
                    Navigator.pop(context); // 前の画面に戻る
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('削除'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedData = {
                      'title': _titleController.text,
                      'startTime': _startTimeController.text,
                      'endTime': _endTimeController.text,
                      'location': _locationController.text,
                      'memo': _memoController.text,
                    };
                    widget.onSave(updatedData); // 保存処理を実行
                    Navigator.pop(context); // 前の画面に戻る
                  },
                  child: Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
