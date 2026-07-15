import db from "./db.js";

class User {

  // Get user by ID
  static async getById(userId) {

    const result = await db.query(
      `
      SELECT
        id,
        full_name,
        email,
        role,
        is_verified
      FROM users
      WHERE id = $1
      LIMIT 1
      `,
      [userId]
    );

    return result.rows[0];
  }

  // Get user by email
  static async getByEmail(email) {

    const result = await db.query(
      `
      SELECT *
      FROM users
      WHERE email = $1
      LIMIT 1
      `,
      [email]
    );

    return result.rows[0];
  }

}

export default User;