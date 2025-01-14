/* cloud firestore へ情報を保存するための関数 */

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // イベントデータを取得
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Firestoreからのデータ取得中にエラー: $e');
      return [];
    }
  }
  // イベント情報をFirestoreへ保存
  Future<void> addEvent(Map<String, dynamic> event) async {
  await FirebaseFirestore.instance.collection('events').add(event);
}

}
