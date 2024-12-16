import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toonflix/models/webtoon_detail_model.dart';
import 'package:toonflix/models/webtoon_episode_model.dart';
import 'package:toonflix/models/webtoon_model_naver.dart';
import 'package:toonflix/models/webtoon_detail_model_kakao.dart';
import 'package:toonflix/models/webtoon_model_kakao.dart';
import 'package:intl/intl.dart';

//import 'package:html/parser.dart' as html;

class ApiService {
  static const String baseUrl =
      "https://webtoon-crawler.nomadcoders.workers.dev";
  static String baseKakaoUrl =
      "https://korea-webtoon-api-cc7dda2f0d77.herokuapp.com/webtoons";
  static const String today = "today";

  // 네이버
  static Future<List<WebtoonModel>> getTodaysToons() async {
    List<WebtoonModel> webtoonInstances = [];
    final url = Uri.parse('$baseUrl/$today');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final webtoons = jsonDecode(response.body);
      for (var webtoon in webtoons) {
        final instance = WebtoonModel.fromJson(webtoon);
        webtoonInstances.add(instance);
      }
      return webtoonInstances;
    }
    throw Error();
  }

  // 카카오
  static Future<List<WebtoonModelKakao>> getTodaysKakaoToons(
      String provider) async {
    provider = provider.toUpperCase();
    late var now = DateTime.now();
    String updateDay = '';
    updateToday() {
      updateDay = DateFormat('EEEE').format(now).substring(0, 3).toUpperCase();
    }

    updateToday();

    List<WebtoonModelKakao> webtoonIstances = [];

    final url =
        Uri.parse('$baseKakaoUrl?provider=$provider&updateDay=$updateDay');
    final response = await http.get(url);

    print(url);
    if (response.statusCode == 200) {
      final List<dynamic> webtoons = jsonDecode(response.body)["webtoons"];

      for (var webtoon in webtoons) {
        // if (webtoon["thumbnail"].startsWith('//')) {
        //   webtoon["thumbnail"] =
        //       webtoon["thumbnail"].replaceRange(0, 2, 'https://');
        // }
        webtoonIstances.add(WebtoonModelKakao.fromJson(webtoon));
      }

      return webtoonIstances;
    }
    throw Error();
  }

  static Future<WebtoonDetailModel> getToonById(String id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final webtoon = jsonDecode(response.body);
      return WebtoonDetailModel.fromJson(webtoon);
    }
    throw Error();
  }

  static Future<WebtoonDetailModelKakao> getKakaoToonById(String title) async {
    Uri url = Uri.parse('$baseKakaoUrl/?keyword=$title');

    // print(url);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final webtoon = jsonDecode(response.body);

      // print(webtoon['webtoons'][0]);
      if (webtoon['webtoons'] != null &&
          webtoon['webtoons'] is List &&
          webtoon['webtoons'].isNotEmpty) {
        return WebtoonDetailModelKakao.fromJson(webtoon['webtoons'][0]);
      }
    }
    throw Error();
  }

  static Future<List<WebtoonEpisodeModel>> getLatestEpisodesById(
      String id) async {
    List<WebtoonEpisodeModel> episodesInstances = [];
    final url = Uri.parse("$baseUrl/$id/episodes");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final episodes = jsonDecode(response.body);
      for (var episode in episodes) {
        episodesInstances.add(WebtoonEpisodeModel.fromJson(episode));
      }
      return episodesInstances;
    }
    throw Error();
  }
}
