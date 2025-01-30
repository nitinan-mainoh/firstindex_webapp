// ignore_for_file: avoid_web_libraries_in_flutter, sort_child_properties_last

import 'package:firstindex_webapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class NewNovelUi extends StatefulWidget {
  const NewNovelUi({super.key});

  @override
  State<NewNovelUi> createState() => _NewNovelUiState();
}

class _NewNovelUiState extends State<NewNovelUi> {
  Map<String, dynamic>? userData; // ประกาศตัวแปรเพื่อเก็บข้อมูล User

  final TextEditingController _novelTitleController = TextEditingController();
  final TextEditingController _novelDescriptionController =
      TextEditingController();

  Uint8List? _coverImageBytes;
  String? _coverImageBase64;

  bool isSelected = true;

  @override
  void initState() {
    super.initState();
    loadUserData(); // โหลดข้อมูล User จาก API ก่อนโหลดหน้าจอ
  }

  void pickImage() {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _coverImageBytes = reader.result as Uint8List?;
            _coverImageBase64 = base64Encode(_coverImageBytes!);
          });
        });
      }
    });
  }

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

  Future<void> _showWarningDialog(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Column(
            children: [
              Text(
                'ข้อความจากระบบ',
                style: TextStyle(
                  color: Colors.cyan[900],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Divider(
                color: Colors.cyan[800],
                indent: 10.0,
                endIndent: 10.0,
              ),
            ],
          ),
          content: Text(message,
              style: TextStyle(
                color: Colors.cyan[800],
                fontSize: 16,
              ),
              textAlign: TextAlign.center),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text(
                  'ตกลง',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Colors.cyan[800]!,
                      width: 1.5,
                    ),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.cyan[800],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

//ฟังก์ชั่นสำหรับเพิ่มนิยายเรื่องใหม่
  Future<void> addNewNovel() async {
    final response = await http.post(
      Uri.parse('${CallAPI.hostURL}/addNewNovel'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": _novelTitleController.text,
        "description": _novelDescriptionController.text,
        "cover_image": _coverImageBase64,
        "author_id": userData!['user_id'],
      }),
    );
    if (response.statusCode == 201) {
      // แสดงข้อความแจ้งเตือนเมื่อเพิ่มนิยายสำเร็จ
      await _showWarningDialog('เพิ่มนิยายเรื่องใหม่เรียบร้อยแล้ว');

      setState(() {
        _novelTitleController.clear();
        _novelDescriptionController.clear();
        _coverImageBytes = null;
        _coverImageBase64 = null;
      });

      // ย้อนกลับไปหน้าก่อนหน้า
    } else {
      // แสดงข้อความแจ้งเตือนข้อผิดพลาดหากเพิ่มนิยายไม่สำเร็จ
      await _showWarningDialog('เกิดข้อผิดพลาดในการเพิ่มนิยาย โปรดลองอีกครั้ง');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: Text(
          'กำหนดรายละเอียดของนิยายเรื่องใหม่',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 50, left: 100, right: 100, bottom: 50),
          child: Column(
            children: [
              _buildNovelForm(),
              SizedBox(height: 20),
              _buildAddButton(),
              SizedBox(height: 20),
              Divider(thickness: 1.0, color: Colors.cyan[900]),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNovelForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.065,
              child: Text(
                'ชื่อนิยาย : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan[900],
                ),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            Expanded(
              child: TextField(
                controller: _novelTitleController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.cyan[800],
                  ),
                  hintText: 'ระบุชื่อของนิยาย',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.cyan[800]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.065,
              child: Text(
                'บทนำ : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan[900],
                ),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            Expanded(
              child: TextField(
                controller: _novelDescriptionController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.cyan[800],
                  ),
                  hintText: 'บทนำ ของนิยาย',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.cyan[800]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.065,
              child: Text(
                'ปกนิยาย : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan[900],
                ),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            ElevatedButton(
              onPressed: pickImage,
              child: Text(
                'เลือกรูปภาพ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[800],
                elevation: 5.0,
                padding: EdgeInsets.symmetric(vertical: 21.0, horizontal: 22.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            SizedBox(width: 10),
            _coverImageBytes != null
                ? Image.memory(
                    _coverImageBytes!,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.image, size: 100, color: Colors.grey[400]),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.065,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            Container(
              padding: EdgeInsets.only(left: 130),
              child: _coverImageBase64 != null
                  ? Text(
                      "รูปภาพถูกแปลงเป็น Base64 สำเร็จแล้ว",
                      style: TextStyle(color: Colors.cyan[800]),
                    )
                  : Container(),
            ),
          ],
        ),
      ],
    );
  }

// ปุ่มบันทึกข้อมูลนิยาย
  Widget _buildAddButton() {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.065,
          child: Text(
            'บันทึกข้อมูล : ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.cyan[900],
            ),
            textAlign: TextAlign.end,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.01,
        ),
        Container(
          width: 200,
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: addNewNovel,
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.white, size: 22),
                SizedBox(width: 5),
                Text(
                  'เพิ่มนิยายเรื่องใหม่',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan[800],
              elevation: 5.0,
              padding: EdgeInsets.symmetric(vertical: 21.0, horizontal: 22.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
