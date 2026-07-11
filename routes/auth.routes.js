import express from 'express';
import {
  signup,
  login,
  verifyEmail,
  requestResetPassword,
  resetPassword,
  getMe,
  googleCallback,
} from '../controllers/auth.controller.js';
import { requireAuth, authorizeRoles, isAdmin } from '../middlewares/auth.middleware.js';
import passport from '../middlewares/passport.js';
import jwt from 'jsonwebtoken';
import pool from '../models/db.js';

const router = express.Router();

// Auth routes
router.post('/signup', signup);
router.post('/login', login);
router.get('/verify/:token', verifyEmail);
router.post('/request-password-reset', requestResetPassword);
router.post('/reset-password/:token', resetPassword);
router.get('/me', requireAuth, getMe);

// Role management
router.post('/set-role', requireAuth, async (req, res) => {
  const { role } = req.body;
  const validRoles = ["admin", "teacher", "parent", "student"];

  if (!validRoles.includes(role)) {
    return res.status(400).json({ message: "Invalid role" });
  }

  try {
    const result = await pool.query(
      'UPDATE users SET role = $1 WHERE id = $2 RETURNING *',
      [role, req.user.userId]
    );

    const user = result.rows[0];

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    res.json({
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    console.error("Set role error:", err);
    res.status(500).json({ message: "Failed to set role" });
  }
});

// Google OAuth
router.get('/google', passport.authenticate('google', { scope: ['profile', 'email'], session: false }));

router.get(
  '/google/callback',
  passport.authenticate('google', { session: false, failureRedirect: '/login' }),
  (req, res) => {
    const user = req.user;
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '2h' }
    );
    return res.redirect(`eduapp://redirect?token=${token}`);
  }
);

// Mobile Google login
router.get('/google/mobile-callback', async (req, res) => {
  const accessToken = req.query.token;

  if (!accessToken) {
    return res.status(400).json({ message: 'No token provided' });
  }

  try {
    const googleRes = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    const profile = await googleRes.json();

    if (!profile.email) {
      return res.status(401).json({ message: 'Invalid Google token' });
    }

    let result = await pool.query('SELECT * FROM users WHERE email = $1', [profile.email]);
    let user = result.rows[0];
    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      const insertResult = await pool.query(
        'INSERT INTO users (email, full_name, role) VALUES ($1, $2, $3) RETURNING *',
        [profile.email, profile.name, null]
      );
      user = insertResult.rows[0];
    }

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '2h' }
    );

    res.json({
      token,
      isNewUser,
      user: { id: user.id, full_name: user.full_name, email: user.email, role: user.role },
    });

  } catch (err) {
    console.error('Mobile Google login error:', err);
    res.status(500).json({ message: 'Google login failed' });
  }
});

// Role-based routes
router.get('/profile', requireAuth, (req, res) => {
  res.json({ message: `Welcome, ${req.user.role}!` });
});
router.post('/create-class', requireAuth, authorizeRoles('teacher'), (req, res) => {
  res.json({ message: 'Class created successfully!' });
});
router.get('/my-grades', requireAuth, authorizeRoles('student'), (req, res) => {
  res.json({ message: 'Here are your grades' });
});
router.post('/add-assignment', requireAuth, authorizeRoles('teacher', 'admin'), (req, res) => {
  res.json({ message: 'Assignment added successfully!' });
});
router.delete('/delete-user/:id', requireAuth, isAdmin, (req, res) => {
  res.json({ message: 'User deleted by Admin' });
});
router.get('/admin/dashboard', requireAuth, isAdmin, (req, res) => {
  res.json({ message: 'Welcome Admin' });
});

export default router;