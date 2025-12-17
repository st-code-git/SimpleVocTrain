class AppLanguage {
  final String label;

  AppLanguage({required this.label});

  factory AppLanguage.fromMap(Map<String, dynamic> data) {
    return AppLanguage(label: data['label'] ?? 'Deutsch');
  }

  Map<String, dynamic> toMap() {
    return {'label': label};
  }

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppLanguage && other.label == label;
  }

  @override
  int get hashCode => label.hashCode;
}

class AppLanguagesData {
  String language1;
  String language2;
  String language3;

  AppLanguagesData({
    required this.language1,
    required this.language2,
    required this.language3,
  });
}