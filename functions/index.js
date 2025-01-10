require("dotenv").config();
const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const Stripe = require("stripe");
const admin = require("firebase-admin");

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

// Initialize Stripe with the secret key
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Create Express app
const app = express();
app.use(cors());
app.use(express.json());
app.use(bodyParser.raw({ type: "application/json" }));

// Test Route
app.get("/", (req, res) => res.send({ status: "API is working!" }));

// Create or retrieve a customer
app.post("/create-customer", async (req, res) => {
  try {
    const { email, userId } = req.body;

    if (!email || !userId) {
      return res.status(400).json({ error: "Email and userId are required." });
    }

    const customerDoc = await admin
      .firestore()
      .collection("customers")
      .doc(userId)
      .get();

    if (customerDoc.exists) {
      const existingCustomer = customerDoc.data();
      return res.json({ customer: { id: existingCustomer.stripeId } });
    }

    const customer = await stripe.customers.create({ email });

    await admin.firestore().collection("customers").doc(userId).set({
      stripeId: customer.id,
      email: email,
      isPremium: false, // Default to false
    });

    res.json({ customer });
  } catch (error) {
    console.error("Error creating customer:", error.message);
    res.status(500).json({ error: "Failed to create customer." });
  }
});

// Create a Payment Intent
app.post("/create-subscription", async (req, res) => {
  try {
    const { customerId, priceId } = req.body;

    if (!customerId || !priceId) {
      console.error("Missing parameters:", { customerId, priceId });
      throw new Error("Customer ID and Price ID are required.");
    }

    console.log("Creating subscription for Customer ID:", customerId, "Price ID:", priceId);

    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"],
    });

    console.log("Subscription created successfully:", subscription);

    res.send({
      subscriptionId: subscription.id,
      clientSecret: subscription.latest_invoice.payment_intent.client_secret,
    });
  } catch (error) {
    console.error("Error creating subscription:", error.message);
    res.status(400).send({ error: error.message });
  }
});

// Webhook for Stripe events
app.post(
  "/webhook",
  bodyParser.raw({ type: "application/json" }),
  async (req, res) => {
    const sig = req.headers["stripe-signature"];
    let event;

    try {
      event = stripe.webhooks.constructEvent(
        req.body,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET
      );
    } catch (err) {
      console.error("Webhook signature verification failed:", err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    try {
      switch (event.type) {
        case "payment_intent.succeeded":
          await handlePaymentSucceeded(event.data.object);
          break;
          case "customer.subscription.updated":
            await handleSubscriptionStatusUpdate(event.data.object);
            break;
          case "customer.subscription.deleted":
            await handleSubscriptionStatusUpdate(event.data.object);
            break;
        case "charge.refunded":
          await handleChargeRefunded(event.data.object);
          break;
        default:
          console.log(`Unhandled event type: ${event.type}`);
      }
      res.json({ received: true });
    } catch (error) {
      console.error("Error processing webhook event:", error.message);
      res.status(500).send("Internal Server Error");
    }
  }
);

// Event Handlers
async function handlePaymentSucceeded(invoice) {
  const customerId = invoice.customer;

  console.log("Payment succeeded for customer:", customerId);

  const customersSnapshot = await admin
    .firestore()
    .collection("customers")
    .where("stripeId", "==", customerId)
    .get();

  if (!customersSnapshot.empty) {
    customersSnapshot.forEach(async (doc) => {
      await doc.ref.update({ isPremium: true });
    });
  }
}

async function handleSubscriptionStatusUpdate(subscription) {
  const customerId = subscription.customer;
  const status = subscription.status;

  console.log(`Subscription status for customer ${customerId}: ${status}`);

  // Determine if the user should still be premium
  const isPremium = status === "active" || status === "trialing";

  // Update Firestore
  const customersSnapshot = await admin
    .firestore()
    .collection("customers")
    .where("stripeId", "==", customerId)
    .get();

  if (!customersSnapshot.empty) {
    customersSnapshot.forEach(async (doc) => {
      await doc.ref.update({ isPremium });
      console.log(
        `Updated Firestore for customer ${customerId}: isPremium = ${isPremium}`
      );
    });
  } else {
    console.error(`No Firestore document found for customer ${customerId}`);
  }
}

async function handleChargeRefunded(refund) {
  const charge = refund.charge;
  const chargeDetails = await stripe.charges.retrieve(charge);

  if (!chargeDetails.customer) {
    console.error("Charge does not have a linked customer.");
    return;
  }

  const customerId = chargeDetails.customer;

  console.log("Charge refunded for customer:", customerId);

  // Find the Firestore document for the customer and update isPremium to false
  const customersSnapshot = await admin
    .firestore()
    .collection("customers")
    .where("stripeId", "==", customerId)
    .get();

  if (!customersSnapshot.empty) {
    customersSnapshot.forEach(async (doc) => {
      await doc.ref.update({ isPremium: false });
      console.log(`Charge refunded: Updated isPremium to false for customer: ${customerId}`);
    });
  } else {
    console.error("No Firestore document found for customer:", customerId);
  }
}

// Scheduled function to check subscription statuses
exports.checkSubscriptionStatuses = functions.https.onRequest(async (req, res) => {
  console.log("Running subscription status check...");

  try {
    const customersSnapshot = await admin.firestore().collection("customers").get();

    for (const doc of customersSnapshot.docs) {
      const customerData = doc.data();
      const stripeSubscriptionId = customerData.stripeSubscriptionId;

      if (stripeSubscriptionId) {
        const subscription = await stripe.subscriptions.retrieve(stripeSubscriptionId);
        const isPremium = subscription.status === "active" || subscription.status === "trialing";

        await doc.ref.update({ isPremium });
        console.log(`Updated isPremium for customer ${doc.id}: ${isPremium}`);
      } else {
        console.log(`No subscription ID found for customer ${doc.id}`);
      }
    }

    console.log("Subscription status check completed.");
    res.status(200).send("Subscription statuses updated successfully.");
  } catch (error) {
    console.error("Error checking subscription statuses:", error.message);
    res.status(500).send(`Error: ${error.message}`);
  }
});

// Export the API
exports.api = functions.https.onRequest(app);
