const express = require('express');
const stripe = require('stripe')('your_stripe_secret_key');
const app = express();

app.use(express.json());

app.post('/create-checkout-session', async (req, res) => {
  const { planId } = req.body;

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price: planId,
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: 'https://your-app.com/success',
      cancel_url: 'https://your-app.com/cancel',
    });

    res.json({ checkoutUrl: session.url });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.listen(4242, () => console.log('Server running on port 4242'));
