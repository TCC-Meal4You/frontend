class UserRestrictionRequestDTO {
  final List<int> idsRestricoes;

  UserRestrictionRequestDTO({required this.idsRestricoes});

  Map<String, dynamic> toJson() {
    return {'idsRestricoes': idsRestricoes};
  }
}
