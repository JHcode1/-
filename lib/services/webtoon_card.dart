import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toonflix/models/webtoon_model_kakao.dart'; // WebtoonModelKakao 임포트

class WebtoonCard extends StatelessWidget {
  final WebtoonModelKakao webtoon;

  const WebtoonCard({super.key, required this.webtoon});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url); // url을 Uri로 변환

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri); // 제공된 URL로 이동
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 카카오 웹툰 또는 카카오페이지는 제공된 URL로 이동
        if (webtoon.provider == "KAKAO" || webtoon.provider == "KAKAO_PAGE") {
          _launchURL(webtoon.url); // 웹 페이지로 이동
        }
      },
      child: Card(
        child: Column(
          children: [
            Image.network(webtoon.thumbnail.isNotEmpty
                ? webtoon.thumbnail[0]
                : ''), // Image.network(webtoon.thumbnail[0]), // 썸네일 이미지
            Text(webtoon.title),
          ],
        ),
      ),
    );
  }
}
