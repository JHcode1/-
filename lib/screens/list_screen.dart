import 'package:toonflix/models/webtoon_model_naver.dart';
import 'package:toonflix/models/webtoon_model_kakao.dart';
import 'package:toonflix/screens/detail_screen.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

// ignore: must_be_immutable
class ListScreen extends StatelessWidget {
  final String txt;
  ListScreen({super.key, required this.txt});

  final List<String> servicesNameKr = ['네이버 웹툰', '카카오페이지 웹툰', '카카오 웹툰'];
  final List<String> servicesNameEng = ['naver', 'kakao_Page', 'kakao'];

  final Future<List<WebtoonModel>> webtoonsNaver = ApiService.getTodaysToons();
  late Future<List<WebtoonModelKakao>> webtoonsKakao;
  late Future<List<WebtoonModelKakao>> webtoonsKakaoPage;

  void initializeWebtoons() {
    webtoonsKakaoPage = ApiService.getTodaysKakaoToons(servicesNameEng[1]);
    webtoonsKakao = ApiService.getTodaysKakaoToons(servicesNameEng[2]);
  }

  @override
  Widget build(BuildContext context) {
    initializeWebtoons();

    String provider = txt;

    late String serviceEng = '';
    late Future webtoonApi;

    if (provider == servicesNameKr[0]) {
      webtoonApi = webtoonsNaver;
      serviceEng = servicesNameEng[0];
    } else if (provider == servicesNameKr[1]) {
      webtoonApi = webtoonsKakaoPage;
      serviceEng = servicesNameEng[1];
    } else {
      webtoonApi = webtoonsKakao;
      serviceEng = servicesNameEng[2];
    }

    {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          title: Text(
            "오늘의 $provider ",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Pretendard',
            ),
          ),
          elevation: 0.0,
        ),
        body: SizedBox(
          child: FutureBuilder(
              future: webtoonApi,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      var webtoon = snapshot.data![index];

                      return webtoonBox(context, webtoon, serviceEng);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 15),
                  );
                }
                return const Center(
                    child: CircularProgressIndicator(color: Colors.green));
              }),
        ),
      );
    }
  }

  Widget webtoonBox(BuildContext context, webtoon, String serviceEng) {
    return InkWell(
      onTap: () {
        serviceEng == servicesNameEng[0]
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailScreen(
                        webtoonId: webtoon.id,
                        thumbnail: webtoon.thumb,
                        title: webtoon.title,
                        provider: serviceEng)))
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailScreen(
                        webtoonId: webtoon.id,
                        thumbnail: webtoon.thumbnail.isNotEmpty
                            ? webtoon.thumbnail[0]
                            : '',
                        title: webtoon.title,
                        provider: serviceEng)));
      },
      child: Hero(
        tag: webtoon.id,
        child: Row(
          children: [
            Container(
              height: 200,
              width: 150,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xfffcf0f0)),
              padding: const EdgeInsets.only(left: 10, right: 6),
              child: Image.network(
                serviceEng == servicesNameEng[0]
                    ? webtoon.thumb
                    : (webtoon.thumbnail.isNotEmpty
                        ? webtoon.thumbnail[0]
                        : ''),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                headers: const {
                  "User-Agent":
                      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                },
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              height: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          webtoon.title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // const Icon(Icons.favorite_border_outlined, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
