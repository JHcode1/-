import 'package:flutter/material.dart';
import 'package:toonflix/screens/detail_screen.dart';

class MainThumbWidget extends StatelessWidget {
  final String title, id, thumb, service;
  const MainThumbWidget(
      {super.key,
      required this.title,
      required this.thumb,
      required this.id,
      required this.service});

  @override
  Widget build(BuildContext context) {
    {
      return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailScreen(
                        webtoonId: id,
                        img: thumb,
                        title: title,
                        service: service)));
          },
          child: Column(
            children: [
              Hero(
                tag: id,
                child: Container(
                  width: 250,
                  decoration: const BoxDecoration(color: Color(0xfffcf0f0)),
                  child: Stack(
                    children: [
                      Image.network(
                        thumb,
                        headers: const {
                          "User-Agent":
                              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                        },
                      ),
                      if (service != 'naver' && service == 'kakaoPage')
                        kakaoPageContainer(),
                    ],
                  ),
                ),
              ),
              if (service != 'naver' && service != 'kakaoPage') kakaoContainer()
            ],
          ));
    }
  }

  Widget kakaoContainer() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget kakaoPageContainer() {
    return Positioned(
        width: 250,
        bottom: 20,
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }
}
