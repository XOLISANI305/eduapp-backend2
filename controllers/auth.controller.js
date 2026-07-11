import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import pool from '../models/db.js';
import { sendVerificationEmail } from '../services/email.js';
import { setRole } from '../controllers/auth.controller.js';
import dotenv from 'dotenv';

dotenv.config();

// ------------------------ SIGNUP ------------------------
export const signup = async (req, res) => {
  const { full_name, email, password, role = 'student', oauthUser = false } = req.body;

  try {
    const allowedRoles = ["student", "teacher", "parent", "admin"];
    if (!allowedRoles.includes(role)) {
      return res.status(400).json({ message: "Invalid role selected" });
    }

    const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    let hashedPassword = null;
    let verificationToken = null;
    let isVerified = false;

    if (!oauthUser) {
      if (!password) {
        return res.status(400).json({ message: 'Password is required' });
      }
      hashedPassword = await bcrypt.hash(password, 10);
      verificationToken = crypto.randomBytes(32).toString('hex');
    } else {
      isVerified = true;
    }

    const newUser = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, role, verification_token, is_verified)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [full_name, email, hashedPassword, role, verificationToken, isVerified]
    );

    if (!oauthUser) {
      const verificationUrl = `${process.env.BACKEND_URL}/api/auth/verify/${verificationToken}`;
      await sendVerificationEmail(email, verificationUrl);
      console.log("Verification email sent to:", email, "Link:", verificationUrl);
    }

    res.status(201).json({
      message: 'User registered successfully, please check your email to verify.',
      user: {
        id: newUser.rows[0].id,
        full_name: newUser.rows[0].full_name,
        email: newUser.rows[0].email,
        role: newUser.rows[0].role,
        is_verified: newUser.rows[0].is_verified
      },
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server error' });
  }
};

// ------------------------ VERIFY EMAIL ------------------------
export const verifyEmail = async (req, res) => {
  const { token } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE verification_token = $1',
      [token]
    );

    const user = result.rows[0];
    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired verification token' });
    }

    await pool.query(
      `UPDATE users SET is_verified = true, verification_token = NULL WHERE id = $1`,
      [user.id]
    );

    res.json({ message: 'Email verified successfully! You can now log in.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// ------------------------ LOGIN ------------------------
export const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user) return res.status(400).json({ message: 'Invalid credentials' });
    if (!user.password_hash) return res.status(400).json({ message: 'Please login using Google or Facebook' });

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

    if (!user.is_verified) return res.status(401).json({ message: 'Email not verified. Please check your inbox!' });

    const token = jwt.sign({ userId: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1d' });

    res.json({
      token,
      user: { id: user.id, full_name: user.full_name, email: user.email, role: user.role },
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server error' });
  }
};

// ------------------------ GOOGLE CALLBACK ------------------------
export const googleCallback = (req, res) => {
  const user = req.user;

  const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '2h' }
  );

  const redirectTo = req.query.redirect || process.env.FRONTEND_URL;
  const separator = redirectTo.includes('?') ? '&' : '?';
  res.redirect(`${redirectTo}${separator}token=${token}`);
};

// ------------------------ SET ROLE ------------------------
export const setRole = async (req, res) => {
  try {
    const { role } = req.body;
    const userId = req.user.userId;

    const allowedRoles = ["student", "teacher", "parent", "admin"];
    if (!allowedRoles.includes(role)) {
      return res.status(400).json({ message: "Invalid role" });
    }

    await pool.query('UPDATE users SET role = $1 WHERE id = $2', [role, userId]);
    res.json({ message: "Role updated successfully" });
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
};

// ------------------------ REQUEST RESET PASSWORD ------------------------
export const requestResetPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const userRes = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = userRes.rows[0];

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 1000 * 60 * 30);

    await pool.query(
      `INSERT INTO password_reset_tokens (user_id, token, expires_at)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id) DO UPDATE SET token = $2, expires_at = $3`,
      [user.id, resetToken, expiresAt]
    );

    const resetLink = `http://localhost:5000/api/auth/reset-password/${resetToken}`;
    console.log('Reset Password Link:', resetLink);

    res.json({ message: 'Password reset link sent (check console)' });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server error' });
  }
};

// ------------------------ RESET PASSWORD ------------------------
export const resetPassword = async (req, res) => {
  const { token } = req.params;
  const { newPassword } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM password_reset_tokens WHERE token = $1',
      [token]
    );

    const tokenRow = result.rows[0];

    if (!tokenRow) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    if (new Date(tokenRow.expires_at) < new Date()) {
      return res.status(400).json({ message: 'Token has expired' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await pool.query(
      'UPDATE users SET password_hash = $1 WHERE id = $2',
      [hashedPassword, tokenRow.user_id]
    );

    await pool.query(
      'DELETE FROM password_reset_tokens WHERE user_id = $1',
      [tokenRow.user_id]
    );

    res.json({ message: 'Password reset successful. You can now log in.' });

  } catch (err) {
    console.error('Error resetting password:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
};

// ------------------------ GET LOGGED IN USER ------------------------
export const getMe = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      "SELECT id, full_name, email, role, is_verified FROM users WHERE id = $1",
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("getMe error:", err.message);
    res.status(500).json({ message: "Server error" });
  }
};