
class Recipe {
  final int id;

  final String name;
  final String category;
  final String description;
  final String image;

  final int preparationTime;

  final String ingredients;
  final String preparationSteps;
  final String cookingInstructions;

  final String storageInstructions;
  final String freezingInstructions;
  final String thawingInstructions;

  bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.image,
    required this.preparationTime,
    required this.ingredients,
    required this.preparationSteps,
    required this.cookingInstructions,
    required this.storageInstructions,
    required this.freezingInstructions,
    required this.thawingInstructions,
    this.isFavorite = false,
  });

  // ============================================================
  // FROM DATABASE
  // ============================================================

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int? ?? 0,

      name: map['name'] as String? ?? '',

      category: map['category'] as String? ?? '',

      description: map['description'] as String? ?? '',

      image: map['image'] as String? ?? '',

      preparationTime:
          map['preparation_time'] as int? ?? 0,

      ingredients:
          map['ingredients'] as String? ?? '',

      preparationSteps:
          map['preparation_steps'] as String? ?? '',

      cookingInstructions:
          map['cooking_instructions'] as String? ?? '',

      storageInstructions:
          map['storage_instructions'] as String? ?? '',

      freezingInstructions:
          map['freezing_instructions'] as String? ?? '',

      thawingInstructions:
          map['thawing_instructions'] as String? ?? '',

      isFavorite: false,
    );
  }

  // ============================================================
  // TO DATABASE MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'image': image,
      'preparation_time': preparationTime,
      'ingredients': ingredients,
      'preparation_steps': preparationSteps,
      'cooking_instructions': cookingInstructions,
      'storage_instructions': storageInstructions,
      'freezing_instructions': freezingInstructions,
      'thawing_instructions': thawingInstructions,
    };
  }
}