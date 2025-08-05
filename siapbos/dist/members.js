"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const db_1 = __importDefault(require("./db"));
const router = express_1.default.Router();
router.get('/', async (_req, res) => {
    try {
        const [rows] = await db_1.default.execute(`SELECT id, name FROM users WHERE role = 'staff' AND is_active = true ORDER BY name ASC`);
        res.status(200).json(rows);
    }
    catch (error) {
        console.error('Error fetching members:', error);
        res.status(500).json({ error: 'Failed to fetch staff members' });
    }
});
exports.default = router;
