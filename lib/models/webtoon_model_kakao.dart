class WebtoonModelKakao {
  final String title, provider, id, url;
  final List<String> thumbnail;

  WebtoonModelKakao.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        thumbnail = List<String>.from(json['thumbnail']),
        id = json['id'],
        url = json['url'],
        provider = json['provider'];
}
