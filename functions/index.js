const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Cloud function to create a new user
exports.createUser = functions.https.onCall((data, context) => {
  // Check if the request is made by an authenticated user
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Only authenticated users can create users.",
    );
  }

  // Optional: Check if the user has admin privileges
  if (context.auth.token.admin !== true) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can create users.",
    );
  }

  // Create the new user with the provided email and password
  return admin.auth().createUser({
    email: data.email,
    password: data.password,
  })
      .then((userRecord) => {
        return {uid: userRecord.uid, email: userRecord.email};
      })
      .catch((error) => {
        throw new functions.https.HttpsError("internal", error.message);
      });
});
