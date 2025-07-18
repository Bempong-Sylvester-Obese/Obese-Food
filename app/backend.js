const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

const vision = require('@google-cloud/vision');
const client = new vision.ImageAnnotatorClient();

// HTTP function to analyze a food image
exports.analyzeFood = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }
  
  // Expect the request body to include an imageUrl (and optionally a userId)
  const { imageUrl, userId } = req.body;
  if (!imageUrl) {
    res.status(400).send('Missing imageUrl in request body');
    return;
  }
  
  try {
    // Use Vision API to detect labels on the image
    const [result] = await client.labelDetection(imageUrl);
    const labels = result.labelAnnotations;
    
    // Optionally, save the analysis result to Firestore 
    if (userId) {
      await db.collection('foodAnalyses').add({
        userId,
        imageUrl,
        labels,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    
    // Respond with the labels from the Vision API
    res.status(200).json({ labels });
  } catch (error) {
    console.error('Error analyzing image:', error);
    res.status(500).send('Error analyzing image: ' + error.toString());
  }
});
