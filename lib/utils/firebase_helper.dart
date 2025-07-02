import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_data.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addStudentData(StudentData student) async {
    try {
      print('Mencoba menyimpan data ke Firebase...');
      print('Data yang akan disimpan: ${student.toMap()}');

      DocumentReference docRef = await _firestore
          .collection('students')
          .add(student.toMap());
      print(
        'Data mahasiswa berhasil ditambahkan ke Firebase dengan ID: ${docRef.id}',
      );
    } catch (e) {
      print('Error menambahkan data mahasiswa: $e');
      print('Error type: ${e.runtimeType}');
      rethrow; // Lempar error agar bisa ditangkap di UI
    }
  }

  static Future<List<StudentData>> getStudentData() async {
    try {
      print('Mengambil data dari Firebase...');
      QuerySnapshot querySnapshot =
          await _firestore.collection('students').get();
      print(
        'Berhasil mengambil ${querySnapshot.docs.length} dokumen dari Firebase',
      );

      List<StudentData> studentList =
          querySnapshot.docs.map((doc) {
            print('Data dokumen: ${doc.data()}');
            return StudentData.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

      return studentList;
    } catch (e) {
      print('Error mengambil data mahasiswa: $e');
      print('Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Fungsi test untuk verifikasi koneksi Firestore
  static Future<bool> testFirestoreConnection() async {
    try {
      print('Testing Firestore connection...');
      await _firestore.collection('test').doc('connection_test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'connection successful',
      });
      print('Firestore connection test successful!');

      // Hapus dokumen test
      await _firestore.collection('test').doc('connection_test').delete();
      return true;
    } catch (e) {
      print('Firestore connection test failed: $e');
      return false;
    }
  }
}
