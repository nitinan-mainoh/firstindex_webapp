// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'package:firstindex_webapp/sharedata.dart';
import 'package:flutter/material.dart';

class ProfileUi extends StatefulWidget {
  const ProfileUi({super.key});

  @override
  State<ProfileUi> createState() => _ProfileUiState();
}

class _ProfileUiState extends State<ProfileUi> {
  Map<String, dynamic>? userData; // ประกาศตัวแปรเพื่อเก็บข้อมูล User

  @override
  void initState() {
    super.initState();
    loadUserData(); // โหลดข้อมูล User จาก API ก่อนโหลดหน้าจอ
  }

// ฟังก์ชั่นโหลดข้อมูล User จาก API
  Future<void> loadUserData() async {
    // สร้างตัวแปร datainfo เก็บข้อมูลจาก API
    final datainfo = await fetchUserData(context);
    // ตรวจสอบว่า datainfo ไม่เป็นค่าว่าง
    if (datainfo != null) {
      setState(
        () {
          // นำข้อมูล User จาก datainfo ไปยังตัวแปร userData เพื่อใช้งานในหน้าจอ
          userData = datainfo;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: Center(
          child: Text(
            "โปรไฟล์ นักเขียนนิยาย",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
              color: Colors.cyan[50],
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.cyan[700]!,
                width: 6.5,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.22,
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email:',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${userData?['email']}',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            color: Colors.cyan[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    decoration: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Colors.cyan[600]!,
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.22,
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ชื่อ:',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${userData?['username']}',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            color: Colors.cyan[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    decoration: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Colors.cyan[600]!,
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.22,
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'จำนวนนิยายทั้งหมด:',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            // fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${userData?['novel_count']}',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            color: Colors.cyan[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    decoration: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Colors.cyan[600]!,
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.20,
                height: MediaQuery.of(context).size.height * 0.28,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  shape: BoxShape.circle,
                ),
                child: userData?['profile_image'] != null
                    ? Image.memory(
                        base64Decode(userData!['profile_image']),
                      )
                    : Image.asset('assets/images/profile_image.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
