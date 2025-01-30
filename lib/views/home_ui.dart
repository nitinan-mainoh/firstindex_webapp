// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

final List<String> imgList = [
  'assets/images/cover/ads1.jpg',
  'assets/images/cover/ads2.jpg',
  'assets/images/cover/ads3.jpg',
  'assets/images/cover/ads4.jpg',
];

class _HomeUiState extends State<HomeUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: Center(
          child: Text(
            "FIRST INDEX",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          // final double height = MediaQuery.of(context).size.height;
          return Center(
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                pageSnapping: true,
                viewportFraction: 0.4,
                enlargeCenterPage: false,
              ),
              items: imgList
                  .map(
                    (item) => Container(
                      margin: EdgeInsets.all(5.0),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            item,
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height * 0.7,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
