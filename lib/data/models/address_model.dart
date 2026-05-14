// lib/data/models/address_model.dart
class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String type; // home, work, other
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      type: map['type'] ?? 'home',
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'type': type,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? type,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
