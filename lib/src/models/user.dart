class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? passwordConfirmation;
  final String? telephone;
  final String statut;
  final String? photo;
  final int? roleId;
  final String? solde;
  final String? soldeMax;
  final String? surname;
  final String? adresse;
  final String? cumulTransaction;
  final Role? role; // Role rendu optionnel

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.passwordConfirmation,
    this.telephone,
    required this.statut,
    this.photo,
    this.roleId,
    this.solde,
    this.soldeMax,
    this.surname,
    this.adresse,
    this.cumulTransaction,
    this.role, // Role optionnel
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      passwordConfirmation: json['password_confirmation'],
      telephone: json['telephone'],
      statut: json['statut'] ?? '',
      photo: json['photo'],
      roleId: json['role_id'],
      solde: json['solde']?.toString(),
      soldeMax: json['soldeMax']?.toString(),
      surname: json['surname'],
      adresse: json['adresse'],
      cumulTransaction: json['cumulTransaction']?.toString(),
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
    );
  }
}

class Role {
  final String nomRole;

  Role({required this.nomRole});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      nomRole: json['nomRole'] ?? '', // Assure que nomRole n'est jamais null
    );
  }
}
