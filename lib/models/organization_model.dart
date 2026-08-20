class Organization {
  final int id;
  final String name;
  final String description;
  final String? image;
  final bool isFollowed;
  final bool isMember;
  final String? volunteerStatus; // none, pending, approved, rejected
  final int? membersCount;
  final int? followersCount;
  final int? projectsCount;
  final int? ownerId;
  final String? ownerName;
  final String? ownerEmail;
  final String? type;
  final String? status;

  Organization({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.isFollowed = false,
    this.isMember = false,
    this.volunteerStatus,
    this.membersCount,
    this.followersCount,
    this.projectsCount,
    this.ownerId,
    this.ownerName,
    this.ownerEmail,
    this.type,
    this.status,
  });

  Organization copyWith({bool? isFollowed}) {
    return Organization(
      id: id,
      name: name,
      description: description,
      image: image,
      isFollowed: isFollowed ?? this.isFollowed,
      isMember: isMember,
      volunteerStatus: volunteerStatus,
      membersCount: membersCount,
      followersCount: followersCount,
      projectsCount: projectsCount,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      type: type,
      status: status,
    );
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'غير معروف',
      description: json['description'] ?? '',
      image: json['image'] ?? json['logo'] ?? null,
      isFollowed: json['is_followed'] ?? false,
      isMember: json['is_member'] ?? false,
      volunteerStatus: json['volunteer_status'] ?? 'none',
      membersCount: json['members_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      projectsCount: json['projects_count'] ?? 0,
      ownerId: json['owner_id'] ?? json['user_id'] ?? null,
      ownerName: json['owner_name'] ?? json['user_name'] ?? null,
      ownerEmail: json['owner_email'] ?? json['user_email'] ?? null,
      type: json['type'] ?? null,
      status: json['status'] ?? null,
    );
  }

  // دالة مساعدة لتحويل الكائن إلى Map إذا احتجت
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'is_followed': isFollowed,
      'is_member': isMember,
      'volunteer_status': volunteerStatus,
      'members_count': membersCount,
      'projects_count': projectsCount,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_email': ownerEmail,
      'followers_count': followersCount,
    };
  }
}
