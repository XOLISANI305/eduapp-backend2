import Payment from "../models/paymentModel.js";
import Subscription from "../models/subscriptionModel.js";
import PayFastService from "../services/payfastService.js";
import User from "../models/userModel.js";

// -----------------------------------------------------
// CREATE PAYFAST PAYMENT
// -----------------------------------------------------
export const createPayFastPayment = async (req, res) => {

  try {

    const userId = req.user.id;
    const { plan_id } = req.body;

    // Get user
    const user = await User.getById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found."
      });
    }

    // Get selected plan
    const plan = await Subscription.getPlanById(plan_id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: "Subscription plan not found."
      });
    }

    // Calculate expiry
    let expiresAt = new Date();

    if (plan.duration_days) {
      expiresAt.setDate(
        expiresAt.getDate() + plan.duration_days
      );
    }

    // Create/update subscription
    const subscription = await Subscription.upsertSubscription({

      userId,

      planId: plan.id,

      expiresAt,

      paymentProvider: "PAYFAST"

    });

    // Create payment linked to subscription
    const payment = await Payment.create({

      user_id: user.id,

      subscription_id: subscription.id,

      amount: plan.price,

      payment_provider: "PAYFAST"

    });

    // Generate PayFast URL
    const paymentUrl = PayFastService.createPayment({

      paymentId: payment.id,

      amount: plan.price,

      planName: plan.name,

      name: user.full_name,

      email: user.email

    });

    return res.json({

      success: true,

      payment_url: paymentUrl,

      payment

    });

  } catch (error) {

    console.error("Create PayFast Payment Error:", error);

    return res.status(500).json({

      success: false,

      message: "Unable to create payment."

    });

  }

};

// -----------------------------------------------------
// PAYFAST ITN
// -----------------------------------------------------
export const payfastNotify = async (req, res) => {

  try {

    const valid =
      await PayFastService.verifyPayment(req.body);

    if (!valid) {

      return res.status(400).send("INVALID ITN");

    }

    const paymentId = req.body.m_payment_id;

    const payfastReference = req.body.pf_payment_id;

    const payment = await Payment.getById(paymentId);

    if (!payment) {

      return res.status(404).send("Payment not found");

    }

    if (payment.status === "completed") {

      return res.status(200).send("Already processed");

    }

    // Mark payment complete
    await Payment.markCompleted(

      payment.id,

      payfastReference

    );

    // Activate subscription
    await Subscription.activate(

      payment.subscription_id,

      payfastReference

    );

    return res.status(200).send("OK");

  } catch (error) {

    console.error("PayFast ITN Error:", error);

    return res.status(500).send("ERROR");

  }

};

// -----------------------------------------------------
// RETURN URL
// -----------------------------------------------------
export const paymentSuccess = async (req, res) => {

  return res.json({

    success: true,

    message: "Payment completed successfully."

  });

};

// -----------------------------------------------------
// CANCEL URL
// -----------------------------------------------------
export const paymentCancel = async (req, res) => {

  return res.json({

    success: false,

    message: "Payment cancelled."

  });

};