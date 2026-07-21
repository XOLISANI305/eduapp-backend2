import express from "express";
import { downloadResource, streamVideo } from "../controllers/resources.controller.js";
import { askTutor } from "../controllers/aiTutorController.js";
import SubscriptionController from "../controllers/subscriptionController.js";
import { requireAuth as authenticateUser } from "../middlewares/auth.middleware.js";
import { requireFeature } from "../middlewares/subscriptionMiddleware.js";

const router = express.Router();

router.get(
    "/plans",
    SubscriptionController.getPlans
);

router.get(
    "/me",
    authenticateUser,
    SubscriptionController.getMySubscription
);

router.post(
    "/mock",
    authenticateUser,
    SubscriptionController.mockSubscribe
);

router.get(
    "/download/:id",
    authenticateUser,
    requireFeature("downloads"),
    downloadResource
);

router.get(
    "/videos/:id",

    authenticateUser,

    requireFeature("videos"),

    streamVideo
);

router.post(
    "/ai/chat",

    authenticateUser,

    requireFeature("ai"),

    askTutor
);

// in your routes file, e.g. paymentRoutes.js
router.get("/payment/success", (req, res) => {
  res.send("Payment successful! Thank you for your purchase.");
  // or render a proper success page:
  // res.render("payment-success");
  // or redirect to your frontend app's success page if this is an API-only backend:
  // res.redirect("https://your-frontend-app.com/payment-success");
});

router.get("/payment/cancel", (req, res) => {
  res.send("Payment was cancelled.");
});

export default router;