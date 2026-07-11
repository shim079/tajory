class Pet {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const Pet({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'description': description,
  };

  factory Pet.fromMap(Map<String, dynamic> map) => Pet(
    id: map['id'] as String,
    name: map['name'] as String,
    emoji: map['emoji'] as String? ?? '',
    description: map['description'] as String? ?? '',
  );
}
