import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class AlternatePowerSupplyUnitParser implements PageWorker {

  parse(Document document, arguments) async {

    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {

      Product psu = new Product();
      psu.name = listRow.querySelector("span.name").text.trim();
      psu.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      psu.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      psu.type = "PSU";
      psu.price = price(listRow.querySelector("span.price").text);
      psu.shop = "Alternate";

      await Crawler.crawl(psu.url, new AlternatePsuDetailParser(), arguments: psu);
    }
  }
}

class AlternatePsuDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product psu = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    psu.ean = dataFlix.attributes["data-flix-ean"];
    psu.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl = document.querySelector("span.picture").querySelector("img[src]");
    psu.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    String psuForm = null;
    var techDataTableElements = document.querySelectorAll("div.techData table tr");
    bool saveNext = false;
    bool breakMethod = false;

    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataLabel = "";
      if(techDataTableElements[i].querySelector("html td") != null){
        techDataLabel = techDataTableElements[i].querySelector("html td").text.trim();
      }

      if (saveNext) {
        if(techDataTableElements[i].querySelector("html td") != null){
          psuForm = techDataTableElements[i].querySelector("html td").text.trim();
          breakMethod = true;
        }
      }

      if (techDataLabel == "Bouwvorm") {
        saveNext = true;
      }

      if (breakMethod) {
        break;
      }
    }

    if(psuForm != null){
      psu.connectors.add(new Connector(psuForm, "PSU"));
    }

    await postProduct(psu);
  }
}
