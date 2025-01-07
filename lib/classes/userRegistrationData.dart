class UserRegistrationData {
  String? gender;
  int? age;
  double? weight;
  int? height;

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
    };
  }
}
