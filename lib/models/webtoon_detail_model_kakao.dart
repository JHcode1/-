class WebtoonDetailModelKakao {
  final String title, provider, id, url;
  final List<String> authors;
  WebtoonDetailModelKakao.fromJson(Map<dynamic, dynamic> json)
      : title = json['title'],
        id = json['id'],
        provider = json['provider'],
        url = json['url'],
        authors = List<String>.from(json['authors']);
}
