class PromptCategory {
  final String id;
  final String name;
  final int index;

  PromptCategory({required this.id, required this.name, required this.index});

  factory PromptCategory.fromJson(Map<String, dynamic> json) {
    return PromptCategory(
      id: json['id'].toString(),
      name: json['name'],
      index: json['index'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'PromptCategory(id: $id, name: $name, index: $index)';
  }
}