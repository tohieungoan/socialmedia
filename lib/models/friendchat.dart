class friendchat {
  String? id;
  String? idofme;
  String? name;
  String? avatar;
  String? idwechat;
  String? lastmessage;

  friendchat(
      {this.id,
      this.idofme,
      this.name,
      this.avatar,
      this.idwechat,
      this.lastmessage});

  friendchat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idofme = json['idofme'];
    name = json['name'];
    avatar = json['avatar'];
    idwechat = json['idwechat'];
    lastmessage = json['lastmessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idofme'] = this.idofme;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['idwechat'] = this.idwechat;
    data['lastmessage'] = this.lastmessage;
    return data;
  }
}
