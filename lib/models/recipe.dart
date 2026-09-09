class Recipe {
  final int id;
  final String name;
  final String category;
  final String description;
  final String image;
  final int preparationTime;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.image,
    required this.preparationTime,
    this.isFavorite = false,
  });
}