import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> deleteSeedUsers() async {
  if (FirebaseAuth.instance.currentUser == null) return;
  try {
    final col = FirebaseFirestore.instance.collection('users');
    final snap = await col.get();
    final batch = FirebaseFirestore.instance.batch();
    int count = 0;
    for (final doc in snap.docs) {
      final img = (doc.data()['profileImage'] as String?) ?? '';
      if (img.contains('pravatar.cc') || img.contains('i.pravatar')) {
        batch.delete(doc.reference);
        count++;
      }
    }
    if (count > 0) {
      await batch.commit();
      debugPrint('[SEED] Deleted $count seed users from Firestore.');
    }
  } catch (e) {
    debugPrint('[SEED] Cleanup error: $e');
  }
}

Future<void> seedFirestoreIfNeeded() async {
  if (FirebaseAuth.instance.currentUser == null) return;
  // Seeding disabled — real users only.
  return;

  // ignore: dead_code
  final col = FirebaseFirestore.instance.collection('users');
  final snapshot = await col.limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    debugPrint('[SEED] Firestore already has users — skipping seed.');
    return;
  }

  debugPrint('[SEED] Seeding 10 Bhutanese users...');

  final users = <Map<String, dynamic>>[
    {
      'name': 'Tenzin',
      'age': 26,
      'gender': 'Male',
      'bio': "Mountain trekker and archery enthusiast. Love the tranquility of Bhutan's valleys. 🏹",
      'location': 'Thimphu',
      'profileImage': 'https://i.pravatar.cc/300?img=1',
      'interests': ['Archery', 'Hiking', 'Buddhist Art', 'Photography'],
      'verified': true,
      'photos': [],
      'occupation': 'Civil Servant',
      'education': 'Royal University of Bhutan',
      'religion': 'Buddhism',
      'zodiacSign': 'Scorpio',
      'bhutaneseZodiac': 'Iron Tiger',
      'languages': 'Dzongkha, English',
      'distance': '12 km',
      'height': "5'9\"",
      'drinkingHabit': 'Occasionally',
      'smokingHabit': 'Never',
      'lookingFor': 'Long-term relationship',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.85,
    },
    {
      'name': 'Pema',
      'age': 24,
      'gender': 'Female',
      'bio': 'Lover of Bhutanese textiles and traditional dance. Weekend farmer. 🌾',
      'location': 'Paro',
      'profileImage': 'https://i.pravatar.cc/300?img=5',
      'interests': ['Weaving', 'Traditional Dance', 'Farming', 'Cooking'],
      'verified': true,
      'photos': [],
      'occupation': 'Teacher',
      'education': 'Samtse College of Education',
      'religion': 'Buddhism',
      'zodiacSign': 'Virgo',
      'bhutaneseZodiac': 'Water Dog',
      'languages': 'Dzongkha, English, Tshangla',
      'distance': '65 km',
      'height': "5'4\"",
      'drinkingHabit': 'Never',
      'smokingHabit': 'Never',
      'lookingFor': 'Serious relationship',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.90,
    },
    {
      'name': 'Sonam',
      'age': 27,
      'gender': 'Male',
      'bio': "GNH advocate. Working to make Bhutan's happiness philosophy known worldwide. 🌏",
      'location': 'Punakha',
      'profileImage': 'https://i.pravatar.cc/300?img=8',
      'interests': ['GNH Philosophy', 'River Rafting', 'Photography', 'Travel'],
      'verified': false,
      'photos': [],
      'occupation': 'Tour Guide',
      'education': 'Tourism & Hospitality',
      'religion': 'Buddhism',
      'zodiacSign': 'Gemini',
      'bhutaneseZodiac': 'Fire Horse',
      'languages': 'Dzongkha, English, Hindi',
      'distance': '77 km',
      'height': "5'8\"",
      'drinkingHabit': 'Social drinker',
      'smokingHabit': 'Never',
      'lookingFor': 'Open to anything',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.70,
    },
    {
      'name': 'Karma',
      'age': 25,
      'gender': 'Female',
      'bio': 'Doctor in training. Passionate about bringing healthcare to remote Bhutanese villages. ❤️',
      'location': 'Bumthang',
      'profileImage': 'https://i.pravatar.cc/300?img=9',
      'interests': ['Medicine', 'Hiking', 'Volunteering', 'Reading'],
      'verified': true,
      'photos': [],
      'occupation': 'Medical Intern',
      'education': 'Khesar Gyalpo University of Medical Sciences',
      'religion': 'Buddhism',
      'zodiacSign': 'Cancer',
      'bhutaneseZodiac': 'Earth Ox',
      'languages': 'Dzongkha, English, Bumthangkha',
      'distance': '198 km',
      'height': "5'5\"",
      'drinkingHabit': 'Never',
      'smokingHabit': 'Never',
      'lookingFor': 'Long-term relationship',
      'ethnicity': 'Bumthap',
      'profileCompletion': 0.95,
    },
    {
      'name': 'Dechen',
      'age': 23,
      'gender': 'Female',
      'bio': 'Art student obsessed with traditional Bhutanese thangka painting. Coffee addict ☕',
      'location': 'Thimphu',
      'profileImage': 'https://i.pravatar.cc/300?img=10',
      'interests': ['Thangka Painting', 'Buddhist Art', 'Coffee', 'Music'],
      'verified': true,
      'photos': [],
      'occupation': 'Art Student',
      'education': 'National Institute for Zorig Chusum',
      'religion': 'Buddhism',
      'zodiacSign': 'Libra',
      'bhutaneseZodiac': 'Wood Rabbit',
      'languages': 'Dzongkha, English',
      'distance': '8 km',
      'height': "5'3\"",
      'drinkingHabit': 'Occasionally',
      'smokingHabit': 'Never',
      'lookingFor': 'Casual dating',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.75,
    },
    {
      'name': 'Ugyen',
      'age': 28,
      'gender': 'Male',
      'bio': 'Farmer by heart, coder by trade. Building apps for rural Bhutan. 💻🌱',
      'location': 'Trashigang',
      'profileImage': 'https://i.pravatar.cc/300?img=12',
      'interests': ['Coding', 'Farming', 'Community Work', 'Football'],
      'verified': false,
      'photos': [],
      'occupation': 'Software Developer',
      'education': 'Royal University of Bhutan',
      'religion': 'Buddhism',
      'zodiacSign': 'Aries',
      'bhutaneseZodiac': 'Metal Sheep',
      'languages': 'Dzongkha, Tshangla, English',
      'distance': '550 km',
      'height': "5'10\"",
      'drinkingHabit': 'Rarely',
      'smokingHabit': 'Never',
      'lookingFor': 'Long-term relationship',
      'ethnicity': 'Sharchop',
      'profileCompletion': 0.65,
    },
    {
      'name': 'Dorji',
      'age': 22,
      'gender': 'Male',
      'bio': 'Young entrepreneur running a local handicraft startup. Believer in GNH. 🎋',
      'location': 'Haa',
      'profileImage': 'https://i.pravatar.cc/300?img=15',
      'interests': ['Entrepreneurship', 'Handicrafts', 'Archery', 'Trekking'],
      'verified': false,
      'photos': [],
      'occupation': 'Entrepreneur',
      'education': 'Gaeddu College of Business Studies',
      'religion': 'Buddhism',
      'zodiacSign': 'Taurus',
      'bhutaneseZodiac': 'Water Snake',
      'languages': 'Dzongkha, English',
      'distance': '180 km',
      'height': "5'7\"",
      'drinkingHabit': 'Occasionally',
      'smokingHabit': 'Never',
      'lookingFor': 'Open to anything',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.60,
    },
    {
      'name': 'Yangchen',
      'age': 25,
      'gender': 'Female',
      'bio': "Nature photographer exploring Bhutan's pristine wilderness. 📷🌿",
      'location': 'Trongsa',
      'profileImage': 'https://i.pravatar.cc/300?img=20',
      'interests': ['Photography', 'Wildlife', 'Hiking', 'Meditation'],
      'verified': true,
      'photos': [],
      'occupation': 'Photographer',
      'education': 'Media & Communication',
      'religion': 'Buddhism',
      'zodiacSign': 'Pisces',
      'bhutaneseZodiac': 'Fire Rabbit',
      'languages': 'Dzongkha, English',
      'distance': '220 km',
      'height': "5'5\"",
      'drinkingHabit': 'Never',
      'smokingHabit': 'Never',
      'lookingFor': 'Friendship first',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.80,
    },
    {
      'name': 'Kinza',
      'age': 26,
      'gender': 'Female',
      'bio': 'Dzong architecture admirer. Working in heritage conservation. 🏯',
      'location': 'Punakha',
      'profileImage': 'https://i.pravatar.cc/300?img=25',
      'interests': ['Heritage Conservation', 'Architecture', 'History', 'Travel'],
      'verified': true,
      'photos': [],
      'occupation': 'Heritage Conservationist',
      'education': 'College of Natural Resources',
      'religion': 'Buddhism',
      'zodiacSign': 'Leo',
      'bhutaneseZodiac': 'Wood Dragon',
      'languages': 'Dzongkha, English',
      'distance': '77 km',
      'height': "5'6\"",
      'drinkingHabit': 'Rarely',
      'smokingHabit': 'Never',
      'lookingFor': 'Long-term relationship',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.88,
    },
    {
      'name': 'Rinchen',
      'age': 27,
      'gender': 'Male',
      'bio': 'Aspiring monk turned IT professional. Still meditating daily 🧘. Living in Thimphu.',
      'location': 'Thimphu',
      'profileImage': 'https://i.pravatar.cc/300?img=30',
      'interests': ['Meditation', 'Technology', 'Dharma', 'Cycling'],
      'verified': false,
      'photos': [],
      'occupation': 'IT Specialist',
      'education': 'Sherubtse College',
      'religion': 'Buddhism',
      'zodiacSign': 'Capricorn',
      'bhutaneseZodiac': 'Earth Bird',
      'languages': 'Dzongkha, English, Tibetan',
      'distance': '15 km',
      'height': "5'8\"",
      'drinkingHabit': 'Never',
      'smokingHabit': 'Never',
      'lookingFor': 'Spiritual partner',
      'ethnicity': 'Ngalop',
      'profileCompletion': 0.72,
    },
  ];

  final batch = FirebaseFirestore.instance.batch();
  for (final user in users) {
    batch.set(col.doc(), user);
  }
  await batch.commit();
  debugPrint('[SEED] Seeded ${users.length} users successfully.');
}
