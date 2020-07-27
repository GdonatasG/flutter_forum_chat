class User {
  String id;
  String name;
  String lastName;
  String username;

  User(this.name, this.lastName, this.username);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = name;
    map['lastName'] = lastName;
    map['username'] = username;

    return map;
  }

  User.fromMap(Map<String, dynamic> data) {
    name = data['name'];
    lastName = data['lastName'];
    username = data['username'];
  }
}
