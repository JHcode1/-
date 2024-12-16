import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_detail_model.dart';
import 'package:toonflix/models/webtoon_detail_model_kakao.dart';
import 'package:toonflix/models/webtoon_episode_model.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/episode_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toonflix/models/webtoon_model_naver.dart';
import 'package:toonflix/models/webtoon_model_kakao.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumbnail, webtoonId, provider;
  const DetailScreen(
      {super.key,
      required this.title,
      required this.thumbnail,
      required this.webtoonId,
      required this.provider});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late Future<WebtoonDetailModelKakao> webtoonKakao;
  late SharedPreferences prefs;

  bool isLiked = false;

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('LikedToons');

    if (likedToons != null) {
      if (likedToons.contains(widget.webtoonId) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await prefs.setStringList('LikedToons', []);
    }
  }

  onHeartTap() async {
    final likedToons = prefs.getStringList('LikedToons');
    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.webtoonId);
      } else {
        likedToons.add(widget.webtoonId);
      }

      await prefs.setStringList('LikedToons', likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  final List<String> servicesNameKr = ['네이버 웹툰', '카카오페이지 웹툰', '카카오 웹툰'];
  final List<String> servicesNameEng = ['naver', 'kakao_Page', 'kakao'];

  final Future<List<WebtoonModel>> webtoonsNaver = ApiService.getTodaysToons();
  late Future<List<WebtoonModelKakao>> webtoonsKakaoPage;
  late Future<List<WebtoonModelKakao>> webtoonsKakao;

  @override
  void initState() {
    super.initState();

    webtoonsKakaoPage = ApiService.getTodaysKakaoToons(servicesNameEng[1]);
    webtoonsKakao = ApiService.getTodaysKakaoToons(servicesNameEng[2]);

    webtoon = ApiService.getToonById(widget.webtoonId);
    episodes = ApiService.getLatestEpisodesById(widget.webtoonId);
    webtoonKakao = ApiService.getKakaoToonById(widget.title);

    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: isLiked
                ? const Icon(Icons.favorite_outlined)
                : const Icon(Icons.favorite_border_outlined),
            onPressed: () => onHeartTap(),
          )
        ],
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.webtoonId,
              child: Container(
                height: 500,
                width: MediaQuery.of(context).size.width,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xfffcf0f0)),
                child: Image.network(
                  widget.thumbnail,
                  alignment: Alignment.topCenter,
                  fit: BoxFit.cover,
                  headers: const {
                    "User-Agent":
                        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (widget.provider == servicesNameEng[0]) naverDetail(),
            if (widget.provider == servicesNameEng[2] ||
                widget.provider == servicesNameEng[1])
              kakaoDetail(),
          ],
        ),
      ),
    );
  }

  Column naverDetail() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FutureBuilder(
              future: webtoon,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '작품소개',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        snapshot.data!.about,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${snapshot.data!.genre} / ${snapshot.data!.age}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                } else {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));
                }
              }),
        ),
        FutureBuilder(
            future: episodes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    for (var episode in snapshot.data!.length > 10
                        ? snapshot.data!.sublist(0, 10)
                        : snapshot.data!)
                      Episode(
                        episode: episode,
                        webtoonId: widget.webtoonId,
                      ),
                  ],
                );
              }
              return Container();
            })
      ],
    );
  }

  Padding kakaoDetail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder(
          future: webtoonKakao,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '작가',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.data!.authors.join(', '),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Expanded(child: SizedBox(height: 10)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          final url = Uri.parse(snapshot.data!.url);
                          launchUrl(url);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          "바로보기",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.green));
            }
          }),
    );
  }
}
