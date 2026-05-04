import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';

const String kCurrentUserId = 'me';

// Named gradient palette for all discover users
const List<List<Color>> kUserGradients = [
  [Color(0xFF1B4F72), Color(0xFF2980B9)], // Pema  – ocean blue
  [Color(0xFF1E8449), Color(0xFF27AE60)], // Sonam – forest green
  [Color(0xFF6C3483), Color(0xFF9B59B6)], // Karma – amethyst
  [Color(0xFF784212), Color(0xFFE67E22)], // Dechen – amber
  [Color(0xFF922B21), Color(0xFFE74C3C)], // Ugyen – ruby
  [Color(0xFF1A5276), Color(0xFF2471A3)], // Dorji  – navy
  [Color(0xFF4A235A), Color(0xFF8E44AD)], // Yangchen – violet
];

final AppUser kCurrentUser = AppUser(
  id: kCurrentUserId,
  name: 'Kinza',
  age: 24,
  location: 'Thimphu',
  bio: 'Lover of archery, hiking in the Himalayas, and butter tea. Looking for someone to explore Bhutan with. 🏔️',
  initial: 'K',
  gradient: [AppColors.saffronDeep, AppColors.saffron],
  isVerified: true,
  interests: ['Hiking', 'Archery', 'Photography', 'Buddhist Art'],
  profileCompletion: 0.52,
  distance: '0 km',
  occupation: 'Software Developer',
  religion: 'Buddhist',
  languages: 'Dzongkha, English',
  hometown: 'Thimphu',
);

final List<AppUser> kDiscoverUsers = [
  AppUser(
    id: 'u1',
    name: 'Pema',
    age: 22,
    location: 'Paro',
    bio: 'Tiger\'s Nest hiker 🏔️ | Thangka painting student | Looking for adventures across Bhutan.',
    initial: 'P',
    gradient: kUserGradients[0],
    isVerified: true,
    interests: ['Thangka Art', 'Hiking', 'Dzong Visits', 'Meditation'],
    profileCompletion: 0.85,
    distance: '65 km',
    occupation: 'Art Student',
  ),
  AppUser(
    id: 'u2',
    name: 'Sonam',
    age: 26,
    location: 'Punakha',
    bio: 'Punakha Dzong guide 🏯 | Rafting enthusiast | Farmer\'s market regular. Loves butter tea & momos.',
    initial: 'S',
    gradient: kUserGradients[1],
    isVerified: false,
    interests: ['Rafting', 'Cooking', 'History', 'Farming'],
    profileCompletion: 0.70,
    distance: '77 km',
    occupation: 'Tour Guide',
  ),
  AppUser(
    id: 'u3',
    name: 'Karma',
    age: 25,
    location: 'Bumthang',
    bio: 'Valley of temples 🕌 | Cheese & apple wine connoisseur | Passionate about Bhutanese folklore.',
    initial: 'K',
    gradient: kUserGradients[2],
    isVerified: true,
    interests: ['Folklore', 'Wine', 'Cheese Making', 'Cycling'],
    profileCompletion: 0.90,
    distance: '240 km',
    occupation: 'Cheese Maker',
  ),
  AppUser(
    id: 'u4',
    name: 'Dechen',
    age: 23,
    location: 'Wangdue',
    bio: 'Aspiring architect inspired by Bhutanese dzong style 🏛️ | Watercolor artist | GNH believer.',
    initial: 'D',
    gradient: kUserGradients[3],
    isVerified: false,
    interests: ['Architecture', 'Art', 'Philosophy', 'GNH'],
    profileCompletion: 0.65,
    distance: '120 km',
    occupation: 'Architecture Student',
  ),
  AppUser(
    id: 'u5',
    name: 'Ugyen',
    age: 28,
    location: 'Trashigang',
    bio: 'East Bhutan wanderer 🌄 | Weaving & traditional textiles | Sunrise catcher at Trashigang Dzong.',
    initial: 'U',
    gradient: kUserGradients[4],
    isVerified: true,
    interests: ['Weaving', 'Photography', 'Sunrise Treks', 'Music'],
    profileCompletion: 0.80,
    distance: '550 km',
    occupation: 'Textile Designer',
  ),
  AppUser(
    id: 'u6',
    name: 'Dorji',
    age: 27,
    location: 'Haa',
    bio: 'Haa Valley local ❄️ | Yak herder turned chef | Making traditional Haap cuisine famous.',
    initial: 'D',
    gradient: kUserGradients[5],
    isVerified: false,
    interests: ['Cooking', 'Yak Herding', 'Skiing', 'Festivals'],
    profileCompletion: 0.55,
    distance: '180 km',
    occupation: 'Chef',
  ),
  AppUser(
    id: 'u7',
    name: 'Yangchen',
    age: 24,
    location: 'Trongsa',
    bio: 'Central Bhutan explorer 🗺️ | Raven watcher (our national bird!) | Part-time monk retreat goer.',
    initial: 'Y',
    gradient: kUserGradients[6],
    isVerified: true,
    interests: ['Birdwatching', 'Meditation', 'Trekking', 'Tea Ceremony'],
    profileCompletion: 0.75,
    distance: '162 km',
    occupation: 'Nature Guide',
  ),
];

final List<AppUser> kInitialMatches = [
  kDiscoverUsers[0], // Pema
  kDiscoverUsers[2], // Karma
];

Map<String, List<ChatMessage>> kInitialConversations() => {
      'u1': [
        ChatMessage(
          id: 'm1',
          senderId: 'u1',
          text: 'Tashi Delek! 🙏 I saw you\'re also into hiking. Have you done the Snowman Trek?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
        ChatMessage(
          id: 'm2',
          senderId: kCurrentUserId,
          text: 'Tashi Delek Pema! Not yet but it\'s on my list. You?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          isRead: true,
        ),
        ChatMessage(
          id: 'm3',
          senderId: 'u1',
          text: 'I\'m planning it for next autumn! Maybe we could go together? ☺️',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: false,
        ),
      ],
      'u3': [
        ChatMessage(
          id: 'm4',
          senderId: 'u3',
          text: 'Hi! Loved your hiking photos. Bumthang is magical this time of year 🍎',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
      ],
    };
