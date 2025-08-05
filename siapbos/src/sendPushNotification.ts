import express, { Request, Response } from 'express';
const router = express.Router();
import admin from './firebaseAdmin';

export const sendPushNotification = async (fcmToken: string, title: string, body: string) => {
  const message = {
    token: fcmToken,
    notification: {
      title,
      body,
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
  };

  try {
    await admin.messaging().send(message);
    console.log(`✅ Notification sent`);
  } catch (error) {
    console.error('❌ Failed to send notification:', error);
  }
};

// export const fcm = admin.messaging();
export default router;