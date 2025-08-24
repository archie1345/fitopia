const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Stripe = require("stripe");

// Define secret
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
const CLIENT_ID = defineSecret("CLIENT_ID");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

// Init Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const app = express();

app.use(cors({ origin: true }));
app.use(express.json());
app.use(bodyParser.raw({ type: "application/json" }));

// Middleware: Authenticate via Firebase ID Token
const authenticateFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing or invalid Authorization header" });
    }

    const idToken = authHeader.split(" ")[1];

    // Verify the Firebase ID token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    req.user = { uid: decodedToken.uid, email: decodedToken.email };
    next();
  } catch (err) {
    console.error("Firebase ID token verification failed:", err.message);
    return res.status(401).json({ error: "Unauthorized" });
  }
};


// Health check
app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

app.post("/webhook", async (req, res) => {
  const sig = req.headers["stripe-signature"];
  const stripeSecret = await STRIPE_WEBHOOK_SECRET.value();

  let event;

  try {
    const stripeSecretKey = await STRIPE_SECRET_KEY.value();
    const stripe = new Stripe(stripeSecretKey, {
      apiVersion: "2025-08-01",
    });

    event = stripe.webhooks.constructEvent(req.body, sig, stripeSecret);
  } catch (err) {
    console.error("Webhook signature verification failed.", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    switch (event.type) {
      case "customer.created": {
        const customer = event.data.object;

        // Save customer info to Firestore
        await db.collection("customers").doc(customer.metadata.appUserId || customer.id).set({
          stripeId: customer.id,
          email: customer.email || null,
          username: customer.name || null,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log("Customer saved to Firestore:", customer.id);
        break;
      }

      case "customer.updated": {
        const customer = event.data.object;

        await db.collection("customers").doc(customer.metadata.appUserId || customer.id).set({
          email: customer.email || null,
          username: customer.name || null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log("Customer updated in Firestore:", customer.id);
        break;
      }

      case "customer.subscription.created":
      case "customer.subscription.updated": {
        const subscription = event.data.object;

        await db.collection("subscriptions").doc(subscription.id).set({
          stripeId: subscription.id,
          customerId: subscription.customer,
          status: subscription.status,
          priceId: subscription.items.data[0].price.id,
          currentPeriodEnd: subscription.current_period_end,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log("Subscription saved/updated in Firestore:", subscription.id);
        break;
      }

      case "invoice.payment_succeeded": {
        const invoice = event.data.object;

        console.log("Invoice payment succeeded:", invoice.id);
        // You can optionally update invoice/payment records in Firestore
        break;
      }

      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    res.status(200).send("Webhook received");
  } catch (err) {
    console.error("Error handling webhook:", err);
    res.status(500).send("Internal Server Error");
  }
});


// Create Stripe Customer
app.post("/create-customer", authenticateFirebaseToken, async (req, res) => {
  try {
    const stripe = Stripe(STRIPE_SECRET_KEY.value());
    const { email, username } = req.body;
    const userId = req.user.uid;

    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    console.log(`Creating customer for UID=${userId}, email=${email}`);

    // Create the Stripe customer
    const customer = await stripe.customers.create({
      name: username || userId,
      email: email,
      metadata: { appUserId: userId }, // optional extra info
    });

    // Save the Stripe customer ID to Firestore
    await db.collection("customers").doc(userId).set({
      stripeId: customer.id,
      email,
      username: username || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    res.status(200).json({ customerId: customer.id });
  } catch (error) {
    console.error("Error creating Stripe customer:", error);
    res.status(500).json({ error: error.message });
  }
});


// Create Stripe Subscription
app.post("/create-subscription", authenticateFirebaseToken, async (req, res) => {
  try {
    const stripe = Stripe(STRIPE_SECRET_KEY.value());
    const { priceId } = req.body;
    const userId = req.user.uid; // Correctly get the UID from the token

    if (!priceId) {
      return res.status(400).json({ error: "priceId is required" });
    }

    // Get or create customerId
    let customerDoc = await db.collection("customers").doc(userId).get();
    let customerId;

    if (!customerDoc.exists || !customerDoc.data().stripeId) {
      // Create Stripe customer since it doesn't exist
      const user = req.user;
      const customer = await stripe.customers.create({
        name: user.email, // Or use user.name from the payload
        email: user.email,
        metadata: { appUserId: userId },
      });
      customerId = customer.id;

      // Save the new Stripe customer ID to Firestore
      await db.collection("customers").doc(userId).set({
        stripeId: customer.id,
        email: user.email,
        username: user.email, // Or user.name
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      console.log(`Created new Stripe customer for UID=${userId}`);
    } else {
      customerId = customerDoc.data().stripeId;
      console.log(`Using existing Stripe customer for UID=${userId}`);
    }

    console.log(`Creating subscription for customer=${customerId}, price=${priceId}`);

    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"],
    });

    res.status(200).json({
      subscriptionId: subscription.id,
      clientSecret: subscription.latest_invoice.payment_intent.client_secret,
    });
  } catch (error) {
    console.error("Error creating subscription:", error);
    res.status(400).json({ error: error.message });
  }
});

// Export the API to Firebase Cloud Functions
exports.api = onRequest({ secrets: [STRIPE_SECRET_KEY,CLIENT_ID,STRIPE_WEBHOOK_SECRET] }, app);
// exports.api = functions.https.onRequest(app);
