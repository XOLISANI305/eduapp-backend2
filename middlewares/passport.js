import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import pool from '../models/db.js'; // Postgres connection
import dotenv from 'dotenv';
dotenv.config();

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: process.env.GOOGLE_CALLBACK_URL,
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        const email = profile.emails[0].value;
        const full_name = profile.displayName;

        // Check if user exists
        const userQuery = await pool.query('SELECT * FROM users WHERE email=$1', [email]);
        let user = userQuery.rows[0];

        if (!user) {
          // Create user if not exists
          const role = 'student'; // default role
          const newUser = await pool.query(
            'INSERT INTO users (full_name, email, role) VALUES ($1, $2, $3) RETURNING *',
            [full_name, email, role]
          );
          user = newUser.rows[0];
        }

        done(null, user);
      } catch (err) {
        done(err, null);
      }
    }
  )
);

export default passport;
