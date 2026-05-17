class ServicemanBody {

  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  String? confirmedPassword;
  String? identityType;
  String? identityNumber;
  String? identityImage;
  String? profileImage;


  ServicemanBody({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
    this.confirmedPassword,
    this.identityType,
    this.identityNumber,
    this.identityImage,
    this.profileImage
  });

  // SignUpBody.fromJson(Map<String, dynamic> json) {
  //   fName = json['f_name'];
  //   lName = json['l_name'];
  //   phone = json['phone'];
  //   email = json['email'];
  //   password = json['password'];
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['identity_type'] = identityType;
    data['identity_number'] = identityNumber;
    data['password'] = password;
    data['confirm_password'] = confirmedPassword;
    data['identity_image'] = identityImage;
    data['profile_image'] = profileImage;

    return data;
  }
}
