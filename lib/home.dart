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
  DateTime _focusedDay = DateTime.now(); // 表示している日付
  DateTime? _selectedDay; // 選択した日付
  Map<DateTime, List<Map<String,dynamic>>> _events = {};// 日付ごとのイベントリストを管理する変数

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Firestoreからイベントを取得
  }

  Future<void> _loadEvents() async {
    FirestoreService firestoreService = FirestoreService();
    
    // イベント情報を取得
    List<Map<String, dynamic>> events = await firestoreService.fetchEvents();

    setState(() {
      // Firestoreから取得したデータを_eventsに格納
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
            lastDay: DateTime(2030, 12, 31),// カレンダーの範囲
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final events = _events[_normalizeDate(day)] ?? [];
              return events.map((event) => event).toList();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Row(
                    // カレンダー上の丸の表示
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.map((event) {
                      if (event != null && event is Map<String, dynamic>) { // nullチェックと型確認
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: event['type'] == 'admin' ? Colors.red : Colors.teal, // typeによって丸の色を変更
                          ),
                        );
                      }
                      return SizedBox.shrink(); // null や無効なデータの場合は空のウィジェットを返す
                    }).toList(),
                  );
                }
                return null;
              },
            ),
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

                        // `type`を付与してFirestoreに保存
                        final Map<String, dynamic> eventWithType = {
                          ...newEvent,
                          'type': 'user', // ユーザが追加したイベントの識別用
                        };

                        // Firestoreにイベントを追加し、ドキュメントIDを取得
                        final docRef = await firestoreService.addEvent(eventWithType);
                        final docId = docRef.id; // ドキュメントIDを取得

                        setState(() {
                          // 新しいイベントが追加されたときに、その情報を_eventsへ格納
                          final eventDate = _normalizeDate(_selectedDay ?? _focusedDay);
                          if (_events[eventDate] == null) {
                            _events[eventDate] = [];
                          }
                          // ローカル状態の更新（FirestoreドキュメントIDの保存も行う）
                          _events[eventDate]?.add({
                            ...eventWithType,
                            'id': docId, // ドキュメントIDを追加
                          }); 
                        });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        "+ イベントを追加",
                        style: TextStyle(fontSize: 16.0, color: Colors.blue),
                      ),
                    ),
                  );
                }
                // イベントリストアイテム
                final event = selectedEvents[index];
                  return InkWell(
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
                                // イベント内容が更新されたときに更新して反映
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
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      // 運営が追加したイベントの判別
                      color: event['type'] == 'admin' ? Colors.red.shade50 : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['startTime'] ?? '**:**',
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              event['endTime'] ?? '**:**',
                              style: TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                          ], 
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            event['title'] ?? 'イベント名',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }
}