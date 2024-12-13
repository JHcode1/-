class WebtoonModelKakao {
  final String title, img, service, id;

  WebtoonModelKakao.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        img = json['img'],
        id = json['_id'],
        service = json['service'];
}
