import express, { Request, Response } from 'express';
import db from './db';

const router = express.Router();

router.get('/members', async (_req: Request, res: Response) => {
  try {
    const [rows]: any = await db.execute(
      `SELECT id, name FROM users WHERE role = 'staff' AND is_active = true ORDER BY name ASC`
    );
    res.status(200).json(rows);
    
  } catch (error) {
    console.error('Error fetching members:', error);
    res.status(500).json({ error: 'Failed to fetch staff members' });
  }
});

export default router;
