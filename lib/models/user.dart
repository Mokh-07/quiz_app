/// Modèle pour représenter un utilisateur
class User {
  final String id;
  final String name;
  final String? email;
  final bool isGuest;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.name,
    this.email,
    this.isGuest = false,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Crée un User à partir d'un Map JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      lastLoginAt: json['lastLoginAt'] != null 
        ? DateTime.parse(json['lastLoginAt'] as String)
        : null,
    );
  }

  /// Convertit le User en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isGuest': isGuest,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Crée une copie du User avec des modifications
  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isGuest,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Retourne le nom d'affichage de l'utilisateur
  String get displayName {
    if (isGuest) {
      return 'Invité';
    }
    return name.isNotEmpty ? name : email ?? 'Utilisateur';
  }

  /// Retourne les initiales de l'utilisateur pour l'avatar
  String get initials {
    if (isGuest) {
      return 'I';
    }
    
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        return parts[0][0].toUpperCase();
      }
    }
    
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    
    return 'U';
  }

  /// Vérifie si l'utilisateur a un email valide
  bool get hasValidEmail {
    return email != null && 
           email!.isNotEmpty && 
           RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!);
  }

  /// Vérifie si l'utilisateur est un utilisateur complet (pas invité)
  bool get isFullUser => !isGuest && hasValidEmail;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, isGuest: $isGuest}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
