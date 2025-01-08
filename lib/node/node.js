const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const Stripe = require("stripe");

const app = express();
const stripe = new Stripe(functions.config().stripe.secret); // Ensure this is set in Firebase config

app.use(cors());
app.use(express.json());

// Test Route
app.get("/", (req, res) => {
  res.send("API is working!");
});

// Create Subscription Route
app.post("/create-subscription", async (req, res) => {
  try {
    const { customerId } = req.body;

    if (!customerId) {
      throw new Error("CustomerId is required");
    }

    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: "price_1QeiMHR3km1Wsl68wd7wO6lh" }],
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"],
    });

    res.status(200).send({
      subscriptionId: subscription.id,
      clientSecret: subscription.latest_invoice.payment_intent.client_secret,
    });
  } catch (error) {
    console.error("Error creating subscription:", error.message);
    res.status(400).send({ error: error.message });
  }
});

exports.api = functions.https.onRequest(app);
