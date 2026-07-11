import express from 'express';
import {
  signup,
  login,
  verifyEmail,
  requestResetPassword,
  resetPassword,
  getMe,
} from '../controllers/auth.controller.js';
import { requireAuth, authorizeRoles, isAdmin } from '../middlewares/auth.middleware.js';
import passport from '../middlewares/passport.js';
import jwt from 'jsonwebtoken';
import { googleCallback } from "../controllers/auth.controller.js";
import pool from '../models/db.js'; // adjust filename if different

const router = express.Router();
// somewhere with other routes:
router.get('/verify/:token', verifyEmail);

router.post('/signup', signup);
router.post('/login', login);
router.get('/verify/:token', verifyEmail); 
router.post('/request-password-reset', requestResetPassword);
router.post('/reset-password/:token', resetPassword);
router.get('/api/subject', requireAuth, (req, res) => {
  // Now req.user is available
  res.json({ message: 'Success', user: req.user });
});
router.get("/me", requireAuth, getMe);

router.get('/admin/dashboard', requireAuth, isAdmin, (req, res) => {
  res.json({ message: 'Welcome Admin' });
});

function isAllowedRedirect(url) {
  const whitelist = (process.env.OAUTH_REDIRECT_WHITELIST || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  if (!whitelist.length) return false;
  return whitelist.includes(url);
}

router.post('/set-role', requireAuth, setRole);
// Start Google login (frontend hits this)
router.get(
  '/google',
  passport.authenticate('google', { scope: ['profile', 'email'], session: false })
);

// Google OAuth callback
router.get(
  "/google/callback",
  passport.authenticate("google", { session: false, failureRedirect: "/login" }),
  (req, res) => {
    const user = req.user;

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    // ✅ CLEAN REDIRECT BACK TO EXPO
    const redirectUrl = `eduapp://redirect?token=${token}`;

    return res.redirect(redirectUrl);
  }
);

router.get('/verify/:token', verifyEmail);

// Route for all logged-in users
router.get('/profile', requireAuth, (req, res) => {
  res.json({ message: `Welcome, ${req.user.role}!` });
});

// Only teachers
router.post('/create-class', requireAuth, authorizeRoles('teacher'), (req, res) => {
  res.json({ message: 'Class created successfully!' });
});

// Only students
router.get('/my-grades', requireAuth, authorizeRoles('student'), (req, res) => {
  res.json({ message: 'Here are your grades' });
});

// Teachers + Admin
router.post('/add-assignment', requireAuth, authorizeRoles('teacher', 'admin'), (req, res) => {
  res.json({ message: 'Assignment added successfully!' });
});

// Admin only
router.delete('/delete-user/:id', requireAuth, isAdmin, (req, res) => {
  res.json({ message: 'User deleted by Admin' });
});

router.get('/me', requireAuth, (req, res) => {
  res.json({
    userId: req.user.userId,
    role: req.user.role,
  });
});

// Mobile Google login — receives Google access token, returns your JWT

router.get("/google/mobile-callback", async (req, res) => {
  const accessToken = req.query.token;

  if (!accessToken) {
    return res.status(400).json({ message: "No token provided" });
  }

  try {
    const googleRes = await fetch("https://www.googleapis.com/oauth2/v3/userinfo", {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    const profile = await googleRes.json();

    if (!profile.email) {
      return res.status(401).json({ message: "Invalid Google token" });
    }

    let result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [profile.email]
    );

    let user = result.rows[0];
    let isNewUser = false;

    // If new user, create WITHOUT a role
    if (!user) {
      isNewUser = true;
      const insertResult = await pool.query(
        'INSERT INTO users (email, full_name, role) VALUES ($1, $2, $3) RETURNING *',
        [profile.email, profile.name, null] // null role — they will pick it
      );
      user = insertResult.rows[0];
    }

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "2h" }
    );

    // Send isNewUser flag so frontend knows to show role selection
    res.json({
      token,
      isNewUser,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
      },
    });

  } catch (err) {
    console.error("Mobile Google login error:", err);
    res.status(500).json({ message: "Google login failed" });
  }
});


router.post("/set-role", requireAuth, async (req, res) => {
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

export default router;
