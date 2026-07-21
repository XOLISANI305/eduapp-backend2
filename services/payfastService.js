import crypto from "crypto";

class PayFastService {

  // Replicates PHP's urlencode() exactly, since PayFast recomputes
  // signatures using PHP on their backend. JS's encodeURIComponent
  // differs from PHP's urlencode for: ! * ' ( ) ~
  static phpUrlEncode(str) {
    return encodeURIComponent(String(str).trim())
      .replace(/%20/g, "+")
      .replace(/!/g, "%21")
      .replace(/'/g, "%27")
      .replace(/\(/g, "%28")
      .replace(/\)/g, "%29")
      .replace(/\*/g, "%2A")
      .replace(/~/g, "%7E");
  }

  static generateSignature(data, passphrase = "") {

    let query = "";

    for (const key in data) {
      if (
        data[key] !== null &&
        data[key] !== undefined &&
        data[key] !== ""
      ) {
        query += `${key}=${this.phpUrlEncode(data[key])}&`;
      }
    }

    if (passphrase) {
      query += `passphrase=${this.phpUrlEncode(passphrase)}`;
    } else {
      query = query.slice(0, -1);
    }

    console.log("PayFast signature string:", query);

    return crypto.createHash("md5").update(query).digest("hex");
  }

  static createPayment(data) {

    const paymentData = {
      merchant_id: process.env.PAYFAST_MERCHANT_ID?.trim(),
      merchant_key: process.env.PAYFAST_MERCHANT_KEY?.trim(),
      return_url: process.env.PAYFAST_RETURN_URL?.trim(),
      cancel_url: process.env.PAYFAST_CANCEL_URL?.trim(),
      notify_url: process.env.PAYFAST_NOTIFY_URL?.trim(),
      name_first: data.name,
      email_address: data.email,
      m_payment_id: data.paymentId,
      amount: Number(data.amount).toFixed(2),
      item_name: data.planName
    };
console.log("DEBUG passphrase set?", Boolean(process.env.PAYFAST_PASSPHRASE), JSON.stringify(process.env.PAYFAST_PASSPHRASE));
    paymentData.signature = this.generateSignature(
      paymentData,
      process.env.PAYFAST_PASSPHRASE?.trim() || ""
    );

    const baseUrl =
      process.env.PAYFAST_SANDBOX === "true"
        ? "https://sandbox.payfast.co.za/eng/process"
        : "https://www.payfast.co.za/eng/process";

    // Build query string manually using the SAME phpUrlEncode used for
    // the signature, instead of URLSearchParams (which uses a different
    // encoding algorithm and could reintroduce a mismatch).
 const queryString = Object.keys(paymentData)
  .filter((key) => paymentData[key] !== null && paymentData[key] !== undefined && paymentData[key] !== "")
  .map((key) => `${key}=${this.phpUrlEncode(paymentData[key])}`)
  .join("&");

const url = `${baseUrl}?${queryString}`;

console.log("PayFast URL:");
console.log(url);

return url;
  }

  static async verifyPayment(data) {
    console.warn("PayFastService.verifyPayment is a stub — implement real ITN validation before production use.");
    return true;
  }

}

export default PayFastService;