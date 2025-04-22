// This file defines the NewsArticle class and the Source class.
// The NewsArticle class represents a news article with various attributes such as source, author, title, description, url, urlToImage, publishedAt, and content. The Source class represents the source of the news article with id and name attributes. Both classes have methods to convert between JSON and Dart objects.
// The NewsArticle class also has a toJson method to convert the object to a JSON format and a fromJson method to create an object from JSON data.

class NewsArticle {
  Source? source;
  String? author;
  String? title;
  String? description;
  String? url;
  String? urlToImage;
  DateTime? publishedAt;
  String? content;
  // String? id; // Add this line to include the id field

  NewsArticle({
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    // this.id, // Add this line to include the id field
  });

  // Convert news article object
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (source != null) {
      data['source'] = source!.toJson();
    }
    data['author'] = author;
    data['title'] = title;
    data['description'] = description;
    data['url'] = url;
    data['urlToImage'] = urlToImage;
    data['publishedAt'] = publishedAt;
    data['content'] = content;
    // data['id'] = id; // Add this line to include the id field
    return data;
  }

  // REVERSE: from firebase, return json file ----> news article object to use
  NewsArticle.fromJson(Map<String, dynamic> json) {
    source = json['source'] != null ? Source.fromJson(json['source']) : null;
    author = json['author'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    urlToImage = json['urlToImage'];
    publishedAt = DateTime.parse(json['publishedAt'] as String);
    content = json['content'];
    // id = json['id']; // Add this line to include the id field
  }
}

class Source {
  String? id;
  String? name;

  Source({this.id, this.name});

  // define the fromJson Method to convert the json file to a source object
  Source.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // define the toJson Method to convert the source object to a json file
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
  /*
  // define the toString Method to convert the source object to a string
  @override
  String toString() {
    return 'Source{id: $id, name: $name}';
  }
  // define the copyWith Method to create a new source object with the same values as the old one
  Source copyWith({String? id, String? name}) {
    return Source(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
*/
}
