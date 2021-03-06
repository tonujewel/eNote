import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:enote/controllers/note_controller.dart';
import 'package:enote/utils/AppConstant.dart';
import 'package:enote/views/add_note/add_note.dart';
import 'package:enote/views/note_details/note_details.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

class NoteList extends StatelessWidget {
  final NoteController noteController = Get.put(NoteController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          isForUpdate = false;
          noteController.goToAddNote();
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Note list"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("notes-$UID")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text('Loading...');
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StaggeredGridView.countBuilder(
                    physics: BouncingScrollPhysics(),
                    crossAxisCount: 4,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onLongPress: () {
                          Get.bottomSheet(Container(
                            height: size.height * .25,
                            padding: EdgeInsets.only(top: 30, left: 20),
                            decoration: BoxDecoration(
                              color: Color(0xff9e9e9e),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Update note
                                GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    isForUpdate = true;
                                    String title =
                                        "${snapshot.data.docs[index].data()['title']}";
                                    String desc =
                                        "${snapshot.data.docs[index].data()['desc']}";
                                    String color =
                                        "${snapshot.data.docs[index].data()['color']}"
                                            .substring(35, 45);

                                    Get.to(AddNote(), arguments: [
                                      "$title",
                                      "$desc",
                                      "$color",
                                      index
                                    ]);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        'Edit Note',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete note
                                GestureDetector(
                                  onTap: () {
                                    noteController.deleteData(index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_forever,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        SizedBox(width: 15),
                                        Text(
                                          'Delete Note',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Share
                                GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    String title =
                                        "${snapshot.data.docs[index].data()['title']}";
                                    String desc =
                                        "${snapshot.data.docs[index].data()['desc']}";
                                    Share.share(
                                        'Title: $title \n Description: $desc ');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.share,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        SizedBox(width: 15),
                                        Text(
                                          'Share',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ));
                        },
                        // note details
                        onTap: () {
                          String title =
                              "${snapshot.data.docs[index].data()['title']}";
                          String desc =
                              "${snapshot.data.docs[index].data()['desc']}";
                          String color =
                              "${snapshot.data.docs[index].data()['color']}"
                                  .substring(35, 45);
                          Get.to(NoteDetails(),
                              arguments: ["$title", "$desc", "$color"]);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                "${snapshot.data.docs[index].data()['color']}"
                                    .substring(35, 45))),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${snapshot.data.docs[index].data()['title']}",
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "${snapshot.data.docs[index].data()['desc']}",
                                  maxLines: 5,
                                  style: TextStyle(color: Colors.white70)),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                      "${snapshot.data.docs[index].data()['time']}",
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
