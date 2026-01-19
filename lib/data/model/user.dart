class User {
  final String? docId;
  final String username;
  final String email;
  final String password;

  static const TABLE_NAME = "users";

  User({
    this.docId,
    required this.username,
    required this.email,
    required this.password,
  });

  User copy({String? docId, String? username, String? email, String? password}) {
    return User(
      docId: docId ?? this.docId,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {"username": username, "email": email, "password": password};
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      docId: map["docId"],
      username: map["username"],
      email: map["email"],
      password: map["password"],
    );
  }

  @override
  String toString() {
    return "User($docId, $username, $email, $password)";
  }
}
