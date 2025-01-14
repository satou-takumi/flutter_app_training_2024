/* ホーム画面
    カレンダー、各日程のイベント表示 */

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'front_end/add_event.dart';
import 'front_end/edit_event.dart';
import 'back_end/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String,dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Firestoreからイベントを取得
  }

  Future<void> _loadEvents() async {
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>> events = await firestoreService.fetchEvents();

    setState(() {
      for (var event in events) {
        DateTime eventDate = DateTime.parse(event['date']);
        if (_events[eventDate] == null) {
          _events[eventDate] = [];
        }
        _events[eventDate]?.add(event);
      }
    });
  }
  
  // 日付を正規化する関数（カレンダーと整合性を合わせる）
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    // 選択された日のイベントを取得(日付を正規化)
    List<Map<String,dynamic>> selectedEvents =
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
              return _events[_normalizeDate(day)]?.map((e) => e['title'] ?? '').toList() ?? [];
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
                            // 選択された日付を渡す
                            selectedDate: _normalizeDate(_selectedDay ?? _focusedDay), 
                          ),
                        ),
                      );

                      // 新しいイベントが追加された場合
                      if (newEvent != null) {
                        FirestoreService firestoreService = FirestoreService();

                        // Firestoreにイベントを追加し、ドキュメント参照を取得
                        final docRef = await firestoreService.addEvent(newEvent);
                        final docId = docRef.id; // ドキュメントIDを取得

                        setState(() {
                          final eventDate = _normalizeDate(_selectedDay ?? _focusedDay);
                          if (_events[eventDate] == null) {
                            _events[eventDate] = [];
                          }
                          // ローカル状態の更新（FirestoreのドキュメントIDを保存も行う）
                          _events[eventDate]?.add({
                            ...newEvent,
                            'id': docId, // ドキュメントIDを追加
                          }); 
                        });
                      }
                    },
                    child: Text("+ イベントを追加"),
                  );
                }
                // イベントリストアイテム
                final event = selectedEvents[index];
                return ListTile(
                  title: Text(event['title'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('開始: ${event['startTime'] ?? '**:**'}'),
                      Text('終了: ${event['endTime'] ?? '**:**'}'),
                      Text('場所: ${event['location'] ?? '***'}'),
                      Text('メモ: ${event['memo'] ?? '***'}'),
                    ],
                  ),
                  onTap: () async {
                    // 編集画面へ遷移
                    final updatedEvent = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEventScreen(
                          eventData: event,
                          onSave: (updatedData) async {
                            FirestoreService firestoreService = FirestoreService();

                            // Firestore にイベントを更新
                            if(event['id'] != null){
                              await firestoreService.updateEvent(event['id'], updatedData); 
                            }
                            setState(() {
                              event['title'] = updatedData['title'] ?? '***'; // nullに対応
                              event['startTime'] = updatedData['startTime'] ?? '**:**';
                              event['endTime'] = updatedData['endTime'] ?? '**:**';
                              event['location'] = updatedData['location'] ?? '***';
                              event['memo'] = updatedData['memo'] ?? '***';
                            });
                          },
                          onDelete: () async {
                            FirestoreService firestoreService = FirestoreService();

                            // Firestoreからイベントを削除
                            if (event['id'] != null) {
                              await firestoreService.deleteEvent(event['id']); 
                            }
                            setState(() {
                              selectedEvents.removeAt(index); // 削除処理
                            });
                          }
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
              }
            ),
          )
        ],
      ),
    );
  }
}