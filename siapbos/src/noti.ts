import express, { Request, Response } from 'express';
import { sendPushNotification } from './sendPushNotification';
import db from './db';

const router = express.Router();

router.get('/ping', (_req, res) => {
  res.send('pong from noti');
});

router.post('/pushNotify', async (req: Request, res: Response) => {
  const { fcmToken, title, body } = req.body;

  if (!fcmToken) {
    return res.status(400).json({ message: 'fcmToken is required' });
  }

  try {
    await sendPushNotification(fcmToken, title || 'Ujian', body || 'Ini mesej push');
    res.json({ message: '✅ Notification sent' });
  } catch (err) {
    res.status(500).json({ message: '❌ Failed to send push', error: err });
  }
});

// saveToken
router.post('/saveToken', async (req: Request, res: Response) => {
  const { user_id, fcm_token } = req.body;

  if (!user_id || !fcm_token) {
    return res.status(400).json({ message: 'Missing user_id or fcm_token' });
  }

  try {
    await db.execute(`UPDATE users SET fcm_token = ? WHERE id = ?`, [fcm_token, user_id]);
    res.json({ message: 'Token saved' });
  } catch (err) {
    console.error('Error saving token:', err);
    res.status(500).json({ message: 'Failed to save token' });
  }
});

export default router;
