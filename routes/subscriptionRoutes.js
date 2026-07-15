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


export default router;