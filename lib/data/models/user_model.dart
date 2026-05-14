// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final List<AddressModel> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'addresses': addresses.map((x) => x.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      role: map['role'] ?? 'customer',
      addresses: List<AddressModel>.from(
          map['addresses']?.map((x) => AddressModel.fromMap(x)) ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class AddressModel {
  final String id;
  final String name;
  final String address;
  final String landmark;
  final String pincode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.address,
    required this.landmark,
    required this.pincode,
    required this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'landmark': landmark,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      landmark: map['landmark'] ?? '',
      pincode: map['pincode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}
