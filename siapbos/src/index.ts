import express, { Request, Response } from 'express';
import cors from 'cors';
import * as jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import bcrypt from 'bcryptjs';

import db from './db';
import memoRoutes from './memo';
import membersRoutes from './members';
import projectRoutes from './projects';
import sendMemoRoutes from './sendPushNotification';
import notiRoutes from './noti';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());
app.use('/api', memoRoutes);
app.use('/api', membersRoutes);
app.use('/api', projectRoutes);
app.use('/api', sendMemoRoutes);
app.use('/api', notiRoutes);

// AUTH ROUTES
app.post('/api/login', async (req: Request, res: Response) => {
  const { username, password } = req.body;
  try {
    const [users]: any = await db.execute('SELECT * FROM users WHERE username = ?', [username]);

    if (users.length === 0) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET as string,
      { expiresIn: '1d' }
    );

    await db.execute('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        name: user.name,
        role: user.role,
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err });
  }
});

app.get('/api/test', (_req: Request, res: Response) => {
  res.json({ message: 'Auth route OddK' });
});

app.get('/', (_req: Request, res: Response) => {
  console.log('✅ GET / called');
  res.send('Main route OK');
});

app.get('/api/profile/:userId', async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId;
    const [rows]: any = await db.execute(
      `SELECT id, username, name, department, designation, role, is_active, created_at 
       FROM users WHERE id = ? LIMIT 1`,
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = rows[0];
    res.json({
      id: user.id,
      email: user.username,
      name: user.name,
      department: user.department,
      designation: user.designation,
      role: user.role,
      is_active: user.is_active,
      created_at: user.created_at,
      // profile_picture: `https://api.example.com/profile-pictures/${user.id}.png` // optional
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
