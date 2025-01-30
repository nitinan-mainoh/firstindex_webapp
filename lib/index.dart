import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firstindex_webapp/views/home_ui.dart';
import 'package:firstindex_webapp/views/mylibrary_ui.dart';
import 'package:firstindex_webapp/views/new_novel_ui.dart';
import 'package:firstindex_webapp/views/profile_ui.dart';
import 'package:flutter/material.dart';
import 'package:firstindex_webapp/sharedata.dart';

class Index extends StatefulWidget {
  final int initialPage;

  const Index({super.key, this.initialPage = 0}); // ค่าเริ่มต้นหน้าแรก

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  // final PageController _pageController = PageController();
  // final SideMenuController _sideMenuController = SideMenuController();
  late PageController _pageController;
  late SideMenuController _sideMenuController;

  // กำหนดรายการของหน้าต่างๆ ที่จะใช้ใน PageView เรียงตามลำดับ
  final List<Widget> _pages = [
    HomeUi(),
    MylibraryUi(),
    NewNovelUi(),
    ProfileUi(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _sideMenuController = SideMenuController();

    _sideMenuController.addListener((index) {
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sideMenuController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            'ออกจากระบบ',
            style: TextStyle(
              color: Colors.cyan[800],
              fontSize: MediaQuery.of(context).size.height * 0.0265,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: Colors.cyan[800],
                indent: 10.0,
                endIndent: 10.0,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.0125,
              ),
              Text(
                'คุณต้องการออกจากระบบหรือไม่?',
                style: TextStyle(
                  color: Colors.cyan[900],
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.065,
                    child: TextButton(
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
                      onPressed: () {
                        Navigator.of(context)
                            .pop(false); // ปิด Dialog ด้วยการยกเลิก
                      },
                      child: Text('ยกเลิก'),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.065,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true); // ปิด Dialog และยืนยัน
                      },
                      child: Text('ยืนยัน'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await logout(context); // เรียกฟังก์ชัน logout หากยืนยัน
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            controller: _sideMenuController,
            style: SideMenuStyle(
              showHamburger: true,
              displayMode: SideMenuDisplayMode.auto,
              hoverColor: Colors.cyan[100], // สีเมื่อ hover
              selectedColor: Colors.cyan[800], // สีเมื่อ selected
              selectedTitleTextStyle: TextStyle(color: Colors.white),
              selectedIconColor: Colors.white, // สีไอคอนเมื่อ selected
              backgroundColor: Colors.cyan[50],
              unselectedTitleTextStyle: TextStyle(color: Colors.black),
              unselectedIconColor: Colors.cyan[800],
            ),
            title: Column(
              children: [
                Center(
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: Text(
                        'First Index',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[900],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Divider(
                    color: Colors.cyan[800],
                    thickness: 1,
                    indent: 10.0,
                    endIndent: 10.0,
                  ),
                )
              ],
            ),
            footer: Container(
              color: Colors.blueGrey[200],
              height: MediaQuery.of(context).size.height * 0.07,
              alignment: Alignment.bottomCenter,
              child: Center(
                child: Text(
                  'First Index © 2024',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            items: [
              SideMenuItem(
                title: 'หน้าแรก',
                icon: Icon(Icons.home),
                onTap: (index, _) {
                  _sideMenuController.changePage(0); // ไปหน้า Home
                },
              ),
              SideMenuItem(
                title: 'ชั้นหนังสือ',
                icon: Icon(Icons.library_books),
                onTap: (index, _) {
                  _sideMenuController.changePage(1); // ไปหน้า Mylibrary
                },
              ),
              SideMenuItem(
                title: 'เพิ่มนิยายเรื่องใหม่',
                icon: Icon(Icons.add_box),
                onTap: (index, _) {
                  _sideMenuController.changePage(2); // ไปหน้า New Novel
                },
              ),
              SideMenuItem(
                title: 'โปรไฟล์',
                icon: Icon(Icons.person),
                onTap: (index, _) {
                  _sideMenuController.changePage(3); // ไปหน้า Profile
                },
              ),
              SideMenuItem(
                builder: (context, displayMode) => Divider(
                  color: Colors.cyan[800],
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
              ),
              SideMenuItem(
                icon: Icon(Icons.logout),
                title: 'ออกจากระบบ',
                onTap: (index, _) async {
                  await _confirmLogout(context); // เรียกฟังก์ชันแสดง Dialog
                },
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _pages,
              onPageChanged: (index) {
                _sideMenuController
                    .changePage(index); // อัพเดตเมนูเมื่อเปลี่ยนหน้า
              },
            ),
          ),
        ],
      ),
    );
  }
}
