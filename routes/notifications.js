// routes/notifications.js
//
// ESM version, matching this project's import style (import db from '../models/db.js').
import express from 'express';
import db from '../models/db.js';

const router = express.Router();

const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";

/**
 * Save (or refresh) a device's Expo push token against a user.
 * Call this from the client right after requesting permission.
 */
router.post("/register-token", async (req, res) => {
  const { userId, expoPushToken } = req.body;

  if (!userId || !expoPushToken) {
    return res.status(400).json({ message: "userId and expoPushToken are required." });
  }

  try {
    await db.query(
      `INSERT INTO push_tokens (user_id, expo_push_token)
       VALUES ($1, $2)
       ON CONFLICT (user_id, expo_push_token) DO NOTHING`,
      [userId, expoPushToken]
    );
    res.json({ success: true });
  } catch (error) {
    console.error("Failed to save push token:", error);
    res.status(500).json({ message: "Failed to save push token." });
  }
});

/**
 * Send one or more Expo push notifications.
 * `messages` is an array of { to, title, body, data } objects.
 * Expo's push API accepts batches of up to 100 at a time.
 */
async function sendExpoPushNotifications(messages) {
  const chunks = [];
  for (let i = 0; i < messages.length; i += 100) {
    chunks.push(messages.slice(i, i + 100));
  }

  for (const chunk of chunks) {
    try {
      await fetch(EXPO_PUSH_URL, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify(chunk),
      });
    } catch (error) {
      console.error("Failed to send push notification batch:", error);
    }
  }
}

/**
 * Look up push tokens for a set of user ids, excluding the sender
 * (so people don't get notified about their own message).
 */
async function getPushTokensForUsers(userIds, excludeUserId) {
  if (!userIds.length) return [];
  const { rows } = await db.query(
    `SELECT expo_push_token FROM push_tokens
     WHERE user_id = ANY($1::uuid[]) AND user_id != $2`,
    [userIds, excludeUserId]
  );
  return rows.map((r) => r.expo_push_token);
}

/**
 * Call this right after a new answer/comment is saved to the DB.
 * `recipientUserIds` should be the question owner plus anyone else
 * already in the thread (so the whole thread gets pinged).
 */
export async function notifyNewQnaMessage({ recipientUserIds, senderUserId, subjectId, subjectName, questionTitle }) {
  const tokens = await getPushTokensForUsers(recipientUserIds, senderUserId);
  if (!tokens.length) return;

  const messages = tokens.map((token) => ({
    to: token,
    sound: "default",
    title: `New reply in ${subjectName}`,
    body: questionTitle ? `New message on: ${questionTitle}` : "New message in your Q&A chat",
    data: { type: "qna_message", subjectId: String(subjectId) },
  }));

  await sendExpoPushNotifications(messages);
}

export default router;