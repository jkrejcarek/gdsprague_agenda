class Speaker {
  final String name;
  final String bio;

  Speaker({
    required this.name,
    required this.bio,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
    };
  }
}

