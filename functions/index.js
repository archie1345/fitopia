require("dotenv").config();
const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const Stripe = require("stripe");
const admin = require("firebase-admin");

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

// Initialize Stripe with environment variable
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Create Express app
const app = express();
app.use(cors());
app.use(express.json());

// Test Route
app.get("/", (req, res) => res.send("API is working!"));

// Create or retrieve a customer
app.post("/create-customer", async (req, res) => {
  try {
    const { email, userId } = req.body;

    if (!email || !userId) {
      throw new Error("Email and userId are required.");
    }

    // Check if customer exists in Firestore
    const customerDoc = await admin.firestore().collection("customers").doc(userId).get();
    if (customerDoc.exists) {
      const existingCustomer = customerDoc.data();
      return res.send({ customer: { id: existingCustomer.stripeId } });
    }

    // Create a new Stripe customer
    const customer = await stripe.customers.create({ email });

    // Save the new customer to Firestore
    await admin.firestore().collection("customers").doc(userId).set({
      stripeId: customer.id,
      email: email,
      isPremium: false, // Default to false
    });

    res.send({ customer });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

// Create a subscription
app.post("/create-subscription", async (req, res) => {
  try {
    const { customerId, priceId } = req.body;

    if (!customerId || !priceId) {
      throw new Error("Customer ID and Price ID are required.");
    }

    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"],
    });

    res.send({
      subscriptionId: subscription.id,
      clientSecret: subscription.latest_invoice.payment_intent.client_secret,
    });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

// Export the API
exports.api = functions.https.onRequest(app);
