enum MembershipLevel {
  newMember,
  activeMember,
  trustedMember,
}

extension MembershipExtension on MembershipLevel {

  int get value {
    switch (this) {
      case MembershipLevel.newMember:
        return 0;
      case MembershipLevel.activeMember:
        return 1;
      case MembershipLevel.trustedMember:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case MembershipLevel.newMember:
        return "عضو جديد";
      case MembershipLevel.activeMember:
        return "عضو نشط";
      case MembershipLevel.trustedMember:
        return "عضو موثوق";
    }
  }
}