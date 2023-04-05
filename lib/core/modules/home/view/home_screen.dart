import 'package:assignment/core/modules/auth/provider/auth_provider.dart';
import 'package:assignment/core/modules/home/provider/home_provider.dart';
import 'package:assignment/core/modules/home/view/comments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../utils/time_ago.dart';

enum SampleItem { logout }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _YTState createState() => _YTState();
}

class _YTState extends State<HomeScreen> {
  late String videoTitle;
  bool loading = false;

  // Url List
  final List<String> _videoUrlList = [
    'https://youtu.be/dWs3dzj4Wng',
    'https://www.youtube.com/watch?v=668nUCeBHyY',
    'https://youtu.be/S3npWREXr8s',
  ];

  List<YoutubePlayerController> lYTC = [];

  Map<String, dynamic> cStates = {};

  @override
  void initState() {
    super.initState();
    fillYTlists();
  }

  fillYTlists() {
    for (var element in _videoUrlList) {
      String _id = YoutubePlayer.convertUrlToId(element)!;
      YoutubePlayerController _ytController = YoutubePlayerController(
        initialVideoId: _id,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          enableCaption: true,
          isLive: true,
          captionLanguage: 'en',
        ),
      );

      _ytController.addListener(() {
        print('for $_id got isPlaying state ${_ytController.value.isPlaying}');
        if (cStates[_id] != _ytController.value.isPlaying) {
          if (mounted) {
            setState(() {
              cStates[_id] = _ytController.value.isPlaying;
            });
          }
        }
      });

      lYTC.add(_ytController);
    }
  }

  @override
  void dispose() {
    for (var element in lYTC) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartOTT'),
        centerTitle: false,
        elevation: 0,
        actions: [
          PopupMenuButton<SampleItem>(
            padding: const EdgeInsets.symmetric(vertical: 5),
            iconSize: 24,
            color: Colors.white,
            offset: const Offset(0, 40),
            onSelected: (SampleItem item) {
              if (item == SampleItem.logout) {
                context.read<AuthProvider>().signOutFromGoogleAcc(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
              const PopupMenuItem<SampleItem>(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 36,
                value: SampleItem.logout,
                child: Text('Log out'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: _videoUrlList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            TextEditingController controller = TextEditingController();
            YoutubePlayerController _ytController = lYTC[index];
            String _id = YoutubePlayer.convertUrlToId(_videoUrlList[index])!;
            print("isId $_id");
            String curState = 'undefined';
            if (cStates[_id] != null) {
              curState = cStates[_id] ? 'playing' : 'paused';
            }
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 220.0,
                        decoration: const BoxDecoration(
                          color: Color(0xfff5f5f5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: YoutubePlayer(
                            controller: _ytController,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: Colors.lightBlueAccent,
                            bottomActions: [
                              CurrentPosition(),
                              ProgressBar(isExpanded: true),
                              FullScreenButton(),
                            ],
                            onReady: () {
                              print('onReady for $index $_id');
                            },
                            onEnded: (YoutubeMetaData _md) {
                              _ytController.seekTo(const Duration(seconds: 0));
                            },
                          ),
                        ),
                      ),
                    ],
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
                            decoration: InputDecoration(
                              hintText: "Add a comment",
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 0.5)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 0.5)),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 0.5)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 0.5)),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (controller.text.isNotEmpty) {
                              await homeProvider.addComment(
                                  videoId: _id,
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
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("videos")
                        .doc(_id)
                        .collection("comments")
                        .orderBy("time")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Total Comments (${snapshot.data!.docs.length})",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.isNotEmpty ? 1 : 0,
                              itemBuilder: (context, index) {
                                DocumentSnapshot data =
                                    snapshot.data!.docs[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.blue.shade200,
                                        backgroundImage:
                                            NetworkImage(data['user']['photo']),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    data['user']['name'] ?? "",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff2B2B2B),
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                Text(
                                                  TimeAgo.timeAgo(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          (data['time']))),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(0xF02B2B2B),
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              data['comment'] ?? "",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Color(0xF02B2B2B),
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            if (snapshot.data!.docs.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        showCupertinoModalBottomSheet(
                                            expand: true,
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) =>
                                                Comments(videoId: _id));
                                      },
                                      child: const Text(
                                        "See more",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w700),
                                      )),
                                ),
                              ),
                          ],
                        );
                      } else {
                        return const Text(
                          '',
                        );
                      }
                    },
                  ),

                  const SizedBox(
                    height: 4,
                  )

                  // Material(
                  //   color: Colors.white,
                  //   child: InkWell(
                  //     onTap: () {
                  //       showCupertinoModalBottomSheet(
                  //           expand: true, context: context, backgroundColor: Colors.transparent, builder: (context) => Comments(videoId: _id));
                  //     },
                  //     child: Container(
                  //       // padding:
                  //       //     const EdgeInsets.symmetric(horizontal: 8.0),
                  //       height: 25.0,
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(
                  //             Icons.comment_outlined,
                  //             color: Colors.grey[600],
                  //             size: 20.0,
                  //           ),
                  //           const SizedBox(width: 4.0),
                  //           const Text('Comments '),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
