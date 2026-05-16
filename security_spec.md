# Security Specification for Charo

## Data Invariants
1. A user can only create and update their own profile.
2. Swipes can only be created by the authenticated user and must involve the user as `fromUserId`.
3. A match is only created/updated when two users have liked each other (verified via backend logic or secure rules).
4. Messages can only be read and created by users belonging to the parent match.
5. Users cannot delete other users' profiles or swipes.

## The Dirty Dozen Payloads
1. Create a user profile with a different `userId` in the path than the `auth.uid`.
2. Update another user's profile.
3. Inject a 1MB string into the `bio` field.
4. Create a swipe where `fromUserId` is not the `auth.uid`.
5. Modify the `type` of an existing swipe from `nope` to `like`.
6. Read matches that the user is not part of.
7. Send a message to a match the user is not part of.
8. Inject a 1MB message string.
9. Delete another user's match.
10. Update a match's `userIds` to add a third user.
11. Create a user with a `verified` status set to `true` (if not authorized).
12. Read all user profiles without filtering for active/public data (scraping).

## The Test Runner
(I will write `firestore.rules.test.ts` after drafting rules)
