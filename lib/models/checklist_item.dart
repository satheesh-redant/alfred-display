class ChecklistItem {
  final String title;
  final String image;
  final bool isBlueBorder;
  final bool completed;

  const ChecklistItem({
    required this.title,
    required this.image,
    this.isBlueBorder = false,
    this.completed = false,
  });

  ChecklistItem copyWith({
    String? title,
    String? image,
    bool? isBlueBorder,
    bool? completed,
  }) {
    return ChecklistItem(
      title: title ?? this.title,
      image: image ?? this.image,
      isBlueBorder: isBlueBorder ?? this.isBlueBorder,
      completed: completed ?? this.completed,
    );
  }
}