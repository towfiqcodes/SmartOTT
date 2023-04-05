class User {
  String id;
  String email;
  String name;
  String photo;

  User({this.id = '', this.name = '', this.email = '', this.photo = ''});

  Map<String, dynamic> toJson() =>
      {"id": id, "name": name, "email": email, "photo": photo};
}
