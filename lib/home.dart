/* ホーム画面
    カレンダー、各日程のイベント表示 */

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'front_end/add_event.dart';
import 'front_end/edit_event.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {
    DateTime(2025, 1, 1): ['たき火祭り', 'POP UP'],
    DateTime(2025, 1, 2): ['吹奏楽部演奏会'],
  };
  // 日付を正規化する関数（カレンダーと整合性を合わせる）
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    // 選択された日のイベントを取得(日付を正規化)
    List<String> selectedEvents =
        _events[_normalizeDate(_selectedDay ?? _focusedDay)] ?? []; 

    return Scaffold(
      appBar: AppBar(
        title: Text('イベントカレンダー'),
      ),
      body: Column(
        children: [
          // カレンダー表示
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _events[_normalizeDate(day)] ?? [];
            },
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: selectedEvents.length + 1, // +1は「+ イベントを追加」ボタン用
              itemBuilder: (context, index) {
                if (index == selectedEvents.length) {
                  // 「イベントを追加」ボタン
                  return TextButton(
                    onPressed: () async {
                      // イベント追加画面へ遷移
                      final newEvent = await Navigator.push(
                        context,
                        MaterialPageRoute(  
                          builder: (context) => AddEventScreen(
                            selectedDate: _normalizeDate(_selectedDay ?? _focusedDay,
                            ), // 選択された日付を渡す
                          ),
                        ),
                      );

                      // 新しいイベントが追加されたと場合
                      if (newEvent != null) {
                        setState(() {
                          final eventDate = _normalizeDate(_selectedDay ?? _focusedDay);
                          if (_events[eventDate] == null) {
                            _events[eventDate] = [];
                          }
                          _events[eventDate]?.add(newEvent); // 新しいイベントを追加
                        });
                      }
                    },
                    child: Text("+ イベントを追加"),
                  );
                }
                // イベントリストアイテム
                return ListTile(
                  title: Text(selectedEvents[index]),
                  onTap: () async {
                    // 編集画面への遷移
                    final updatedEvent = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEventScreen(
                          eventTitle: selectedEvents[index], // 編集対象のイベント名
                          onDelete: () {
                            setState(() {
                              selectedEvents.removeAt(index); // 削除処理
                            });
                          },
                        ),
                      ),
                    );
                    if (updatedEvent != null && updatedEvent.isNotEmpty) {
                      setState(() {
                        selectedEvents[index] = updatedEvent; // イベント名を更新
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

