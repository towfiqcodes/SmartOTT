import 'package:assignment/core/modules/auth/model/user.dart';
import 'package:assignment/core/modules/home/model/Comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../../../../utils/smart_prefs.dart';

class HomeProvider with ChangeNotifier {
  static const String videoCollection = "videos";
  static const String commentCollection = "comments";
  var smartPrefs = SmartPrefs();

  User currentUser() {
    return User(
        id: smartPrefs.userId,
        name: smartPrefs.fullName,
        email: smartPrefs.userEmail,
        photo: smartPrefs.imageUrl);
  }

  Future<void> addComment(
      {required String videoId, required String comment}) async {
    try {
      String commentId = const Uuid().v4();

      FirebaseFirestore.instance
          .collection(videoCollection)
          .doc(videoId)
          .collection(commentCollection)
          .doc(commentId)
          .set({
        "commentId": commentId,
        "videoId": videoId,
        "comment": comment,
        "time": DateTime.now().microsecondsSinceEpoch,
        "user": currentUser().toJson()
      }).then((value) {
        debugPrint("comment added successfully.");
      }).catchError((error) {
        debugPrint("adding comment failed, error - $error");
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Adding comment failed, $e");
    }
  }

  Future<List<Comment>> getComments({required String videoId}) async {
    List<Comment> comments = [];
    try {
      FirebaseFirestore.instance
          .collection(videoCollection)
          .doc(videoId)
          .collection(commentCollection)
          .orderBy("time")
          .get()
          .then((querySnapshot) {
        for (var element in querySnapshot.docChanges) {
          Comment comment = Comment(
              commentId: element.doc["commentId"],
              comment: element.doc["comment"],
              time: element.doc["time"],
              videoId: element.doc["videoId"],
              user: User(
                id: element.doc["user"]["id"],
                name: element.doc["user"]["name"],
                email: element.doc["user"]["email"],
                photo: element.doc["user"]["photo"],
              ));
          comments.add(comment);
        }
      });
      return comments;
    } catch (error) {
      debugPrint("Getting comments failed, error - $error");
      return [];
    }
  }
}
