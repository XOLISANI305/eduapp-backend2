import crypto from "crypto";
import PayFastService from "../services/payfastService.js";
import Payment from "../models/paymentModel.js";
import Subscription from "../models/subscriptionModel.js";

class PayFastService {

  static generateSignature(data, passphrase = "") {

    const sorted = Object.keys(data)
      .sort()
      .reduce((obj, key) => {
        obj[key] = data[key];
        return obj;
      }, {});

    let query = "";

    for (const key in sorted) {

      if (
        sorted[key] !== null &&
        sorted[key] !== undefined &&
        sorted[key] !== ""
      ) {

        query +=
          `${key}=${encodeURIComponent(sorted[key]).replace(/%20/g, "+")}&`;

      }

    }

    if (passphrase) {

      query +=
        `passphrase=${encodeURIComponent(passphrase).replace(/%20/g, "+")}`;

    } else {

      query = query.slice(0, -1);

    }

    return crypto
      .createHash("md5")
      .update(query)
      .digest("hex");

  }

  static createPayment(data) {

    const paymentData = {

      merchant_id: process.env.PAYFAST_MERCHANT_ID,

      merchant_key: process.env.PAYFAST_MERCHANT_KEY,

      return_url: process.env.PAYFAST_RETURN_URL,

      cancel_url: process.env.PAYFAST_CANCEL_URL,

      notify_url: process.env.PAYFAST_NOTIFY_URL,

      name_first: data.name,

      email_address: data.email,

      m_payment_id: data.paymentId,

      amount: Number(data.amount).toFixed(2),

      item_name: data.planName

    };

    paymentData.signature =
      this.generateSignature(
        paymentData,
        process.env.PAYFAST_PASSPHRASE
      );

    const baseUrl =
      process.env.PAYFAST_SANDBOX === "true"
        ? "https://sandbox.payfast.co.za/eng/process"
        : "https://www.payfast.co.za/eng/process";

    const params = new URLSearchParams(paymentData);

    return `${baseUrl}?${params.toString()}`;

  }

}

export const payfastNotify = async (req, res) => {

  try {

    // Verify with PayFast
    const valid = await PayFastService.verifyPayment(req.body);

    if (!valid) {
      return res.status(400).send("INVALID ITN");
    }

    const paymentId = req.body.m_payment_id;
    const payfastReference = req.body.pf_payment_id;

    const payment = await Payment.getById(paymentId);

    if (!payment) {
      return res.status(404).send("Payment not found");
    }

    // Prevent duplicate processing
    if (payment.payment_status === "completed") {
      return res.status(200).send("Already processed");
    }

    // Mark payment complete
    await Payment.markCompleted(
      paymentId,
      payfastReference
    );

    // Load subscription plan
    const plan = await Subscription.getPlanById(
      payment.plan_id
    );

    let expiresAt = null;

    if (plan.duration_days) {

      expiresAt = new Date();

      expiresAt.setDate(
        expiresAt.getDate() + plan.duration_days
      );

    }

    // Activate subscription
    await Subscription.upsertSubscription({

      userId: payment.user_id,

      planId: payment.plan_id,

      expiresAt,

      paymentProvider: "PAYFAST",

      paymentReference: payfastReference

    });

    return res.status(200).send("OK");

  } catch (error) {

    console.error("PayFast ITN Error:", error);

    return res.status(500).send("ERROR");

  }

};

export default PayFastService;