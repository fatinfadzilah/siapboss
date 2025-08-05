import express, { Request, Response } from 'express';
const router = express.Router();
import axios from 'axios';
import db from './db';

export async function sendPushNotification(token: string, title: string, body: string): Promise<boolean> {
  try {
    const response = await axios.post('https://fcm.googleapis.com/fcm/send', {
      to: token,
      notification: {
        title,
        body,
      },
    }, {
      headers: {
        'Authorization': `key=${process.env.FCM_SERVER_KEY}`,
        'Content-Type': 'application/json',
      },
    });

    console.log('✅ Notification sent:', response.data);
    return true;
  } catch (error) {
    console.error('❌ Notification failed:', error);
    return false;
  }
}


router.get('/notifications', async (req: Request, res: Response) => {
  const [rows]: any = await db.execute(`
    SELECT n.id, u.name AS user_name, n.title, n.message, n.status, n.sent_at
    FROM notifications n
    JOIN users u ON n.user_id = u.id
    ORDER BY n.sent_at DESC
  `);
  res.json(rows);
});

// export const fcm = admin.messaging();
export default router;