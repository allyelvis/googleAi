#!/bin/bash

# Ensure Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Firebase CLI not found. Please install it first."
    exit 1
fi

# Initialize Firebase in the current project directory (if not already initialized)
firebase init functions

# Navigate to functions directory
cd functions || { echo "Functions directory not found!"; exit 1; }

# Install necessary packages
echo "Installing @genkit-ai/googleai and Firebase functions dependencies..."
npm install @genkit-ai/googleai firebase-functions

# Prompt user for Google GenAI API key
read -p "Enter your Google GenAI API key: " GOOGLE_GENAI_API_KEY

# Securely set API key in Firebase Functions using Cloud Secret Manager
firebase functions:secrets:set GOOGLE_GENAI_API_KEY="$GOOGLE_GENAI_API_KEY"

# Create index.js file for Cloud Function
echo "Generating index.js file..."
cat << 'EOF' > index.js
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
EOF

# Confirm file creation
if [ -f index.js ]; then
    echo "index.js file created successfully."
else
    echo "Failed to create index.js file."
    exit 1
fi

# Deploy the Cloud Function
echo "Deploying Firebase Cloud Function..."
firebase deploy --only functions

# Display completion message
echo "Deployment completed! Your Cloud Function is now live."