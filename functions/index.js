const express = require("express");
const bodyParser = require("body-parser");
const stripe = require("stripe")("sk_test_YourSecretKey");

const app = express();
app.use(bodyParser.json());
app.use(express.static("public"));

// Create a PaymentIntent
app.post("/create-payment-intent", async (req, res) => {
  const { amount, currency } = req.body;

  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount, // Amount in cents
    currency: currency, // E.g., 'usd'
    automatic_payment_methods: { enabled: true },
  });

  res.send({
    clientSecret: paymentIntent.client_secret,
  });
});

// Serve an HTML page with Payment Elements
app.get("/payment-page", (req, res) => {
  res.sendFile(__dirname + "/payment.html");
});

app.listen(4242, () => console.log("Server running on http://localhost:4242"));
