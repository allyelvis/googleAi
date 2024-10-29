const { onFlow } = require('@genkit-ai/googleai');
const functions = require('firebase-functions');
const { gemini } = require('@genkit-ai/googleai'); // Import Gemini API from Genkit

// Cloud Function for text generation using Gemini
exports.generateText = functions.https.onCall(async (data, context) => {
  const flow = onFlow({
    name: 'generateTextFlow',
    httpsOptions: {
      secrets: ['GOOGLE_GENAI_API_KEY'],
      cors: true,
    },
  }, async (subject) => {
    const response = await gemini.generateText({
      text: subject,
      temperature: 0.7,
      max_tokens: 100,
    });
    return response;
  });

  return flow(data.text);
});
