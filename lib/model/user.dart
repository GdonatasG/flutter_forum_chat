class User {
  String id;
  String name;
  String lastName;
  String username;
  String photoUrl;

  User(this.name, this.lastName, this.username);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = name;
    map['lastName'] = lastName;
    map['username'] = username;
    map['photoUrl'] = photoUrl;

    return map;
  }

  User.fromMap(Map<String, dynamic> data) {
    name = data['name'];
    lastName = data['lastName'];
    username = data['username'];
    photoUrl = data['photoUrl'];
  }
}
