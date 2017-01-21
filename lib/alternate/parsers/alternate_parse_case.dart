import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/interface/pageworker.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

class AlternateCaseParser implements PageWorker {

  Metrics metrics;
  AlternateCaseParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {

    metrics.caseParserTime.start();

    var rows = document.querySelectorAll("div.listRow");

    for (Element listRow in rows) {

      Product pcCase = new Product();
      pcCase.name = listRow.querySelector("span.name").text.trim();
      pcCase.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      pcCase.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      pcCase.type = "CASE";
      pcCase.price = price(listRow.querySelector("span.price").text);
      pcCase.shop = "Alternate";

      await Crawler.crawl(pcCase.url, new AlternateCaseDetailParser(metrics), arguments: pcCase);
    }
  }
}

class AlternateCaseDetailParser implements PageWorker {

  Metrics metrics;
  AlternateCaseDetailParser(Metrics metrics) {
    this.metrics = metrics;
  }

  parse(Document document, arguments) async {

    Product pcCase = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    pcCase.ean = dataFlix.attributes["data-flix-ean"];
    pcCase.mpn = dataFlix.attributes["data-flix-mpn"];
    var picUrl = document.querySelector("span.picture").querySelector("img[src]");
    pcCase.pictureUrl = "https://www.alternate.nl" + picUrl.attributes["src"];

    String caseForm = "";
    var techDataTableElements = document.querySelectorAll("div.productShort ul li");

    for (int i = 0; i < techDataTableElements.length; i++) {

      List<String> productShort = techDataTableElements[i].text.split(":");

      String techDataLabel = productShort[0];
      String techData = productShort[1];

      if (techDataLabel == "Formfactor") {

        List<String> caseFormList = techData.split(",");

        for (int i = 0; i < caseFormList.length; i++){
          if(caseFormList[i] != null){
            pcCase.connectors.add(new Connector(caseFormList[i].trim(), "CASE"));
          }
        }

        break;
      }
    }

    metrics.caseParserTime.stop();

    metrics.caseBackendTime.start();
    await postProduct(pcCase);
    metrics.caseBackendTime.stop();
  }
}