import express from "express";

import SubscriptionController
from "../controllers/subscriptionController.js";
import { requireFeature }
from "../middlewares/subscriptionMiddleware.js";

import authenticateUser
from "../middlewares/authMiddleware.js";

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