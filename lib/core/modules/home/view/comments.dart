import 'package:assignment/utils/time_ago.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/home_provider.dart';

class Comments extends StatefulWidget {
  final String videoId;

  const Comments({Key? key, required this.videoId}) : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  bool loading = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: const Text(
          "Comments",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("videos")
                  .doc(widget.videoId)
                  .collection("comments")
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    'No Data...',
                  );
                }
                return commentChild(snapshot.data!.docs);
              },
            ),
          ),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Add a comment",
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await homeProvider.addComment(
                          videoId: widget.videoId,
                          comment: controller.text.trim());
                      setState(() {
                        controller.clear();
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget commentChild(List<QueryDocumentSnapshot<Map<String, dynamic>>> data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 0.0),
            child: ListTile(
              leading: Container(
                height: 40.0,
                width: 40.0,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(data[i]['user']['photo'])),
              ),
              title: Container(
                decoration: const BoxDecoration(
                    color: Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data[i]['user']['name'] ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2B2B2B),
                                  fontSize: 16),
                            ),
                          ),
                          Text(
                            TimeAgo.timeAgo(DateTime.fromMillisecondsSinceEpoch(
                                (data[i]['time']))),
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xF02B2B2B),
                                fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        data[i]['comment'] ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xF02B2B2B),
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
