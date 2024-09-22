class CreateUserReq {
  final String fullName;
  final String email;
  final String password;
  final String profilePicture;

  CreateUserReq({
    required this.fullName,
    required this.email,
    required this.password,
    required this.profilePicture,
  });
}