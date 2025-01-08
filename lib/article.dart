import 'package:webfeed/domain/rss_enclosure.dart';
import 'package:webfeed/domain/rss_item.dart';

class Article {
  String? _title;
  String? _description;
  DateTime? _pubDate;
  String? _enclosure;
  String? _link;
  Article({required RssItem item}) {
    _title = item.title;
    _description = item.description;
    _pubDate = item.pubDate;
    _enclosure = item.enclosure?.url;
    _link = item.link;
  }
  String? get title => _title;

  String? get description => _description;

  DateTime? get pubDate => _pubDate;

  String? get enclosure => _enclosure;

  String? get link => _link;
  
}
