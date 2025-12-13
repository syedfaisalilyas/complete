const functions = require("firebase-functions");
const sgMail = require("@sendgrid/mail");

sgMail.setApiKey(functions.config().sendgrid.key);

exports.sendInvoiceEmail = functions.https.onCall(async (data, context) => {
    const msg = {
        to: data.to,
        from: "universal-tools@app.com",
        subject: `Your Invoice #${data.invoiceId}`,
        text: `Thank you! Your order ${data.orderId} has been placed.`,
        html: `
            <h2>Invoice: ${data.invoiceId}</h2>
            <p><strong>Order ID:</strong> ${data.orderId}</p>
            <p><strong>Total Amount:</strong> ${data.amount} OMR</p>
            <p>Thank you for shopping with us!</p>
        `,
    };

    try {
        await sgMail.send(msg);
        return { success: true };
    } catch (error) {
        console.error(error);
        return { success: false, error: error.message };
    }
});
