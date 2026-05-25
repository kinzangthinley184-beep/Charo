const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.checkAndCreateMatch = functions.firestore
  .document("users/{userId}/likes/{likedUserId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const likedUserId = context.params.likedUserId;

    const reverseSnap = await db
      .collection("users")
      .doc(likedUserId)
      .collection("likes")
      .doc(userId)
      .get();

    if (!reverseSnap.exists) return null;

    const matchId = [userId, likedUserId].sort().join("_");
    await db.collection("matches").doc(matchId).set({
      participants: [userId, likedUserId],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastMessage: "",
      lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const [userSnap, likedSnap] = await Promise.all([
      db.collection("users").doc(userId).get(),
      db.collection("users").doc(likedUserId).get(),
    ]);
    const userData = userSnap.data();
    const likedData = likedSnap.data();

    const notifications = [];
    if (likedData?.fcmToken) {
      notifications.push(
        admin.messaging().send({
          token: likedData.fcmToken,
          notification: {
            title: "New Match!",
            body: `You matched with ${userData?.name ?? "someone"}`,
          },
          data: {
            type: "match",
            chatId: matchId,
            senderId: userId,
          },
          android: { priority: "high" },
        })
      );
    }
    if (userData?.fcmToken) {
      notifications.push(
        admin.messaging().send({
          token: userData.fcmToken,
          notification: {
            title: "New Match!",
            body: `You matched with ${likedData?.name ?? "someone"}`,
          },
          data: {
            type: "match",
            chatId: matchId,
            senderId: likedUserId,
          },
          android: { priority: "high" },
        })
      );
    }
    await Promise.allSettled(notifications);
    return null;
  });

exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const chatId = context.params.chatId;
    const message = snap.data();
    const senderId = message?.senderId;
    const text = message?.text ?? "New message";

    if (!senderId) return null;

    const recipientId = chatId.split("_").find((id) => id !== senderId);

    if (!recipientId) return null;

    const [recipientSnap, senderSnap] = await Promise.all([
      db.collection("users").doc(recipientId).get(),
      db.collection("users").doc(senderId).get(),
    ]);
    const recipientToken = recipientSnap.data()?.fcmToken;
    const senderName = senderSnap.data()?.name ?? "Someone";

    if (!recipientToken) return null;

    await admin.messaging().send({
      token: recipientToken,
      notification: {
        title: senderName,
        body: text.length > 100 ? text.substring(0, 97) + "..." : text,
      },
      data: {
        type: "message",
        chatId: chatId,
        senderId: senderId,
      },
      android: {
        priority: "high",
        notification: { sound: "default" },
      },
      apns: {
        payload: { aps: { sound: "default" } },
      },
    });
    return null;
  });
