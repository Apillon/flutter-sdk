// ignore_for_file: constant_identifier_names
class IApillonList<I> {
  List<I> items;
  int total;

  IApillonList({
    required this.items,
    required this.total,
  });

  factory IApillonList.fromJson(Map<String, dynamic> json) {
    return IApillonList(
      items: json['items'],
      total: json['total'] as int,
    );
  }
}

class IApillonPagination {
  String? search;
  int? page;
  int? limit;
  String? orderBy;
  bool? desc;

  IApillonPagination({
    this.search,
    this.page,
    this.limit,
    this.orderBy,
    this.desc,
  });

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'page': page,
      'limit': limit,
      'orderBy': orderBy,
      'desc': desc
    };
  }
}

enum LogLevel {
  NONE,
  ERROR,
  VERBOSE,
}
