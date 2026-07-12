const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin using serviceAccountKey.json
const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();

// Enable CORS and body parser
app.use(cors());
app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Endpoint to send push notification
app.post('/send-notification', async (req, res) => {
  const { token, title, body, data } = req.body;

  if (!token) {
    return res.status(400).json({ error: 'FCM token is required' });
  }
  if (!title || !body) {
    return res.status(400).json({ error: 'Title and body are required' });
  }

  try {
    // Construct message payload
    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
    };

    // Include custom data if provided
    if (data) {
      // Ensure all values in data are strings as required by Firebase Admin SDK
      const stringifiedData = {};
      for (const [key, value] of Object.entries(data)) {
        stringifiedData[key] = String(value);
      }
      message.data = stringifiedData;
    }

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return res.status(200).json({ success: true, messageId: response });
  } catch (error) {
    console.error('Error sending message:', error);
    return res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Notification server is listening on port ${PORT}`);
});

module.exports = app;