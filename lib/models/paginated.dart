class Paginated<T> {
  final List<T> items;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  Paginated({
    required this.items,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final data = json['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return Paginated(
      items: rawItems
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList(),
      total: int.tryParse('${pagination['total']}') ?? 0,
      perPage: int.tryParse('${pagination['per_page']}') ?? 0,
      currentPage: int.tryParse('${pagination['current_page']}') ?? 1,
      lastPage: int.tryParse('${pagination['last_page']}') ?? 1,
    );
  }
}