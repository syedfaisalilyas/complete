const functions = require("firebase-functions");
const stripe = require("stripe")(functions.config().stripe.secret);

// ✅ Stripe Payment Intent Function
exports.createPaymentIntent = functions.https.onRequest(async (req, res) => {
  try {
    const {amount, currency} = req.body;

    if (!amount || !currency) {
      return res.status(400).send({error: "Amount and currency are required"});
    }

    // Create Payment Intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount, // Amount in smallest currency unit (e.g. paisa for PKR)
      currency: currency,
      payment_method_types: ["card"],
    });

    res.status(200).send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    console.error("Payment Error:", error);
    res.status(500).send({error: error.message});
  }
});
