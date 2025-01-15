/* cloud firestore へ情報を保存するための関数 */

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // イベントデータを取得
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // IDを追加
      return data;
    }).toList();
    } catch (e) {
      print('Firestoreからのデータ取得中にエラー: $e');
      return [];
    }
  }
  // イベント情報をFirestoreへ保存
  Future<DocumentReference<Map<String, dynamic>>> addEvent(Map<String, dynamic> event) async {
    final docRef = FirebaseFirestore.instance.collection('events').doc(); // ドキュメント参照を生成
    await docRef.set({
      ...event,
      'id': docRef.id // ドキュメントIDを追加
    });
    return docRef; // ドキュメント参照を返す
  }

  // イベントの更新
  Future<void> updateEvent(String eventId, Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update(updatedData);
  }
  // イベントの削除
  Future<void> deleteEvent(String eventId) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .delete();
  }
}
