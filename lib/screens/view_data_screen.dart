import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/firebase_helper.dart';
import '../utils/aes_helper.dart';
import '../models/student_data.dart';

class ViewDataScreen extends StatefulWidget {
  final List<int> aesKey;
  final List<int> aesIv;

  const ViewDataScreen({Key? key, required this.aesKey, required this.aesIv})
    : super(key: key);

  @override
  _ViewDataScreenState createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen> {
  List<StudentData> _studentDataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    setState(() {
      _isLoading = true;
    });
    final data = await FirebaseHelper.getStudentData();
    setState(() {
      _studentDataList = data;
      _isLoading = false;
    });
  }

  String _decryptData(String encryptedData) {
    try {
      final List<int> decryptedBytes = AesHelper.decryptCBC(
        encryptedData,
        widget.aesKey,
        widget.aesIv,
      );
      return utf8.decode(decryptedBytes); // <--- UBAH DI SINI
    } catch (e) {
      return 'Error dekripsi: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lihat Data Mahasiswa')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _studentDataList.isEmpty
              ? Center(child: Text('Belum ada data mahasiswa.'))
              : ListView.builder(
                itemCount: _studentDataList.length,
                itemBuilder: (context, index) {
                  final student = _studentDataList[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nama (Terenkripsi): ${student.name}'),
                          Text('NIM (Terenkripsi): ${student.nim}'),
                          Text('Email (Terenkripsi): ${student.email}'),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Data Terdekripsi'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                            'Nama: ${_decryptData(student.name)}',
                                          ),
                                          Text(
                                            'NIM: ${_decryptData(student.nim)}',
                                          ),
                                          Text(
                                            'Email: ${_decryptData(student.email)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Tutup'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Dekripsi & Lihat'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchStudentData,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }
}
