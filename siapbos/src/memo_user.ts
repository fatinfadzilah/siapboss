import express, { Request, Response } from 'express';
import db from './db';
import { sendPushNotification } from './sendPushNotification';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import axios from 'axios';

const router = express.Router();
dotenv.config();
router.use(cors());
router.use(bodyParser.json());

router.get('/memos/assigned/:staffId', async (req: Request, res: Response) => {
  const staffId = parseInt(req.params.staffId, 10);

  try {
    const [memos]: any = await db.execute(
      `SELECT m.id, m.nama_aktiviti, m.tarikh, m.masa, m.lokasi, m.keterangan, m.project_id, ms.accepted, ms.accepted_at
       FROM memos m
       JOIN memo_staff ms ON ms.memo_id = m.id
       WHERE ms.staff_id = ?
       ORDER BY m.tarikh DESC, m.masa DESC`,
      [staffId]
    );

    res.json(memos);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/memos/:memoId/accept', async (req: Request, res: Response) => {
  const memoId = parseInt(req.params.memoId, 10);
  const { staffId } = req.body;

  if (!staffId) {
    return res.status(400).json({ message: 'Missing staffId' });
  }

  try {
    const [result]: any = await db.execute(
      `UPDATE memo_staff 
       SET accepted = true, accepted_at = CURRENT_TIMESTAMP 
       WHERE memo_id = ? AND staff_id = ?`,
      [memoId, staffId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'No memo assigned to this user or already accepted' });
    }

    res.json({ message: 'Memo accepted successfully' });
  } catch (error) {
    console.error('Error accepting memo:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


export default router;