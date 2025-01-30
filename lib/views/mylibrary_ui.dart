// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:firstindex_webapp/novelmanage/edit_novel_ui.dart';
import 'package:firstindex_webapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MylibraryUi extends StatefulWidget {
  const MylibraryUi({super.key});

  @override
  State<MylibraryUi> createState() => _MylibraryUiState();
}

class _MylibraryUiState extends State<MylibraryUi> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final datainfo = await fetchUserData(context);
    if (datainfo != null) {
      setState(() {
        userData = datainfo;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchAuthorLibrary() async {
    if (userData == null || userData?['user_id'] == null) {
      throw Exception('User data or user ID is not loaded');
    }

    final response = await http.get(
      Uri.parse(
          '${CallAPI.hostURL}/authorlibrary?authorId=${userData!['user_id']}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load library novels');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: Center(
          child: Text(
            "ชั้นหนังสือ",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAuthorLibrary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('ไม่มีนิยายในชั้นหนังสือ'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ไม่มีนิยายในชั้นหนังสือ'));
          }

          final novels = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              // กำหนดค่าขนาดที่เหมาะสมสำหรับหน้าจอที่แตกต่างกัน
              // double iconSize = constraints.maxWidth >= 1000 ? 30 : 20;
              // double fontSizeTitle = constraints.maxWidth >= 1000 ? 20 : 14;
              // double fontSizeContent = constraints.maxWidth >= 1000 ? 16 : 12;
              // double fontSizeLabel = constraints.maxWidth >= 1000 ? 16 : 12;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: novels.length,
                itemBuilder: (context, index) {
                  final novel = novels[index];
                  return SizedBox(
                    width: constraints.maxWidth * 0.55,
                    height: constraints.maxHeight * 0.25,
                    child: Center(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              showGeneralDialog(
                                context: context,
                                barrierLabel: "EditNovel",
                                barrierDismissible: false,
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                                pageBuilder: (context, anim1, anim2) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: EditNovelUi(
                                        novelData: novel,
                                        userData: userData!,
                                      ),
                                    ),
                                  );
                                },
                                transitionBuilder:
                                    (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween(
                                      begin: const Offset(1, 0),
                                      end: const Offset(0, 0),
                                    ).animate(anim1),
                                    child: child,
                                  );
                                },
                              ).then((_) {
                                // เมื่อ dialog ถูกปิด ให้ทำการโหลดข้อมูลใหม่
                                setState(() {
                                  // เรียก fetchAuthorLibrary อีกครั้งเพื่อ refresh หน้าหลังจากการปิด dialog
                                  fetchAuthorLibrary();
                                });
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    left: constraints.maxWidth * 0.005,
                                  ),
                                  child: Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.cyan[800],
                                    size: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: constraints.maxHeight * 0.005,
                                    bottom: constraints.maxHeight * 0.005,
                                    left: constraints.maxWidth * 0.005,
                                  ),
                                  width: constraints.maxWidth * 0.10,
                                  height: constraints.maxHeight * 0.285,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: novel['novel_cover_image'] != null &&
                                            novel['novel_cover_image']
                                                .isNotEmpty
                                        ? Image.memory(
                                            base64Decode(
                                                novel['novel_cover_image']),
                                            width: constraints.maxWidth * 0.265,
                                            height: constraints.maxHeight * 0.3,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/cover/novel1.jpg',
                                            width: constraints.maxWidth * 0.265,
                                            height: constraints.maxHeight * 0.3,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            margin: EdgeInsets.only(
                              left: constraints.maxWidth * 0.01,
                              top: constraints.maxHeight * 0.01,
                              bottom: constraints.maxHeight * 0.01,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  novel['novel_title'] ?? 'ไม่มีชื่อ',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.021,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyan[900],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: constraints.maxHeight * 0.01,
                                ),
                                Text(
                                  novel['genres'] ?? '',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Colors.cyan[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: constraints.maxHeight * 0.01,
                                ),
                                Text(
                                  'บทนำ :',
                                  style: TextStyle(
                                    color: Colors.cyan[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${novel['novel_description'] ?? ''}',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.020,
                                    color: Colors.cyan[900],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: constraints.maxHeight * 0.01,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        top: constraints.maxHeight * 0.005,
                                      ),
                                      child: Icon(
                                        Icons.remove_red_eye_rounded,
                                        color: Colors.cyan[800],
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.03,
                                      ),
                                    ),
                                    Text(
                                      ' ${novel['novel_views']} ',
                                      style: TextStyle(
                                        color: Colors.cyan[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.022,
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth * 0.025,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        top: constraints.maxHeight * 0.0025,
                                      ),
                                      child: Icon(
                                        Icons.view_list_rounded,
                                        color: Colors.cyan[800],
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.03,
                                      ),
                                    ),
                                    Text(
                                      ' ${novel['episode_count']} ',
                                      style: TextStyle(
                                        color: Colors.cyan[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.022,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
