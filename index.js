import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import passport from './middlewares/passport.js';
import session from 'express-session';
import path from 'path';
import { fileURLToPath } from 'url';
import studentRoutes from "./routes/student.routes.js";
import subscriptionRoutes from "./routes/subscriptionRoutes.js";

// Routes
import authRoutes from './routes/auth.routes.js';
import topicRoutes from './routes/topics.routes.js';
import subjectRoutes from './routes/subjects.routes.js';
import groupRoutes from './routes/groups.routes.js';
import questionRoutes from './routes/questions.routes.js';
import assessmentRoutes from './routes/assessments.routes.js';
import userRoutes from './routes/users.routes.js';
import resourcesRouter from './routes/resources.routes.js';
import teacherRoutes from './routes/teacher.routes.js';
import parentRoutes from './routes/parents.js';
import parentChildrenRoutes from './routes/parent-children.js';
import qnaRouter from './routes/qna.js';
import studentDashboardRoutes from "./routes/studentDashboard.routes.js";
import paymentRoutes from "./routes/paymentRoutes.js";
import notificationsRouter from './routes/notifications.js';

// Setup
dotenv.config();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(session({
  secret: process.env.SESSION_SECRET || 'secret', // ✅ use env var
  resave: false,
  saveUninitialized: false // better default
}));
app.use(passport.initialize());
app.use(passport.session());

// Static uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/topics', topicRoutes);
app.use('/api/subjects', subjectRoutes);
app.use('/api/groups', groupRoutes);
app.use('/api/questions', questionRoutes);
app.use('/api/assessments', assessmentRoutes);
app.use('/api/users', userRoutes);
app.use('/api/resources', resourcesRouter);
app.use('/api/teacher', teacherRoutes);
app.use('/api/parents', parentRoutes);
app.use('/api/parent-children', parentChildrenRoutes);
app.use('/api/qna', qnaRouter);
app.use('/student', studentDashboardRoutes);


app.get('/dashboard', (req, res) => res.json({ message: 'Authenticated!' }));
app.get('/admin', (req, res) => res.json({ message: 'Admin route!' }));
app.use("/api/users", userRoutes);


app.use("/api/student", studentRoutes);

// Temporary debug route
app.get('/debug-env', (req, res) => {
  res.json({
    clientId: process.env.GOOGLE_CLIENT_ID ? '✅ loaded' : '❌ missing',
    clientSecret: process.env.GOOGLE_CLIENT_SECRET ? '✅ loaded' : '❌ missing',
    callbackUrl: process.env.GOOGLE_CALLBACK_URL,
    jwtSecret: process.env.JWT_SECRET ? '✅ loaded' : '❌ missing',
  });
});

app.use("/api/payments", paymentRoutes);

app.use(
    "/api/subscriptions",
    subscriptionRoutes
);

app.get("/payment/success", (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Payment Successful</title>
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
          font-family: Arial, Helvetica, sans-serif;
        }

        body {
          background: linear-gradient(135deg, #0f172a, #1e293b);
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          color: white;
        }

        .card {
          background: #fff;
          color: #333;
          padding: 40px;
          border-radius: 16px;
          text-align: center;
          max-width: 450px;
          width: 90%;
          box-shadow: 0 15px 40px rgba(0, 0, 0, 0.25);
        }

        .icon {
          width: 90px;
          height: 90px;
          background: #22c55e;
          border-radius: 50%;
          margin: 0 auto 20px;
          display: flex;
          justify-content: center;
          align-items: center;
          font-size: 48px;
          color: white;
          font-weight: bold;
        }

        h1 {
          color: #16a34a;
          margin-bottom: 15px;
        }

        p {
          color: #555;
          font-size: 16px;
          line-height: 1.7;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <div class="icon">✓</div>
        <h1>Payment Successful!</h1>
        <p>
          Thank you for your payment.<br><br>
          Your subscription has been activated successfully.
        </p>
      </div>
    </body>
    </html>
  `);
});

app.get("/payment/cancel", (req, res) => {
  res.send(`
    <h1>Payment Cancelled</h1>
    <p>Your payment was cancelled. You can return to the app and try again.</p>
  `);
});

app.use('/notifications', notificationsRouter);

const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => console.log(`✅ Server running on port ${PORT}`));
