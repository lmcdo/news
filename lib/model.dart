class ItemModel {
  List<Article> Articles;
  

  ItemModel({
    this.Articles,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    var accJson = json['articles'] as List;
    List<Article> accList = accJson.map((i) => Article.fromJson(i)).toList();

    // TO SORT ARRAY WITH publishedAt
    accList.sort((a, b) {
      return a.publishedAt.compareTo(b.publishedAt);
    });

    return ItemModel(Articles: accList);
  }

  Map<String, dynamic> toJson() => {
        "articles": new List<dynamic>.from(Articles.map((x) => x.toJson())),
      };
}

class Article {
  
  Source source;
  String author;
  String description;
  String publishedAt;
  String title;
  String url;
  String urlToImage;
  String content;

  Article({
    this.source,
    this.author,
    this.description,
    this.publishedAt,
    this.title,
    this.url,
    this.urlToImage,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    

    return Article(
      source:Source.fromJson(json['source']),
      author: json["author"],
      description: json['description'],
      publishedAt: json["publishedAt"],
      title: json['title'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      content: json['content'],
      //iconPath: iconPathValues.map[json["iconPath"]],
    );
  }

  Map<String, dynamic> toJson() => {
        
        "name": author,
        "description": description,
        "publishedAt": publishedAt,
        "title": title,
        "url": url,
        "urltoImage": urlToImage
      };
}

class Source {
  String id;
  String name;

  Source({
    this.id,
    this.name,
  });

  factory Source.fromJson(Map< String, dynamic> source) {
    return Source(
        id: source['id'] as String,
        name: source['name'] as String);
  }


}



/* class ItemModel {
  List<Category> articles;

  ItemModel({
    this.articles,
  });


  factory ItemModel.fromJson(Map<String, dynamic> json){

    var accJson = json['articles'] as List;
    List<Article> accList = accJson.map((i) => Article.fromJson(i)).toList();


    // TO SORT ARRAY WITH publishedAt
    accList.sort((a, b) {
      return a.publishedAt.compareTo(b.publishedAt);
    });

    return ItemModel(
        articles: accList
    );
  }

  Map<String, dynamic> toJson() => {
    "articles": new List<dynamic>.from(articles.map((x) => x.toJson())),
  };
}

class Article {
  int id;
  String author;
  String description;
  String publishedAt;
  String title;
  String url;
  String urlToImage;
  String content;


  Article({
    this.id,
    this.author,
    this.description,
    this.publishedAt,
    this.title,
    this.url,
    this.urlToImage,
    this.content,
    
  });

  factory Article.fromJson(Map<String, dynamic> json) => new Article(
    
    author: json["author"],
    
    description: json['description'],
    publishedAt: json["publishedAt"],
    title:json['title'],
    url:json['url'],
    urlToImage:json['urlToImage'],
    content: json['content'],
    //iconPath: iconPathValues.map[json["iconPath"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": author,
    "description": description,
    "publishedAt": publishedAt,
    "title": title,
    "url": url,
    "urltoImage": urlToImage
    
  };
} */


