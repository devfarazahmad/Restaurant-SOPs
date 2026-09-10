class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromMap(
    Map<String, dynamic> map,
  ) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
    );
  }

  bool get isOwner =>
      role == 'owner';

  bool get isChefMaster =>
      role == 'chef_master';

  bool get isStaff =>
      role == 'staff';

  bool get canManageRecipes =>
      isChefMaster;
}