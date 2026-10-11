/// Visual food category / cuisine roundel for home discovery.
class CuisineCategory {
  const CuisineCategory({
    required this.id,
    required this.name,
    required this.iconEmoji,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String iconEmoji;
  final String? imageUrl;
}
