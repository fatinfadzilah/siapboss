class LoginModel
{
  final String? userId;
  final String? fullName;
  bool isSetupBio;
  bool isUseBio;
  String? bearerToken;

  LoginModel({
    this.userId,
    this.fullName,
    this.isSetupBio = false,
    this.isUseBio = false,
    this.bearerToken = ""
  });

  LoginModel.fromJson(Map<String, dynamic> json)
  : userId = json['user_id'],
    fullName = json['user_name'],
    isSetupBio = (json['is_setup_bio'] == 1),
    isUseBio = (json['is_use_bio'] == 1),
    bearerToken = json['bearer'];

  Map<String, dynamic> toJson() =>
  {
    'user_id': userId,
    'user_name': fullName,
    'is_setup_bio': (isSetupBio ? 1 : 0),
    'is_use_bio': (isUseBio ? 1 : 0),
    'bearer': bearerToken
  };
}