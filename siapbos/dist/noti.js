"use strict";
// import express, { Request, Response } from 'express';
// import db from './db';
// import axios from 'axios';
Object.defineProperty(exports, "__esModule", { value: true });
// const router = express.Router();
// // Define request body structure
// interface SendMemoRequest extends Request {
//   body: {
//     project_id: number;
//     tarikh: string;
//     nama_aktiviti: string;
//     masa: string;
//     lokasi: string;
//     created_by: number;
//     staff_ids: number[];
//   };
// }
// // Push notification function
// async function sendPush(fcmToken: string, title: string, body: string) {
//   await axios.post(
//     'https://fcm.googleapis.com/fcm/send',
//     {
//       to: fcmToken,
//       notification: {
//         title,
//         body,
//       },
//       data: {
//         click_action: 'FLUTTER_NOTIFICATION_CLICK',
//       },
//     },
//     {
//       headers: {
//         Authorization: `key=${process.env.FCM_SERVER_KEY}`,
//         'Content-Type': 'application/json',
//       },
//     }
//   );
// }
// router.post('/sendMemo', async (req: SendMemoRequest, res: Response) => {
//   const { project_id, tarikh, nama_aktiviti, masa, lokasi, created_by, staff_ids } = req.body;
//   const conn = await db.getConnection();
//   await conn.beginTransaction();
//   try {
//     // 1. Insert memo
//     const [memoRes]: any = await conn.execute(
//       `
//       INSERT INTO memos (project_id, tarikh, nama_aktiviti, masa, lokasi, created_by)
//       VALUES (?, ?, ?, ?, ?, ?)`,
//       [project_id, tarikh, nama_aktiviti, masa, lokasi, created_by]
//     );
//     const memo_id = memoRes.insertId;
//     // 2. Insert into memo_staff
//     for (const staff_id of staff_ids) {
//       await conn.execute(
//         `INSERT INTO memo_staff (memo_id, staff_id) VALUES (?, ?)`,
//         [memo_id, staff_id]
//       );
//     }
//     // 3. Get FCM tokens of staff
//     const [tokens]: any = await conn.query(
//       `SELECT fcm_token FROM users WHERE id IN (?) AND fcm_token IS NOT NULL AND is_active = TRUE`,
//       [staff_ids]
//     );
//     // 4. Send push notification
//     for (const { fcm_token } of tokens) {
//       await sendPush(fcm_token, "Memo Baru", `Aktiviti: ${nama_aktiviti} pada ${tarikh} jam ${masa}`);
//     }
//     await conn.commit();
//     res.json({ success: true, memo_id });
//   } catch (error) {
//     await conn.rollback();
//     console.error(error);
//     res.status(500).json({ success: false, message: "Gagal hantar memo" });
//   } finally {
//     conn.release();
//   }
// });
// export default router;
