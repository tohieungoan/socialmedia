class Getcontentmessage {
  String? name;
  String? avatar;
  String? content;
  String? linkmedia;
  String? timecreate;
  String? idofme;

  Getcontentmessage(
      {this.name,
      this.avatar,
      this.content,
      this.linkmedia,
      this.timecreate,
      this.idofme});

  Getcontentmessage.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    avatar = json['avatar'];
    content = json['content'];
    linkmedia = json['linkmedia'];
    timecreate = json['timecreate'];
    idofme = json['idofme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['content'] = this.content;
    data['linkmedia'] = this.linkmedia;
    data['timecreate'] = this.timecreate;
    data['idofme'] = this.idofme;
    return data;
  }
}
