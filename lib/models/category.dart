class Category {
  final String id;
  final String name;
  final String iconAsset; // icon name or emoji
  final int itemCount;

  const Category({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.itemCount,
  });
}
