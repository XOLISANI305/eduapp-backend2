import crypto from "crypto";

class PayFastService {

static generateSignature(data, passphrase = "") {

  let query = "";

  for (const key in data) {

    if (
      data[key] !== null &&
      data[key] !== undefined &&
      data[key] !== ""
    ) {
      query += `${key}=${encodeURIComponent(data[key]).replace(/%20/g, "+")}&`;
    }

  }

  if (passphrase) {
    query += `passphrase=${encodeURIComponent(passphrase).replace(/%20/g, "+")}`;
  } else {
    query = query.slice(0, -1);
  }

  console.log("PayFast signature string:", query);

  return crypto.createHash("md5").update(query).digest("hex");
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

    paymentData.signature = this.generateSignature(
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

  // NOTE: verifyPayment is called in paymentController.js but not yet implemented.
  // PayFast ITN verification normally requires posting back the ITN data to
  // PayFast's validate endpoint to confirm it's legitimate. Stub added below
  // so deploy doesn't crash — replace with real verification before going live.
  static async verifyPayment(data) {
    console.warn("PayFastService.verifyPayment is a stub — implement real ITN validation before production use.");
    return true;
  }

}

export default PayFastService;