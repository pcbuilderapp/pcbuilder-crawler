import 'package:html/dom.dart';
import "package:pcbuilder.crawler/model/metrics.dart";

///classes implementing the PageWorker abstract class should implement a parse function
abstract class PageWorker {
  parse(Document document, arguments);
}
