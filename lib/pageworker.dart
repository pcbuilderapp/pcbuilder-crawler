import 'package:html/dom.dart';

///PageWorker abstract class should implement a parse function///
abstract class PageWorker {
  parse(Document document, arguments);
}