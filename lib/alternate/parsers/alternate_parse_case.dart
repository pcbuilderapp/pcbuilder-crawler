import "package:pcbuilder.crawler/utils.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';

class AlternateCaseParser implements PageWorker {
  Metrics metrics;
  AlternateCaseParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {
      metrics.caseParserTime.start();

      Product computerCase = new Product();
      computerCase.name = listRow.querySelector("span.name").text.trim();
      computerCase.brand =
          listRow.querySelectorAll("span.name span")[0].text.trim();
      computerCase.url = config["alternateUrl"] +
          listRow.querySelector(".productLink").attributes["href"];
      computerCase.type = config["computerCaseType"];
      computerCase.price = price(listRow.querySelector("span.price").text);
      setProductDiscountAlternate(listRow, computerCase);

      computerCase.shop = config["alternateName"];

      await UrlCrawler.crawlUrl(
          computerCase.url, new AlternateCaseDetailParser(metrics),
          arguments: computerCase);
    }
  }
}

class AlternateCaseDetailParser implements PageWorker {
  Metrics metrics;
  AlternateCaseDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {
    Product computerCase = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    computerCase.ean = dataFlix.attributes["data-flix-ean"];
    computerCase.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl =
        document.querySelector("span.picture").querySelector("img[src]");
    computerCase.pictureUrl =
        config["alternateUrl"] + picUrl.attributes["src"];

    var techDataTableElements =
        document.querySelectorAll("div.productShort ul li");

    for (int i = 0; i < techDataTableElements.length; i++) {
      List<String> productShort = techDataTableElements[i].text.split(":");

      String techDataLabel = productShort[0];
      String techData = productShort[1];

      if (techDataLabel == "Formfactor") {
        List<String> caseFormList = techData.split(",");

        for (int i = 0; i < caseFormList.length; i++) {
          if (caseFormList[i] != null) {
            extendCaseType(caseFormList[i].trim(), computerCase);
          }
        }

        break;
      }
    }

    metrics.caseParserTime.stop();

    metrics.caseBackendTime.start();
    await postProduct(computerCase);
    metrics.caseBackendTime.stop();
    metrics.caseCount++;
  }
}
