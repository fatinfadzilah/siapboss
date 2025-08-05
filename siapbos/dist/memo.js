"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const db_1 = __importDefault(require("./db"));
const router = express_1.default.Router();
router.post('/memo', async (req, res) => {
    try {
        const { project_id, tarikh, nama_aktiviti, masa, lokasi, created_by, members } = req.body;
        const formattedTime = '10:00:00';
        console.log('📥 Received masa:', masa);
        const [memoResult] = await db_1.default.execute(`INSERT INTO memos (project_id, tarikh, nama_aktiviti, masa, lokasi, created_by)
       VALUES (?, ?, ?, ?, ?, ?)`, [project_id, tarikh, nama_aktiviti, formattedTime, lokasi, created_by]);
        const memoId = memoResult.insertId;
        if (members && members.length > 0) {
            for (const memberName of members) {
                const [rows] = await db_1.default.execute(`SELECT id FROM users WHERE name = ? LIMIT 1`, [memberName]);
                if (rows.length > 0) {
                    const staffId = rows[0].id;
                    await db_1.default.execute(`INSERT INTO memo_staff (memo_id, staff_id) VALUES (?, ?)`, [memoId, staffId]);
                }
            }
        }
        res.status(201).json({ message: 'Memo created successfully', memo_id: memoId });
    }
    catch (error) {
        console.error('Error creating memo:', error);
        res.status(500).json({ message: 'Failed to create memo', error });
    }
});
router.get('/testingggg', (_req, res) => {
    res.json({ message: 'Auth rommmute OK' });
});
exports.default = router;
