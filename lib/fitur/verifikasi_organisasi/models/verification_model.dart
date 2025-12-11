class OrganizationVerificationData {
  String? organizationId;
  String? ownerName;
  String? ownerNik;
  String? ownerAddress;
  String? orgLegalName;
  String? orgNpwp;
  String? orgRegistrationNo;
  String? email;
  String? phone;
  String? city;
  String? docAktaPath;
  String? docNpwpPath;
  String? docOtherPath;

  OrganizationVerificationData({
    this.organizationId,
    this.ownerName,
    this.ownerNik,
    this.ownerAddress,
    this.orgLegalName,
    this.orgNpwp,
    this.orgRegistrationNo,
    this.email,
    this.phone,
    this.city,
    this.docAktaPath,
    this.docNpwpPath,
    this.docOtherPath,
  });

  bool get isOwnerDataComplete =>
      ownerName != null &&
      ownerName!.isNotEmpty &&
      ownerNik != null &&
      ownerNik!.isNotEmpty &&
      ownerAddress != null &&
      ownerAddress!.isNotEmpty;

  bool get isOrgDataComplete =>
      organizationId != null &&
      organizationId!.isNotEmpty &&
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
