class Post2 {
  String? avatar;
  String? birthday;
  String? email;
  String? name;
  String? password;
  String? phone;
  String? sociallogin;

  Post2(
      {this.avatar,
      this.birthday,
      this.email,
      this.name,
      this.password,
      this.phone,
      this.sociallogin});

  Post2.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    birthday = json['birthday'];
    email = json['email'];
    name = json['name'];
    password = json['password'];
    phone = json['phone'];
    sociallogin = json['sociallogin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['birthday'] = this.birthday;
    data['email'] = this.email;
    data['name'] = this.name;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['sociallogin'] = this.sociallogin;
    return data;
  }
}
