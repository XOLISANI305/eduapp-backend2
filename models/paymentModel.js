import db from "./db.js";

class Payment {

  static async create({
    user_id,
    subscription_id,
    amount,
    currency = "ZAR",
    payment_provider = "PAYFAST"
  }) {

    const result = await db.query(
      `
      INSERT INTO payments
      (
        user_id,
        subscription_id,
        amount,
        currency,
        payment_provider,
        status
      )
      VALUES
      (
        $1,$2,$3,$4,$5,'pending'
      )
      RETURNING *
      `,
      [
        user_id,
        subscription_id,
        amount,
        currency,
        payment_provider
      ]
    );

    return result.rows[0];

  }

  static async getById(id) {

    const result = await db.query(
      `
      SELECT *
      FROM payments
      WHERE id=$1
      `,
      [id]
    );

    return result.rows[0];

  }

  static async activate(subscriptionId, paymentReference) {

    const result = await db.query(
        `
        UPDATE subscriptions
        SET
            status = 'ACTIVE',
            payment_reference = $2,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
        RETURNING *;
        `,
        [subscriptionId, paymentReference]
    );

    return result.rows[0];
}

  static async markCompleted(id, reference) {

    const result = await db.query(
      `
      UPDATE payments

      SET

        status='completed',

        transaction_reference=$2,

        paid_at=NOW()

      WHERE id=$1

      RETURNING *
      `,
      [id, reference]
    );

    return result.rows[0];

  }

}

export default Payment;