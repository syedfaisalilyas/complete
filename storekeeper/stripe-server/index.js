const express = require("express");
const app = express();
const stripe = require("stripe")("sk_test_51S4FOSGoeDUTZbmFWbMyErT9o21nkDOBPWxCZJzD7lOoMxcDzi4xABqxY8nwyiwrTrUmL01QHFsuFckPVypEzaBA00BwTqssJI"); // Replace with your Stripe Secret Key
app.use(express.json());

app.post("/create-payment-intent", async (req, res) => {
  const { amount } = req.body; // Amount in cents
  const paymentIntent = await stripe.paymentIntents.create({
    amount,
    currency: "usd",
  });
  res.send({ clientSecret: paymentIntent.client_secret });
});

app.listen(3000, () => console.log("Server running on port 3000"));
