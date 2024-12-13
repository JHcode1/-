import 'package:flutter/material.dart';
import 'package:toonflix/models/webtoon_model_naver.dart';
import 'package:toonflix/models/webtoon_model_kakao.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/screens/list_screen.dart';
import 'package:toonflix/widgets/webtoon_widget.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<String> servicesNameKr = ['네이버 웹툰', '카카오페이지 웹툰', '카카오 웹툰'];
  final List<String> servicesNameEng = ['naver', 'kakaoPage', 'kakao'];

  final Future<List<WebtoonModel>> webtoonsNaver = ApiService.getTodaysToons();
  late Future<List<WebtoonModelKakao>> webtoonsKakaoPage;
  late Future<List<WebtoonModelKakao>> webtoonsKakao;

  void initializeWebtoons() {
    webtoonsKakaoPage = ApiService.getTodaysKakaoToons(servicesNameEng[1]);
    webtoonsKakao = ApiService.getTodaysKakaoToons(servicesNameEng[2]);
  }

  int basicListCount = 5;

  @override
  Widget build(BuildContext context) {
    initializeWebtoons();
    initializeDateFormatting('ko_KR', null);

    DateTime now = DateTime.now();
    String dayOfWeek = DateFormat('EEEE', 'ko_KR').format(now);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          title: const Text(
            "오늘의 웹툰",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Column(
              children: [
                ListBetweenSizeBox(),
                mainNaver(),
                ListBetweenSizeBox(),
                webtoonKakao(webtoonsKakaoPage, servicesNameKr[1]),
                ListBetweenSizeBox(),
                webtoonKakao(webtoonsKakao, servicesNameKr[2]),
              ],
            ),
          ),
        ));
  }

  SizedBox ListBetweenSizeBox() => const SizedBox(height: 20);

  FutureBuilder<List<WebtoonModel>> mainNaver() {
    return FutureBuilder(
      future: webtoonsNaver,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return allListButton(
              context, snapshot, servicesNameKr[0], makeNaverList);
        }
        return const Center();
      },
    );
  }

  FutureBuilder<List<WebtoonModelKakao>> webtoonKakao(
      Future<List<WebtoonModelKakao>> webtoon, String txt) {
    return FutureBuilder(
      future: webtoon,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return allListButton(context, snapshot, txt, makeKakaoList);
        }
        return const Center(
            child: CircularProgressIndicator(color: Colors.green));
      },
    );
  }

  Widget allListButton(BuildContext context, snapshot, String txt, homeList) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ListScreen(txt: txt)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  txt,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.arrow_forward_ios_outlined)
              ],
            ),
          ),
        ),
        homeList(snapshot),
      ],
    );
  }

  dynamic makeNaverList(snapshot) {
    return SizedBox(
      height: 330,
      child: ListView.separated(
        itemCount: basicListCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var webtoon = snapshot.data![index];

          return MainThumbWidget(
            title: webtoon.title,
            thumb: webtoon.thumb,
            id: webtoon.id,
            service: servicesNameEng[0],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 5),
      ),
    );
  }

  dynamic makeKakaoList(AsyncSnapshot<List<WebtoonModelKakao>> snapshot) {
    return SizedBox(
      height: 500,
      child: ListView.separated(
        itemCount: basicListCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var webtoon = snapshot.data![index];

          return MainThumbWidget(
            title: webtoon.title,
            thumb: webtoon.img,
            id: webtoon.id,
            service: webtoon.service,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 5),
      ),
    );
  }
}
