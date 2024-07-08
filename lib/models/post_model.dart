class Post {
  final String idpost;
  final String nameuser;
  final String avatar;
  final String content;
  final int commentcount;
  final String idcomment;
  final int like;
  final String linkmedia;
  final String timecreate;

  const Post({
    required this.idpost,
    required this.nameuser,
    required this.avatar,
    required this.content,
    required this.commentcount,
    required this.idcomment,
    required this.like,
    required this.linkmedia,
    required this.timecreate,
  });
}
