class Category {
  String id;
  String name;

  Category(this.name);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = name;

    return map;
  }

  Category.fromMap(Map<String, dynamic> data) {
    name = data['name'];
  }
}
