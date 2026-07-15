import SubscriptionService from "../services/subscriptionService.js";

export const requireFeature = (feature) => {
    return async (req, res, next) => {

        try {

            const userId = req.user.id;

            let allowed = false;

            switch (feature) {

                case "downloads":
                    allowed = await SubscriptionService.canDownload(userId);
                    break;

                case "videos":
                    const videoLimit =
                        await SubscriptionService.getVideoLimit(userId);

                    allowed = videoLimit === null;
                    break;

                case "quizzes":
                    const quizLimit =
                        await SubscriptionService.getQuizLimit(userId);

                    allowed = quizLimit === null;
                    break;

                case "subjects":
                    const subjectLimit =
                        await SubscriptionService.getSubjectLimit(userId);

                    allowed = subjectLimit === null;
                    break;

                case "ai":
                    allowed = await SubscriptionService.canUseAI(userId);
                    break;

                default:
                    allowed = false;
            }

            if (!allowed) {
                return res.status(403).json({
                    success: false,
                    message:
                        "This feature requires an EduApp Premium subscription."
                });
            }

            next();

        } catch (error) {

            console.error(error);

            return res.status(500).json({
                success: false,
                message: "Subscription verification failed."
            });

        }

    };
};