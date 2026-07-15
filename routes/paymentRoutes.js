import express from "express";
import {
  createPayFastPayment,
  payfastNotify,
  paymentSuccess,
  paymentCancel
} from "../controllers/paymentController.js";

import { requireAuth } from "../middlewares/auth.middleware.js";

const router = express.Router();

// Create payment (User must be logged in)
router.post(
  "/payfast/create",
  requireAuth,
  createPayFastPayment
);

// PayFast ITN (Do NOT protect this route)
router.post(
  "/payfast/notify",
  payfastNotify
);

// Return URL
router.get(
  "/payfast/success",
  paymentSuccess
);

// Cancel URL
router.get(
  "/payfast/cancel",
  paymentCancel
);

export default router;