import Subscription from "../models/subscriptionModel.js";

class SubscriptionService {

  // Return the current subscription.
  // If the user has never subscribed, return the Free plan.
  static async getCurrentSubscription(userId) {

    const subscription = await Subscription.getUserSubscription(userId);

    if (!subscription) {
      const freePlan = await Subscription.getPlanById(1);

      return {
        status: "ACTIVE",
        plan: freePlan,
        expires_at: null
      };
    }

    return subscription;
  }

  // Check whether the subscription has expired.
  static async isSubscriptionActive(userId) {

    const subscription = await this.getCurrentSubscription(userId);

    if (!subscription.expires_at) {
      return true; // Free plan
    }

    return new Date(subscription.expires_at) > new Date();
  }

  // Check whether downloads are allowed.
  static async canDownload(userId) {

    const subscription = await this.getCurrentSubscription(userId);

    if (subscription.plan) {
      return subscription.plan.downloads_enabled;
    }

    return subscription.downloads_enabled;
  }

  // Check whether AI Tutor is enabled.
  static async canUseAI(userId) {

    const subscription = await this.getCurrentSubscription(userId);

    if (subscription.plan) {
      return subscription.plan.ai_tutor_enabled;
    }

    return subscription.ai_tutor_enabled;
  }

  // Subject limit.
  // Returns null for unlimited.
  static async getSubjectLimit(userId) {

    const subscription = await this.getCurrentSubscription(userId);

    if (subscription.plan) {
      return subscription.plan.subject_limit;
    }

    return subscription.subject_limit;
  }

  // Quiz limit.
  static async getQuizLimit(userId) {

    const subscription = await this.getCurrentSubscription(userId);

    if (subscription.plan) {
      return subscription.plan.quiz_limit;
    }

    return subscription.quiz_limit;
  }

  // Video limit.
  static async getVideoLimit(userId) {

    const subscription = await this.getCurrentSubscription(userId);

    if (subscription.plan) {
      return subscription.plan.video_limit;
    }

    return subscription.video_limit;
  }

}

export default SubscriptionService;