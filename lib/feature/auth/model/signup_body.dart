class SignUpBody {
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? password;
  String? confirmPassword;
  String? referCode;
  String? userType;
  //
  // brand-only fields
  String? brandName;
  String? industry;
  String? cacNumber;
  String? brandDescription;
  String? cacDocumentUrl;

  SignUpBody({
    this.fName,
    this.lName,
    this.phone,
    this.email = '',
    this.password,
    this.confirmPassword,
    this.referCode,
    this.userType,
    this.brandName,
    this.industry,
    this.cacNumber,
    this.brandDescription,
    this.cacDocumentUrl,
  });

  SignUpBody.fromJson(Map<String, dynamic> json) {
    fName = json['first_name'];
    lName = json['last_name'];
    phone = json['phone'];
    email = json['email'];
    password = json['password'];
    confirmPassword = json['confirm_password'];
    referCode = json['referral_code'];
    userType = json['user_type'];
    brandName = json['brand_name'];
    industry = json['industry'];
    cacNumber = json['cac_number'];
    brandDescription = json['brand_description'];
    cacDocumentUrl = json['cac_document_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = fName;
    data['last_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['password'] = password;
    data['confirm_password'] = confirmPassword;

    if (referCode != null) data['referral_code'] = referCode;
    if (userType != null) data['user_type'] = userType;

    if (userType == 'brand') {
      data['brand_name'] = brandName;
      data['industry'] = industry;
      data['cac_number'] = cacNumber;
      data['brand_description'] = brandDescription;
      data['cac_document_url'] = cacDocumentUrl;
    }

    return data;
  }
}
