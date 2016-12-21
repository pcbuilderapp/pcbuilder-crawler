class Shop {
  String name;
  String url;
  String logoUrl;

  Shop(this.name, this.url, this.logoUrl) {}

  Map toJson() => {
    "name": name,
    "url" : url,
    "logoUrl" : logoUrl
  };
}