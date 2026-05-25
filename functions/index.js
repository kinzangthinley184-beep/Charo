const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.checkAndCreateMatch = functions.firestore
  .document("users/{userId}/likes/{likedUserId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const likedUserId = context.params.likedUserId;

    try {
      // Check if the other person already liked us back
      const reverseDoc = await db
        .collection("users")
        .doc(likedUserId)
        .collection("likes")
        .doc(userId)
        .get();

      if (!reverseDoc.exists) {
        // No mutual like yet — do nothing
        return null;
      }

      // Mutual like found — create a match
      const matchId = [userId, likedUserId].sort().join("_");
      const matchRef = db.collection("matches").doc(matchId);
      const matchDoc = await matchRef.get();

      if (matchDoc.exists) {
        // Match already exists — do nothing
        return null;
      }

      await matchRef.set({
        participants: [userId, likedUserId],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Match created: ${matchId}`);
      return null;
    } catch (error) {
      console.error("Error creating match:", error);
      return null;
    }
  });