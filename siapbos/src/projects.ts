import express,{ Request, Response } from 'express';
import db from './db'; 

const router = express.Router();

router.get('/projects', async (req: Request, res: Response) => {
  try {
    const [rows]: [any[], any] = await db.execute('SELECT id, name, lokasi FROM projects ORDER BY name DESC');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching projects:', error);
    res.status(500).json({ error: 'Failed to fetch projects' });
  }
});

export default router;