import Subscription from "../models/subscriptionModel.js";
import SubscriptionService from "../services/subscriptionService.js";

class SubscriptionController {

    // GET /api/subscriptions/plans
    static async getPlans(req, res) {
        try {
            const plans = await Subscription.getPlans();

            return res.status(200).json({
                success: true,
                data: plans
            });

        } catch (error) {
            console.error("Get Plans Error:", error);

            return res.status(500).json({
                success: false,
                message: "Failed to fetch subscription plans."
            });
        }
    }

    // GET /api/subscriptions/me
    static async getMySubscription(req, res) {
        try {
            const userId = req.user.id;

            const subscription =
                await SubscriptionService.getCurrentSubscription(userId);

            return res.status(200).json({
                success: true,
                data: subscription
            });

        } catch (error) {
            console.error("Get Subscription Error:", error);

            return res.status(500).json({
                success: false,
                message: "Failed to fetch subscription."
            });
        }
    }

    // POST /api/subscriptions/mock
    static async mockSubscribe(req, res) {
        try {

            const userId = req.user.id;
            const { planId } = req.body;

            if (!planId) {
                return res.status(400).json({
                    success: false,
                    message: "Plan ID is required."
                });
            }

            // Check if plan exists
            const plan = await Subscription.getPlanById(planId);

            if (!plan) {
                return res.status(404).json({
                    success: false,
                    message: "Subscription plan not found."
                });
            }

            // Calculate expiry
            const expiresAt = new Date();
            expiresAt.setDate(
                expiresAt.getDate() + plan.duration_days
            );

            // Generate one transaction reference
            const transactionReference = `MOCK-${Date.now()}`;

            // Create or update subscription
            const subscription =
                await Subscription.upsertSubscription({
                    userId,
                    planId,
                    expiresAt,
                    paymentProvider: "MOCK",
                    paymentReference: transactionReference
                });

            // Save payment history
            await Subscription.createPayment({
                userId,
                subscriptionId: subscription.id,
                amount: plan.price,
                paymentProvider: "MOCK",
                transactionReference,
                status: "SUCCESS"
            });

            return res.status(200).json({
                success: true,
                message: `${plan.name} subscription activated successfully.`,
                data: subscription
            });

        } catch (error) {
            console.error("Mock Subscription Error:", error);

            return res.status(500).json({
                success: false,
                message: "Failed to activate subscription."
            });
        }
    }

}

export default SubscriptionController;