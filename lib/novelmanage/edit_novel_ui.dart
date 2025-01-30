// ignore_for_file: avoid_web_libraries_in_flutter, sort_child_properties_last, avoid_unnecessary_containers, sized_box_for_whitespace, collection_methods_unrelated_type, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:firstindex_webapp/index.dart';
import 'package:firstindex_webapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class EditNovelUi extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? novelData;

  const EditNovelUi({
    super.key,
    this.userData,
    this.novelData,
  });

  @override
  State<EditNovelUi> createState() => _EditNovelUiState();
}

class _EditNovelUiState extends State<EditNovelUi> {
  List<Map<String, dynamic>> episodes = [];
  Map<String, dynamic>? selectedEpisode;
  Uint8List? _coverImageBytes;
  String? _coverImageBase64;
  List<int> selectedTags = [];
  bool isSelected = true;
  bool checkUpdateButton = false; // กำหนดสถานะเริ่มต้นของ Checkbox Update
  bool checkDeleteButton = false; // กำหนดสถานะเริ่มต้นของ Checkbox Delete

  final _novelTitleController = TextEditingController();
  final _novelDescriptionController = TextEditingController();
  final _newEpisodeTitleController = TextEditingController();
  final _newEpisodeContentController = TextEditingController();

//กำหนดค่าของปุ่มให้ตรงกับค่า tag ของนิยาย
  final Map<int, String> tagMap = {
    1: 'ผจญภัย',
    2: 'แฟนตาซี',
    3: 'วิทยาศาสตร์',
    4: 'โรแมนติก',
    5: 'สยองขวัญ',
    6: 'ลึกลับ',
    7: 'กำลังภายใน',
  };

  @override
  void initState() {
    super.initState();
    fetchEpisodes();
  }

  // ฟังก์ชันเลือกไฟล์รูปภาพสำหรับ Web และแปลงเป็น Base64
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

  Future<void> _showWarningDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Divider(
                color: Colors.cyan[800],
                indent: 10.0,
                endIndent: 10.0,
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.cyan[800],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
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
          ],
        );
      },
    );
  }

  Future<void> _showWarningDeleteDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Divider(
                color: Colors.cyan[800],
                indent: 10.0,
                endIndent: 10.0,
              ),
            ],
          ),
          content: Text(
            "นิยายเรื่องนี้อาจจะกำลังถูกอ่านหรือเก็บไว้ในชั้นหนังสือของผู้อ่าน\nซึ่งอาจจะทำให้คุณสูญเสียผู้อ่านได้ ต้องการลบนิยายเรื่องนี้หรือไม่",
            style: TextStyle(
              color: Colors.cyan[800],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_forever, color: Colors.white), // ไอคอนลบ
                  SizedBox(width: 5.0),
                  Text('ยืนยันการลบนิยาย'),
                ],
              ),
              onPressed: () {
                deleteNovel();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
            ),
            TextButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, color: Colors.white), // ไอคอนยกเลิก
                  SizedBox(width: 5),
                  Text('ยกเลิก'),
                ],
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
          ],
        );
      },
    );
  }

  // ฟังก์ชันดึงข้อมูลตอนต่างๆ
  Future<void> fetchEpisodes() async {
    if (widget.novelData?['novel_id'] == null) {
      return;
    }
    final response = await http.get(Uri.parse(
        '${CallAPI.hostURL}/novelepisode?novel_id=${widget.novelData?['novel_id']}'));
    if (response.statusCode == 200) {
      final List<dynamic> episodeData = jsonDecode(response.body);
      // final List<dynamic> tagData = jsonDecode(response.body);
      setState(() {
        episodes = List<Map<String, dynamic>>.from(episodeData);

        if (episodes.isNotEmpty) {
          selectedEpisode = episodes[0];
        }
      });
    } else {
      await _showWarningDialog('นิยายยังไม่มีเนื้อหา กรุณาเพิ่มเนื้อหาก่อน');
    }
  }

//ฟังก์ชัน update ข้อมูลนิยาย
  Future<void> updateNovel() async {
    final Map<String, dynamic> requestBody = {
      "title": _novelTitleController.text.isNotEmpty
          ? _novelTitleController.text
          : widget.novelData?['novel_title'],
      "description": _novelDescriptionController.text.isNotEmpty
          ? _novelDescriptionController.text
          : widget.novelData?['novel_description'],
      "cover_image":
          _coverImageBase64 ?? widget.novelData?['novel_cover_image'],
      "tagId":
          selectedTags.isNotEmpty ? selectedTags : widget.novelData!['tag_ids'],
      "novel_id": widget.novelData?['novel_id']
    };

    try {
      final response = await http.put(
        Uri.parse('${CallAPI.hostURL}/updateNovelInfo'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        await _showWarningDialog('แก้ไขข้อมูลนิยายเรียบร้อยแล้ว');

        setState(() {
          _novelTitleController.clear();
          _novelDescriptionController.clear();
          _coverImageBytes = null;
          _coverImageBase64 = null;
          checkUpdateButton = false;
        });
      }
    } catch (error) {
      await _showWarningDialog('เกิดข้อผิดพลาดในการแก้ไขข้อมูลนิยาย: $error');
    }
  }

//ฟังชั่นสำหรับการเพิ่มชื่อและเนื้อหาของนิยาย
  Future<void> addEpisode(String newtitle, String newcontent) async {
    final Map<String, dynamic> requestBody = {
      // "novel_id": widget.novelData!['novel_id'],
      "title": newtitle,
      "content": newcontent,
    };

    try {
      final response = await http.post(
        Uri.parse(
            '${CallAPI.hostURL}/addEpisode?novel_id=${widget.novelData?['novel_id']}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 201) {
        await _showWarningDialog('เพิ่มเนื้อหานิยายเรียบร้อยแล้ว');
      }
    } catch (error) {
      await _showWarningDialog(
        'เกิดข้อผิดพลาดในการเพิ่มเนื้อหานิยาย : $error',
      );
    }
  }

//ฟังก์ชั่นสำหรับการแก้ไขชื่อและเนื้อหาของนิยาย
  Future<void> updateEpisode(String title, String content) async {
    final Map<String, dynamic> requestBody = {
      "episode_id": selectedEpisode?['episode_id'],
      "title": title,
      "content": content,
    };

    try {
      final response = await http.put(
        Uri.parse(
            '${CallAPI.hostURL}/updateEpisode?episode_id=${selectedEpisode?['episode_id']}&novel_id=${widget.novelData?['novel_id']}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        await _showWarningDialog('แก้ไขเนื้อหานิยายเรียบร้อยแล้ว');
      }
    } catch (error) {
      await _showWarningDialog('พบข้อผิดพลาดในการแก้ไขเนื้อหานิยาย: $error');
    }
  }

//ฟังก์ชั่นสำหรับการลบนิยาย
  Future<void> deleteNovel() async {
    try {
      final response = await http.delete(Uri.parse(
          '${CallAPI.hostURL}/deleteNovel?novel_id=${widget.novelData?['novel_id']}'));
      if (response.statusCode == 200) {
        await _showWarningDialog('ลบนิยายเรียบร้อยแล้ว');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                Index(initialPage: 1), // เริ่มที่หน้า list index 1
          ),
          (Route<dynamic> route) => false, // ลบ stack ทั้งหมด
        );
      }
    } catch (error) {
      await _showWarningDialog('เกิดข้อผิดพลาดในการลบนิยาย: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: Row(
          children: [
            Text(
              'แก้ไขรายละเอียดนิยาย : ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Text(
                '${widget.novelData?['novel_title'] ?? 'No Title'}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.cyanAccent,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 50, left: 100, right: 100, bottom: 50),
          child: Column(
            children: [
              _buildNovelInfo(),
              SizedBox(height: 20),
              _buildTaginfo(),
              SizedBox(height: 35),
              _buildUpdateButton(),
              SizedBox(height: 20),
              Divider(thickness: 1.0, color: Colors.cyan[900]),
              SizedBox(height: 20),
              _buildEpisodeDropdown(),
              SizedBox(height: 20),
              selectedEpisode != null ? _buildEpisodeContent() : Container(),
              SizedBox(height: 20),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  // สร้าง Widget UI สําหรับแสดงรายละเอียดนิยาย
  Widget _buildNovelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
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
                  hintText:
                      widget.novelData?['novel_title'] ?? 'ไม่มีชื่อเรื่อง',
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
            Container(
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
                maxLines: 5,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.cyan[800],
                  ),
                  hintText:
                      widget.novelData?['novel_description'] ?? 'ไม่มีบทนำ',
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
            Container(
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
              child: Row(
                children: [
                  Icon(Icons.image_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 5),
                  Text(
                    'เลือกรูปภาพ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 22.0),
                backgroundColor: Colors.cyan[800],
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            SizedBox(width: 10),
            _coverImageBytes != null
                ? Image.memory(
                    _coverImageBytes!,
                    width: 200,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : widget.novelData?['cover_image'] != null
                    ? Image.memory(
                        base64Decode(widget.novelData!['cover_image']),
                        width: 200,
                        height: 300,
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
              padding: EdgeInsets.only(left: 165),
              child: _coverImageBase64 != null
                  ? Text(
                      "เลื่อกรูปภาพ สำเร็จแล้ว",
                      style: TextStyle(color: Colors.cyan, fontSize: 16),
                    )
                  : Container(),
            ),
          ],
        ),
      ],
    );
  }

// สร้าง Widget สําหรับสร้างปุ่ม
  Widget _buildTaginfo() {
    return Container(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.065,
                child: Text(
                  'ประเภท : ',
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
                alignment: Alignment.center,
                width: 132,
                height: 73,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.cyan,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  '${widget.novelData?['genres'] ?? 'ไม่มีประเภท'}'
                      .split(', ')
                      .join('\n'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              // ใช้ Warp ควบคุมขนาดของปุ่ม
              Container(
                child: Expanded(
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    // ใช้ tagMap ในการสร้างปุ่มแต่ละแท็ก โดยส่ง tagId
                    children: tagMap.keys.map((tagId) {
                      return _buildTagButton(tagId);
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

//สร้าง Widget ปุ่มเลือกประเภทนิยาย
  Widget _buildTagButton(int tagId) {
    bool isSelected = selectedTags.contains(tagId);

    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isSelected) {
            selectedTags.remove(tagId);
          } else {
            if (selectedTags.length < 2) {
              selectedTags.add(tagId);
            }
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.cyan[700] : Colors.white,
        shadowColor: Colors.black,
        padding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.cyan[800]!,
          width: 1,
        ),
      ),
      child: Text(
        tagMap[tagId]!, // ใช้ tagMap เพื่อแสดงชื่อแท็กตาม tagId
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Colors.white : Colors.cyan[900],
        ),
      ),
    );
  }

//สร้าง Widget ปุ่มบันทึกข้อมูลนิยาย
  Widget _buildUpdateButton() {
    return Row(
      children: [
        Container(
          width: 360,
          decoration: BoxDecoration(
            border: Border.all(
              color: checkUpdateButton ? Colors.cyan : Colors.cyan[900]!,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: CheckboxListTile(
            selectedTileColor: Colors.cyan,
            activeColor: Colors.cyan,
            value: checkUpdateButton,
            title: Text(
              'ต้องการแก้ไขรายละเอียดของนิยาย ?',
              style: TextStyle(
                color: checkUpdateButton ? Colors.cyan : Colors.cyan[900],
                fontSize: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {
                checkUpdateButton = value!; // เปลี่ยนค่าของ checkDeleteButton
              });
            },
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.01,
        ),
        Container(
          width: 175,
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: checkUpdateButton ? updateNovel : null,
            child: Row(
              children: [
                Icon(Icons.save_alt_rounded, color: Colors.white, size: 20),
                SizedBox(width: 5),
                Text(
                  'บันทึกการแก้ไข',
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

  //สร้าง Widget DropdownButton สำหรับเลือกตอน
  Widget _buildEpisodeDropdown() {
    return Container(
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.065,
            child: Text(
              'เลือกตอน : ',
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
            width: MediaQuery.of(context).size.width * 0.125,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.cyan[800]!,
                  width: 1.0,
                ),
              ),
              child: DropdownButton<Map<String, dynamic>>(
                underline: Container(
                  color: Colors.transparent,
                ),
                focusColor: Colors.transparent,
                dropdownColor: Colors.cyan[100],
                isExpanded: true,
                value: selectedEpisode,
                items: episodes
                    .map((episode) => DropdownMenuItem(
                          value: episode,
                          child: Text(
                            '   ตอนที่  ${episode['episode_number']}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.cyan[900]),
                          ),
                        ))
                    .toList(),
                onChanged: (newEpisode) {
                  setState(() {
                    selectedEpisode = newEpisode;
                  });
                },
                hint: Text(
                  '   เลือกตอนของนิยาย',
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.01,
          ),

          //สร้างปุ่มเพิ่มตอนใหม่ ///////////////////////
          Container(
            width: 160,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      title: Row(
                        children: [
                          Text(
                            'ระบุชื่อตอนและเนื่อหาของตอนใหม่',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.cyan[900],
                            ),
                          ),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextField(
                                controller: _newEpisodeTitleController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  hintText: 'ชื่อตอน',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextField(
                                controller: _newEpisodeContentController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  hintText: 'เนื่อหาตอน',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      actions: [
                        Container(
                          width: 100,
                          child: TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_presentation_rounded,
                                    color: Colors.white),
                                SizedBox(width: 5),
                                Text("ยกเลิก"),
                              ],
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _newEpisodeTitleController
                                  .clear(); // ล้างค่า TextField
                              _newEpisodeContentController
                                  .clear(); // ล้างค่า TextField
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          child: TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_alt_rounded,
                                    color: Colors.cyan[800]),
                                SizedBox(width: 5),
                                Text("บันทึก"),
                              ],
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await addEpisode(
                                  _newEpisodeTitleController.text,
                                  _newEpisodeContentController
                                      .text); // ส่งค่าพารามิเตอร์
                              _newEpisodeTitleController
                                  .clear(); // ล้างค่า TextField
                              _newEpisodeContentController
                                  .clear(); // ล้างค่า TextField
                              await fetchEpisodes();
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(
                                  color: Colors.cyan[800]!,
                                  width: 1.5,
                                ),
                              ),
                              foregroundColor: Colors.cyan[800],
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 22),
                  SizedBox(width: 5),
                  Text(
                    'เพิ่มตอนใหม่',
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
      ),
    );
  }

  //สร้าง Widget แสดงเนื้อหาของตอนที่เลือก และปุ่มแก้ไข
  Widget _buildEpisodeContent() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan[900]!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
          ),
          Text(
            selectedEpisode?['title'] ?? '',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Divider(),
          SizedBox(
            height: 15,
          ),
          Text(
            selectedEpisode?['content'] ?? '',
            style: TextStyle(fontSize: 16),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 15,
          ),
          Divider(),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _openEditEpisodeDialog(selectedEpisode!),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note_rounded,
                          color: Colors.cyan[900], size: 22),
                      SizedBox(width: 5),
                      Text(
                        'แก้ไขชื่อตอนและเนื้อหา',
                        style: TextStyle(
                          color: Colors.cyan[900],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 5.0,
                    padding:
                        EdgeInsets.symmetric(vertical: 21.0, horizontal: 22.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    side: BorderSide(
                      color: Colors.cyan[900]!,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 13,
          )
        ],
      ),
    );
  }

  // ฟังก์ชันเปิด Dialog สำหรับแก้ไขตอนที่เลือก
  void _openEditEpisodeDialog(Map<String, dynamic> episode) {
    final TextEditingController episodeTitleController =
        TextEditingController(text: episode['title']);
    final TextEditingController episodeContentController =
        TextEditingController(text: episode['content']);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          title: Row(
            children: [
              Text('แก้ไขชื่อและเนื้อหาของนิยาย '),
              Text(
                '${widget.novelData!['novel_title']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan[900],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextField(
                    controller: episodeTitleController,
                    maxLines: null,
                    decoration: InputDecoration(hintText: 'ชื่อตอน'),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextField(
                    controller: episodeContentController,
                    maxLines:
                        null, // เพิ่มขีดจำกัดของ maxLines เพื่อการแสดงเนื้อหาที่ยาวขึ้น
                    decoration: InputDecoration(hintText: 'เนื้อหาตอน'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              width: 100,
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_presentation_rounded,
                        color: Colors.white),
                    SizedBox(width: 5),
                    Text("ยกเลิก"),
                  ],
                ),
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
            Container(
              width: 100,
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_alt_rounded, color: Colors.cyan[800]),
                    SizedBox(width: 5),
                    Text("บันทึก"),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    episode['title'] = episodeTitleController.text;
                    episode['content'] = episodeContentController.text;
                  });
                  Navigator.of(context).pop();
                  updateEpisode(episodeTitleController.text,
                      episodeContentController.text); // ส่งค่าพารามิเตอร์
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Colors.cyan[800]!,
                      width: 1.5,
                    ),
                  ),
                  foregroundColor: Colors.cyan[800],
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //สร้าง Widget สําหรับปุ่มลบนิยาย
  Widget _buildDeleteButton() {
    return Row(
      children: [
        Container(
          width: 360,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent, width: 1.2),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: CheckboxListTile(
            selectedTileColor: Colors.cyan,
            activeColor: Colors.redAccent,
            value: checkDeleteButton,
            title: Text(
              'ต้องการลบนิยายเรื่องนี้หรือไม่ ?',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {
                checkDeleteButton = value!; // เปลี่ยนค่าของ checkDeleteButton
              });
            },
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Container(
          width: 130,
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: checkDeleteButton ? _showWarningDeleteDialog : null,
            child: Row(
              children: [
                Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 5),
                Text(
                  'ลบนิยาย',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  checkDeleteButton ? Colors.redAccent : Colors.grey,
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
