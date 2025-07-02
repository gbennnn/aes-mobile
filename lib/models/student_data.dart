class StudentData {
  final String name;
  final String nim;
  final String email;

  StudentData({required this.name, required this.nim, required this.email});

  Map<String, dynamic> toMap() {
    return {'name': name, 'nim': nim, 'email': email};
  }

  factory StudentData.fromMap(Map<String, dynamic> map) {
    return StudentData(name: map['name'], nim: map['nim'], email: map['email']);
  }
}
