import db from "./db.js";

class Subscription {

  // Get all available plans
  static async getPlans() {
    const result = await db.query(
      `SELECT *
       FROM subscription_plans
       WHERE is_active = TRUE
       ORDER BY price ASC`
    );

    return result.rows;
  }

  // Get one plan
  static async getPlanById(id) {
    const result = await db.query(
      `SELECT *
       FROM subscription_plans
       WHERE id = $1`,
      [id]
    );

    return result.rows[0];
  }

 static async getUserSubscription(userId) {

    const result = await db.query(
        `
        SELECT
            s.id,
            s.user_id,
            s.plan_id,
            s.status,
            s.payment_provider,
            s.payment_reference,
            s.starts_at,
            s.expires_at,

            p.name,
            p.price,
            p.subject_limit,
            p.quiz_limit,
            p.video_limit,
            p.downloads_enabled,
            p.ai_tutor_enabled

        FROM subscriptions s

        JOIN subscription_plans p
            ON s.plan_id = p.id

        WHERE s.user_id = $1

        LIMIT 1
        `,
        [userId]
    );

    return result.rows[0];
}

// Create or update a user's subscription (used by PayFast ITN handler)
  static async upsertSubscription({
    userId,
    planId,
    expiresAt,
    paymentProvider,
    paymentReference
  }) {

    const existing = await db.query(
      `SELECT id FROM subscriptions WHERE user_id = $1 LIMIT 1`,
      [userId]
    );

    if (existing.rows.length > 0) {

      const result = await db.query(
        `
        UPDATE subscriptions
        SET
          plan_id = $2,
          status = 'ACTIVE',
          payment_provider = $3,
          payment_reference = $4,
          starts_at = CURRENT_TIMESTAMP,
          expires_at = $5,
          updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $1
        RETURNING *
        `,
        [userId, planId, paymentProvider, paymentReference, expiresAt]
      );

      return result.rows[0];

    } else {

      const result = await db.query(
        `
        INSERT INTO subscriptions
          (user_id, plan_id, status, payment_provider, payment_reference, starts_at, expires_at)
        VALUES
          ($1, $2, 'ACTIVE', $3, $4, CURRENT_TIMESTAMP, $5)
        RETURNING *
        `,
        [userId, planId, paymentProvider, paymentReference, expiresAt]
      );

      return result.rows[0];

    }

  }

  // Cancel subscription
  static async cancelSubscription(subscriptionId) {

    const result = await db.query(
      `
      UPDATE subscriptions

      SET
          status='CANCELLED',
          updated_at=CURRENT_TIMESTAMP

      WHERE id=$1

      RETURNING *
      `,
      [subscriptionId]
    );

    return result.rows[0];
  }

}

export default Subscription;