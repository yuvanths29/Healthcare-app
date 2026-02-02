class HealthProfile {
  final String? height; // in cm
  final String? weight; // in kg
  final String? allergies;
  final String? medicalConditions;

  HealthProfile({
    this.height,
    this.weight,
    this.allergies,
    this.medicalConditions,
  });

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'allergies': allergies,
        'medicalConditions': medicalConditions,
      };

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
        height: json['height'] as String?,
        weight: json['weight'] as String?,
        allergies: json['allergies'] as String?,
        medicalConditions: json['medicalConditions'] as String?,
      );

  HealthProfile copyWith({
    String? height,
    String? weight,
    String? allergies,
    String? medicalConditions,
  }) =>
      HealthProfile(
        height: height ?? this.height,
        weight: weight ?? this.weight,
        allergies: allergies ?? this.allergies,
        medicalConditions: medicalConditions ?? this.medicalConditions,
      );
}
