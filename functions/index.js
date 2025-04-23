// functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {
  RecaptchaEnterpriseServiceClient,
} = require("@google-cloud/recaptcha-enterprise");

admin.initializeApp();

const recaptchaClient = new RecaptchaEnterpriseServiceClient();

// Replace with your reCAPTCHA Site Key and Google Cloud Project ID
const SITE_KEY = "6LcYI1MqAAAAAOknOASj0LqpK30kcUHZL6LEcgd1";
const PROJECT_ID = "tnpnitd-1e54c";

exports.verifyRecaptcha = functions.https.onCall(
    async (data, context) => {
      const token = data.token;

      if (!token) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "The function must be called with a token.",
        );
      }

      const projectPath = recaptchaClient.projectPath(PROJECT_ID);

      const request = {
        assessment: {
          event: {
            token: token,
            siteKey: SITE_KEY,
          },
        },
        parent: projectPath,
      };

      try {
        const [response] = await recaptchaClient.createAssessment(request);
        const riskAnalysis = response.riskAnalysis;

        // Define a threshold for acceptable score (e.g., 0.5)
        const scoreThreshold = 0.5;

        if (riskAnalysis.score >= scoreThreshold) {
          return {success: true};
        } else {
          return {
            success: false,
            message: "Low reCAPTCHA score detected.",
          };
        }
      } catch (error) {
        console.error("Error verifying reCAPTCHA:", error);
        throw new functions.https.HttpsError(
            "unknown",
            "Failed to verify reCAPTCHA.",
        );
      }
    },
);
