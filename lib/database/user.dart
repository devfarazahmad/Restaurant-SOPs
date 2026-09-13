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
      name:
          map['name'] as String? ?? '',
      email:
          map['email'] as String? ?? '',
      role:
          map['role'] as String? ?? 'staff',
    );
  }

  bool get isOwner {
    return role == 'owner';
  }

  bool get isChefMaster {
    return role == 'chef_master';
  }

  bool get isStaff {
    return role == 'staff';
  }

  bool get canManageRecipes {
    return isChefMaster;
  }
}