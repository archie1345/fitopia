// const functions = require("firebase-functions");
// const express = require("express");
// const cors = require("cors");
// const Stripe = require("stripe");

// const app = express();
// const stripe = new Stripe(functions.config().stripe.secret);

// app.use(cors({ origin: true }));
// app.use(express.json());

// // Test Route
// app.get("/", (req, res) => {
//   res.send("API is working!");
// });

// // New function to create a Stripe customer
// app.post("/create-customer", async (req, res) => {
//   try {
//     const { email, userId } = req.body;
//     const customer = await stripe.customers.create({
//       email,
//       metadata: { userId },
//     });

//     // Save to Firestore
//     const admin = require("firebase-admin");
//     if (!admin.apps.length) {
//       admin.initializeApp();
//     }

//     const db = admin.firestore();
//     await db.collection("users").doc(userId).set(
//       {
//         stripeCustomerId: customer.id,
//         email: email,
//       },
//       { merge: true }
//     );

//     // Send back full customer object but with id accessible
//     res.status(200).send({
//       customer,           // full Stripe customer object
//       customerId: customer.id,  // easy access for Flutter
//     });

//   } catch (error) {
//     console.error("Error creating Stripe customer:", error.message);
//     res.status(500).send({ error: error.message });
//   }
// });


// // Create Subscription Route
// app.post("/create-subscription", async (req, res) => {
//   try {
//     const { customerId } = req.body;

//     if (!customerId) {
//       throw new Error("CustomerId is required");
//     }

//     const subscription = await stripe.subscriptions.create({
//       customer: customerId,
//       items: [{ price: "price_1QeiMHR3km1Wsl68wd7wO6lh" }],
//       payment_behavior: "default_incomplete",
//       expand: ["latest_invoice.payment_intent"],
//     });

//     res.status(200).send({
//       subscriptionId: subscription.id,
//       clientSecret: subscription.latest_invoice.payment_intent.client_secret,
//     });
//   } catch (error) {
//     console.error("Error creating subscription:", error.message);
//     res.status(400).send({ error: error.message });
//   }
// });

// exports.api = functions.https.onRequest(app);
