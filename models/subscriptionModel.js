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