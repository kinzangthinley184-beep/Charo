/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

export interface Profile {
  id: string;
  name: string;
  age: number;
  gender: string;
  location: string;
  imageUrl: string;
  photos: string[];
  bio?: string;
  interests?: string[];
  verified: boolean;
  occupation: string;
  education: string;
  height: string;
  zodiacSign: string;
  bhutaneseZodiac: string;
  religion: string;
  ethnicity: string;
  languages: string[];
  hometown: string;
  latitude: number;
  longitude: number;
  drinkingHabit: string;
  smokingHabit: string;
  lookingFor: string;
  profileCompletion: number;
  matchPercentage: number;
  shareLocation?: boolean;
}

export type Screen = 'profile' | 'explore' | 'matches' | 'chat';

export interface Message {
  id: string;
  text?: string;
  image?: string;
  sender: 'me' | 'them';
  timestamp: string;
}

export interface Chat {
  id: string;
  name: string;
  matchProfile: Profile;
  lastMessage: string;
  unread: boolean;
  online: boolean;
}
