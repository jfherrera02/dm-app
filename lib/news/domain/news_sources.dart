/// Model for the /v2/top‑headlines/sources endpoint
class NewsSource {
  final String id;
  final String name;
  final String description;
  final String url;
  final String category;
  final String language;
  final String country;

  NewsSource({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.category,
    required this.language,
    required this.country,
  });

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id:          json['id']          as String,
      name:        json['name']        as String,
      description: json['description'] as String,
      url:         json['url']         as String,
      category:    json['category']    as String,
      language:    json['language']    as String,
      country:     json['country']     as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'name':        name,
    'description': description,
    'url':         url,
    'category':    category,
    'language':    language,
    'country':     country,
  };
}
