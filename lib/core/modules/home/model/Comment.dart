import 'package:assignment/core/modules/auth/model/user.dart';

class Comment {
  String commentId;
  String videoId;
  String comment;
  String? time;
  User? user;

  Comment(
      {this.commentId = '',
      this.videoId = '',
      this.comment = '',
      this.time,
      this.user});
}
