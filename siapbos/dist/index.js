"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const dotenv_1 = __importDefault(require("dotenv"));
const db_1 = __importDefault(require("./db"));
const memo_1 = __importDefault(require("./memo"));
const members_1 = __importDefault(require("./members"));
const noti_1 = __importDefault(require("./noti"));
dotenv_1.default.config();
const app = (0, express_1.default)();
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use('/api', memo_1.default);
app.use('/api', members_1.default);
app.use('/api', noti_1.default);
// AUTH ROUTES
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        const [users] = await db_1.default.execute('SELECT * FROM users WHERE username = ?', [username]);
        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid username or password' });
        }
        const user = users[0];
        const isMatch = await bcryptjs_1.default.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid username or password' });
        }
        const token = jsonwebtoken_1.default.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1d' });
        await db_1.default.execute('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);
        res.json({
            token,
            user: {
                id: user.id,
                username: user.username,
                name: user.name,
                role: user.role,
            }
        });
    }
    catch (err) {
        res.status(500).json({ message: 'Server error', error: err });
    }
});
app.get('/api/test', (_req, res) => {
    res.json({ message: 'Auth route OK' });
});
app.get('/api/profile/:id', async (req, res) => {
    const userId = req.params.id;
    try {
        const [users] = await db_1.default.execute(`
      SELECT id, username, name, email, designation, department, profile_picture 
      FROM users 
      WHERE id = ?
    `, [userId]);
        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(users[0]);
    }
    catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Failed to fetch profile' });
    }
});
app.get('/', (_req, res) => {
    console.log('✅ GET / called');
    res.send('Main route OK');
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`✅ Server runningG on port ${PORT}`);
});
