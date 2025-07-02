import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk ByteData
import 'dart:convert'; // Untuk utf8 encoding
import '../utils/aes_helper.dart';
import '../utils/firebase_helper.dart';
import '../models/student_data.dart';
import 'view_data_screen.dart'; // Untuk navigasi ke halaman lihat data

class InputDataScreen extends StatefulWidget {
  @override
  _InputDataScreenState createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Kunci dan IV (Initialization Vector) untuk AES-128 CBC
  // Ini harus digenerate dengan aman dan disimpan dengan aman di aplikasi nyata.
  // Untuk tujuan pembelajaran, kita gunakan nilai statis.
  // Ukuran kunci harus 16 byte (128 bit)
  // Ukuran IV harus 16 byte (128 bit)
  final List<int> _aesKey = List.generate(
    16,
    (index) => index + 1,
  ); // Contoh kunci
  final List<int> _aesIv = List.generate(
    16,
    (index) => 16 - index,
  ); // Contoh IV

  String _encryptedName = '';
  String _encryptedNIM = '';
  String _encryptedEmail = '';

  void _testFirestoreConnection() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Testing Firestore connection...')));

    bool isConnected = await FirebaseHelper.testFirestoreConnection();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isConnected
              ? 'Firestore connection successful!'
              : 'Firestore connection failed!',
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
      ),
    );
  }

  void _encryptData() async {
    // Validasi input
    if (_nameController.text.trim().isEmpty ||
        _nimController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Harap isi semua field!')));
      return;
    }

    setState(() {
      try {
        print('Memulai proses enkripsi...');

        // Enkripsi Nama
        final List<int> nameBytes = utf8.encode(_nameController.text.trim());
        _encryptedName = AesHelper.encryptCBC(nameBytes, _aesKey, _aesIv);
        print('Nama berhasil dienkripsi: $_encryptedName');

        // Enkripsi NIM
        final List<int> nimBytes = utf8.encode(_nimController.text.trim());
        _encryptedNIM = AesHelper.encryptCBC(nimBytes, _aesKey, _aesIv);
        print('NIM berhasil dienkripsi: $_encryptedNIM');

        // Enkripsi Email
        final List<int> emailBytes = utf8.encode(_emailController.text.trim());
        _encryptedEmail = AesHelper.encryptCBC(emailBytes, _aesKey, _aesIv);
        print('Email berhasil dienkripsi: $_encryptedEmail');

        print('Semua data berhasil dienkripsi, menyimpan ke Firebase...');
      } catch (e) {
        print('Error saat enkripsi: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saat enkripsi: $e')));
        return;
      }
    });

    try {
      // Simpan data terenkripsi ke Firebase
      final StudentData encryptedStudent = StudentData(
        name: _encryptedName,
        nim: _encryptedNIM,
        email: _encryptedEmail,
      );

      await FirebaseHelper.addStudentData(encryptedStudent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil dienkripsi dan disimpan!')),
      );

      // Clear the form after successful save
      _nameController.clear();
      _nimController.clear();
      _emailController.clear();

      setState(() {
        _encryptedName = '';
        _encryptedNIM = '';
        _encryptedEmail = '';
      });
    } catch (e) {
      print('Error saat menyimpan ke Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat menyimpan ke Firebase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Data Mahasiswa'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ViewDataScreen(aesKey: _aesKey, aesIv: _aesIv),
                ),
              );
            },
            tooltip: 'Lihat Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nimController,
              decoration: InputDecoration(
                labelText: 'NIM',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _encryptData,
              child: Text('Enkripsi & Simpan Data'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testFirestoreConnection,
              child: Text('Test Firestore Connection'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 24),
            // Tampilkan hasil enkripsi (opsional, untuk debugging)
            if (_encryptedName.isNotEmpty) ...[
              Text('Nama Terenkripsi: $_encryptedName'),
              Text('NIM Terenkripsi: $_encryptedNIM'),
              Text('Email Terenkripsi: $_encryptedEmail'),
            ],
          ],
        ),
      ),
    );
  }
}
