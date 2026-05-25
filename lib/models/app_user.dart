import 'package:flutter/material.dart';

class AppUser {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bio;
  final String profileImage;
  final List<String> interests;
  final String location;
  final bool verified;
  final String occupation;
  final double profileCompletion;
  final String distance;
  final List<String>? photos;
  final String? education;
  final String? lookingFor;
  final String? zodiacSign;
  final String? bhutaneseZodiac;
  final String? religion;
  final String? ethnicity;
  final String? height;
  final String? drinkingHabit;
  final String? smokingHabit;
  final String? languages;
  final String? hometown;
  final String? nickname;
  final double? latitude;
  final double? longitude;

  AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bio,
    required this.profileImage,
    required this.interests,
    required this.location,
    required this.verified,
    this.occupation = '',
    this.profileCompletion = 0.0,
    this.distance = '',
    this.photos,
    this.education,
    this.lookingFor,
    this.zodiacSign,
    this.bhutaneseZodiac,
    this.religion,
    this.ethnicity,
    this.height,
    this.drinkingHabit,
    this.smokingHabit,
    this.languages,
    this.hometown,
    this.nickname,
    this.latitude,
    this.longitude,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
  bool get isVerified => verified;

  static const List<List<Color>> _gradients = [
    [Color(0xFF1B4F72), Color(0xFF2980B9)],
    [Color(0xFF1E8449), Color(0xFF27AE60)],
    [Color(0xFF6C3483), Color(0xFF9B59B6)],
    [Color(0xFF784212), Color(0xFFE67E22)],
    [Color(0xFF922B21), Color(0xFFE74C3C)],
    [Color(0xFF1A5276), Color(0xFF2471A3)],
    [Color(0xFF4A235A), Color(0xFF8E44AD)],
  ];

  List<Color> get gradient =>
      _gradients[id.hashCode.abs() % _gradients.length];

  factory AppUser.fromFirestore(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? 'Unknown',
      age: (data['age'] ?? 0) as int,
      gender: data['gender'] ?? 'Other',
      bio: data['bio'] ?? '',
      profileImage: data['profileImage'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      location: data['location'] ?? 'Bhutan',
      verified: data['verified'] ?? false,
      occupation: data['occupation'] ?? '',
      profileCompletion: (data['profileCompletion'] ?? 0.0).toDouble(),
      distance: data['distance'] ?? '',
      photos: data['photos'] != null
          ? List<String>.from(data['photos'])
          : null,
      education: data['education'],
      lookingFor: data['lookingFor'],
      zodiacSign: data['zodiacSign'],
      bhutaneseZodiac: data['bhutaneseZodiac'],
      religion: data['religion'],
      ethnicity: data['ethnicity'],
      height: data['height'],
      drinkingHabit: data['drinkingHabit'],
      smokingHabit: data['smokingHabit'],
      languages: data['languages'],
      hometown: data['hometown'],
      nickname: data['nickname'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? bio,
    String? profileImage,
    List<String>? interests,
    String? location,
    bool? verified,
    String? occupation,
    double? profileCompletion,
    String? distance,
    List<String>? photos,
    String? education,
    String? lookingFor,
    String? zodiacSign,
    String? bhutaneseZodiac,
    String? religion,
    String? ethnicity,
    String? height,
    String? drinkingHabit,
    String? smokingHabit,
    String? languages,
    String? hometown,
    String? nickname,
    double? latitude,
    double? longitude,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      verified: verified ?? this.verified,
      occupation: occupation ?? this.occupation,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      distance: distance ?? this.distance,
      photos: photos ?? this.photos,
      education: education ?? this.education,
      lookingFor: lookingFor ?? this.lookingFor,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      bhutaneseZodiac: bhutaneseZodiac ?? this.bhutaneseZodiac,
      religion: religion ?? this.religion,
      ethnicity: ethnicity ?? this.ethnicity,
      height: height ?? this.height,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      languages: languages ?? this.languages,
      hometown: hometown ?? this.hometown,
      nickname: nickname ?? this.nickname,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
