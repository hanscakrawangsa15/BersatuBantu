class OrganizationVerificationData {
  String? verificationId;
  String? organizationId;
  String? ownerName;
  String? ownerNik;
  String? ownerAddress;
  String? ownerEmail;  // ← NEW: for email_pemilik
  String? ownerPhone;  // ← NEW: for no_telpon_pemilik
  String? orgLegalName;
  String? orgNpwp;
  String? orgRegistrationNo;
  String? email;
  String? phone;
  String? city;
  String? docAktaPath;
  String? docNpwpPath;
  String? docOtherPath;
  String? orgPassword;

  OrganizationVerificationData({
    this.verificationId,
    this.organizationId,
    this.ownerName,
    this.ownerNik,
    this.ownerAddress,
    this.ownerEmail,  // ← NEW
    this.ownerPhone,  // ← NEW
    this.orgLegalName,
    this.orgNpwp,
    this.orgRegistrationNo,
    this.email,
    this.phone,
    this.city,
    this.docAktaPath,
    this.docNpwpPath,
    this.docOtherPath,
    this.orgPassword,
  });

  bool get isOwnerDataComplete =>
      ownerName != null &&
      ownerName!.isNotEmpty &&
      ownerNik != null &&
      ownerNik!.isNotEmpty &&
      ownerAddress != null &&
      ownerAddress!.isNotEmpty;

  bool get isOrgDataComplete =>
      orgLegalName != null &&
      orgLegalName!.isNotEmpty &&
      orgNpwp != null &&
      orgNpwp!.isNotEmpty &&
      orgRegistrationNo != null &&
      orgRegistrationNo!.isNotEmpty;

  bool get isDocumentsComplete =>
      docAktaPath != null &&
      docAktaPath!.isNotEmpty &&
      docNpwpPath != null &&
      docNpwpPath!.isNotEmpty;
}
