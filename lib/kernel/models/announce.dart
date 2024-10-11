class Announce {
  int? id;
  String? title;
  String? content;
  String? createdAt;

  Announce({this.id, this.title, this.content, this.createdAt});

  Announce.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    createdAt = json['created_at'];
  }
}
