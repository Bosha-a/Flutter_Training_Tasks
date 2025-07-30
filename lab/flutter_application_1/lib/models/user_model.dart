import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String passwordHash;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? securityQuestion;
  final String? securityAnswer;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.passwordHash,
    this.phoneNumber,
    this.dateOfBirth,
    this.profileImage,
    required this.createdAt,
    this.lastLoginAt,
    this.securityQuestion,
    this.securityAnswer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'passwordHash': passwordHash,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'profileImage': profileImage,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer != null ? _hashSecurityAnswer(securityAnswer!) : null,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        passwordHash: json['passwordHash'],
        phoneNumber: json['phoneNumber'],
        dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
        profileImage: json['profileImage'],
        createdAt: DateTime.parse(json['createdAt']),
        lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
        securityQuestion: json['securityQuestion'],
        securityAnswer: json['securityAnswer'],
      );

  // Hash security answer for storage
  String _hashSecurityAnswer(String answer) {
    return sha256.convert(utf8.encode(answer)).toString();
  }
}