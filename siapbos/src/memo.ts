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

interface MemoRequest extends Request {
  body: {
    project_id: number;
    tarikh: string;
    nama_aktiviti: string;
    masa: string;
    lokasi: string;
    keterangan: string;
    created_by: number;
    members?: string[];
  };
}

//create memo
router.post('/memo', async (req: MemoRequest, res: Response) => {
  try {
    const {
      project_id,
      tarikh,
      nama_aktiviti,
      masa,
      lokasi = '',
      keterangan = '',
      created_by,
      members = [],
    } = req.body;

    if (!project_id || !tarikh || !nama_aktiviti || !masa || !created_by) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const formattedTime = masa.length === 5 ? `${masa}:00` : masa;

    // Insert memo
    const [memoResult]: any = await db.execute(
      `INSERT INTO memos (project_id, tarikh, nama_aktiviti, masa, lokasi, keterangan, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        project_id,
        tarikh,
        nama_aktiviti,
        formattedTime,
        lokasi,
        keterangan,
        created_by,
      ]
    );

    const memoId = memoResult.insertId;

    // Loop for each member
    for (const memberName of members) {
      const [rows]: any = await db.execute(
        `SELECT id, fcm_token FROM users WHERE name = ? LIMIT 1`,
        [memberName]
      );

      if (rows.length > 0) {
        const staffId = rows[0].id;
        const fcmToken = rows[0].fcm_token;

        // Insert into memo_staff
        await db.execute(
          `INSERT INTO memo_staff (memo_id, staff_id) VALUES (?, ?)`,
          [memoId, staffId]
        );

        // Send notification
        if (fcmToken) {
          await sendPushNotification(
            fcmToken,
            'Memo Baru',
            `Aktiviti: ${nama_aktiviti} pada ${tarikh} di ${lokasi}`
          );
        }

        // Log notifications table
        await db.execute(
          `INSERT INTO notifications (user_id, memo_id, title, message, status)
           VALUES (?, ?, ?, ?, ?)`,
          [
            staffId,
            memoId,'Memo Baru',`Aktiviti: ${nama_aktiviti} pada ${tarikh} di ${lokasi}`,'sent',
          ]
        );
      }
    }

    res.status(201).json({ message: 'Memo created successfully', memo_id: memoId });
  } catch (error) {
    console.error('❌ Error creating memo:', error);
    res.status(500).json({ message: 'Failed to create memo', error });
  }
});

router.get('/displaymemo', async (req: Request, res: Response) => {
  try {
    const projectId = req.query.project_id;

    if (!projectId) {
      return res.status(400).json({ message: 'Missing project_id' });
    }

    const [memoRows]: any = await db.execute(
      `SELECT m.id, m.nama_aktiviti, m.tarikh, m.masa, m.lokasi,m.keterangan, m.project_id
       FROM memos m
       WHERE m.project_id = ?
       ORDER BY m.tarikh DESC, m.masa DESC`,
      [projectId]
    );

    const memosWithMembers = await Promise.all(
      memoRows.map(async (memo: any) => {
        const [memberRows]: any = await db.execute(
          `SELECT u.name
           FROM memo_staff ms
           JOIN users u ON ms.staff_id = u.id
           WHERE ms.memo_id = ?`,
          [memo.id]
        );
        return {
          ...memo,
          members: memberRows.map((r: any) => r.name)
        };
      })
    );

    res.json(memosWithMembers);
  } catch (error) {
    console.error('Error fetching memos:', error);
    res.status(500).json({ message: 'Failed to fetch memos', error });
  }
});

router.get('/countMemo', async (req, res) => {
  try {
    const [rows]: any = await db.execute(`
      SELECT project_id, COUNT(*) AS total
      FROM memos
      GROUP BY project_id
    `);

    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.delete('/deleteMemos/:id', async (req: Request, res: Response) => {
  const memoId = parseInt(req.params.id, 10);
  try {
    // Delete from `memo_staff` table first (to avoid foreign key constraint errors)
    await db.execute('DELETE FROM memo_staff WHERE memo_id = ?', [memoId]);

    // Delete from `memos` table
    const [result]: any = await db.execute('DELETE FROM memos WHERE id = ?', [memoId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Memo not found' });
    }

    res.status(200).json({ message: 'Memo deleted successfully' });
  } catch (error) {
    console.error('Delete memo error:', error);
    res.status(500).json({ message: 'Failed to delete memo' });
  }
});

router.put('/updateMemos/:id', async (req: Request, res: Response) => {
  const memoId = parseInt(req.params.id, 10);
  const {
    project_id,
    tarikh,
    nama_aktiviti,
    masa,
    lokasi = '',
    keterangan = '',
    created_by,
    members = [],
  } = req.body;

  if (!project_id || !tarikh || !nama_aktiviti || !masa || !created_by) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  const formattedTime = masa.length === 5 ? `${masa}:00` : masa;
  const formattedDate = formatDateOnly(tarikh);

  try {
    const [updateResult]: any = await db.execute(
      `UPDATE memos 
       SET project_id = ?, tarikh = ?, nama_aktiviti = ?, masa = ?, lokasi = ?, keterangan = ?, created_by = ?
       WHERE id = ?`,
      [
        project_id,
        formattedDate,
        nama_aktiviti,
        formattedTime,
        lokasi,
        keterangan,
        created_by,
        memoId,
      ]
    );

    if (updateResult.affectedRows === 0) {
      return res.status(404).json({ message: 'Memo not found or no changes made' });
    }

    await db.execute('DELETE FROM memo_staff WHERE memo_id = ?', [memoId]);

    for (const memberName of members) {
      const [rows]: any = await db.execute(
        `SELECT id FROM users WHERE name = ? LIMIT 1`,
        [memberName]
      );
      if (rows.length > 0) {
        const staffId = rows[0].id;
        await db.execute(
          `INSERT INTO memo_staff (memo_id, staff_id) VALUES (?, ?)`,
          [memoId, staffId]
        );
      } else {
        console.warn(`User not found: ${memberName}`);
      }
    }

    res.status(200).json({ message: 'Memo updated successfully' });
  } catch (error) {
    console.error('❌ Error updating memo:', error);
    res.status(500).json({ message: 'Failed to update memo', error });
  }
})

router.post('/location', (req, res) => {
  const { latitude, longitude, address } = req.body;
  console.log('📍 Received Location:', latitude, longitude, address);

  // Store to DB or process as needed
  res.status(200).json({ message: 'Location received successfully' });
});

router.get('/suggest', async (req: Request, res: Response) => {
  const query = req.query.q as string;

  if (!query) {
    return res.status(400).json({ message: 'Missing query'});
  }

  try {
    const response = await axios.get('https://nominatim.openstreetmap.org/search', {
      params: {
        q: query,
        format: 'json',
        addressdetails: 1,
        limit: 10,
        countrycodes: 'MY', // ✅ filter Malaysia only
        viewbox: '99.6,7.5,119.3,1.0', // optional: sempadan Malaysia (long, lat)
        bounded: 1,
      },
      headers: {
        'User-Agent': 'siapbos-app/1.0',
      },
    });

    const suggestions = response.data.map((item: any) => ({
      name: item.display_name,
      lat: parseFloat(item.lat),
      lon: parseFloat(item.lon),
    }));

    res.json(suggestions);
  } catch (error) {
     res.status(500).json({ message: 'Nominatim error', error });
  }
});

router.post('/memo-summary', async (req, res) => {
  const { memos } = req.body;
  const summary = await generateWithGPT(`Summarize these memos:\n${JSON.stringify(memos)}`);
  res.json({ summary });
});

function generateWithGPT(arg0: string) {
  throw new Error('Function not implemented.');
}

function formatDateOnly(dateInput: string): string {
  const date = new Date(dateInput);
  if (isNaN(date.getTime())) throw new Error('Invalid date format');
  return date.toISOString().split('T')[0];
}


export default router;


