import 'package:flutter/material.dart';

class AppUser {
  final String id;
  final String name;
  final int age;
  final String location;
  final String bio;
  final String initial;
  final List<Color> gradient;
  final bool isVerified;
  final List<String> interests;
  final double profileCompletion;
  final String distance;
  final String occupation;
  final String? photoUrl;
  final List<String>? photos;
  final String? education;
  final String? height;
  final String? zodiacSign;
  final String? bhutaneseZodiac;
  final String? religion;
  final String? ethnicity;
  final String? drinkingHabit;
  final String? smokingHabit;
  final String? lookingFor;
  final String? languages;
  final String? hometown;

  const AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.bio,
    required this.initial,
    required this.gradient,
    this.isVerified = false,
    required this.interests,
    required this.profileCompletion,
    required this.distance,
    required this.occupation,
    this.photoUrl,
    this.photos,
    this.education,
    this.height,
    this.zodiacSign,
    this.bhutaneseZodiac,
    this.religion,
    this.ethnicity,
    this.drinkingHabit,
    this.smokingHabit,
    this.lookingFor,
    this.languages,
    this.hometown,
  });

  AppUser copyWith({
    String? id,
    String? name,
    int? age,
    String? location,
    String? bio,
    String? initial,
    List<Color>? gradient,
    bool? isVerified,
    List<String>? interests,
    double? profileCompletion,
    String? distance,
    String? occupation,
    String? photoUrl,
    List<String>? photos,
    String? education,
    String? height,
    String? zodiacSign,
    String? bhutaneseZodiac,
    String? religion,
    String? ethnicity,
    String? drinkingHabit,
    String? smokingHabit,
    String? lookingFor,
    String? languages,
    String? hometown,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      initial: initial ?? this.initial,
      gradient: gradient ?? this.gradient,
      isVerified: isVerified ?? this.isVerified,
      interests: interests ?? this.interests,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      distance: distance ?? this.distance,
      occupation: occupation ?? this.occupation,
      photoUrl: photoUrl ?? this.photoUrl,
      photos: photos ?? this.photos,
      education: education ?? this.education,
      height: height ?? this.height,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      bhutaneseZodiac: bhutaneseZodiac ?? this.bhutaneseZodiac,
      religion: religion ?? this.religion,
      ethnicity: ethnicity ?? this.ethnicity,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      lookingFor: lookingFor ?? this.lookingFor,
      languages: languages ?? this.languages,
      hometown: hometown ?? this.hometown,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessage copyWith({bool? isRead}) => ChatMessage(
        id: id,
        senderId: senderId,
        text: text,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
      );
}
