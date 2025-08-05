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

router.get('/projects/:id/staff', async (req: Request, res: Response) => {
  const projectId = parseInt(req.params.id);
  try {
    const [staff] = await db.query(
      `SELECT u.id, u.name, u.department, u.designation
       FROM users u
       JOIN project_staff ps ON ps.staff_id = u.id
       WHERE ps.project_id = ?`,
      [projectId]
    );
    res.json(staff);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch staff' });
  }
});

// Get available staff (not yet assigned to project)
router.get('/projects/:id/availableStaff', async (req: Request, res: Response) => {
  const projectId = parseInt(req.params.id);
  try {
    const [staff] = await db.query(
      `SELECT id, name FROM users 
       WHERE role = 'staff' AND id NOT IN (
         SELECT staff_id FROM project_staff WHERE project_id = ?
       )`,
      [projectId]
    );
    res.json(staff);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch available staff' });
  }
});

// Add staff to a project
router.post('/projects/:id/staff', async (req: Request, res: Response) => {
  const projectId = parseInt(req.params.id);
  const { staffIds } = req.body; // expects array of ids

  if (!Array.isArray(staffIds)) {
    return res.status(400).json({ error: 'staffIds must be an array' });
  }

  try {
    const values = staffIds.map((id: number) => [projectId, id]);
    await db.query(
      'INSERT IGNORE INTO project_staff (project_id, staff_id) VALUES ?',
      [values]
    );
    res.json({ message: 'Staff assigned successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to assign staff' });
  }
});

router.get('/projects/:id/staff', async (req: Request, res: Response) => {
  const projectId = parseInt(req.params.id);
  try {
    const [staff] = await db.query(
      `SELECT u.id, u.name, u.department, u.designation
       FROM users u
       JOIN project_staff ps ON ps.staff_id = u.id
       WHERE ps.project_id = ?`,
      [projectId]
    );
    res.json(staff);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch staff' });
  }
});

// Get available staff (not yet assigned to project)
router.get('/projects/:id/availableStaff', async (req: Request, res: Response) => {
  const projectId = parseInt(req.params.id);
  try {
    const [staff] = await db.query(
      `SELECT id, name FROM users 
       WHERE role = 'staff' AND id NOT IN (
         SELECT staff_id FROM project_staff WHERE project_id = ?
       )`,
      [projectId]
    );
    res.json(staff);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch available staff' });
  }
});

// Add staff to a project
router.post('/projects/:id/staff', async (req: Request, res: Response) => {
  const projectId = parseInt(req.params.id);
  const { staffIds } = req.body; // expects array of ids

  if (!Array.isArray(staffIds)) {
    return res.status(400).json({ error: 'staffIds must be an array' });
  }

  try {
    const values = staffIds.map((id: number) => [projectId, id]);
    await db.query(
      'INSERT IGNORE INTO project_staff (project_id, staff_id) VALUES ?',
      [values]
    );
    res.json({ message: 'Staff assigned successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to assign staff' });
  }
});


export default router;