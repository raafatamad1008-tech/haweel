class ApplicantModel {

  final String id;
  final String contractId;
  final String userId;
  final bool selected;

  ApplicantModel({
    required this.id,
    required this.contractId,
    required this.userId, 
    required this.selected,
  });

  factory ApplicantModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicantModel(
      id: id,
      contractId: map["contractId"],
      userId: map["userId"], 
      selected: map['selected'] ?? false,
    );
  }
}