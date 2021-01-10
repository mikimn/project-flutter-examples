import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { messaging } from 'firebase-admin';

var serviceAccount = require('../service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://hellome-476c3.firebaseio.com'
});

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const updateUser = functions.firestore
    .document('users/{userId}')
    .onWrite((change, context) => {
        if (!change.after.exists) {
            // Ignore delete operations
            return;
        }
        // Get an object representing the document
        // e.g. {'first_name': 'John', 'last_name': 'Smith'}
        const newValue = change.after.data();
        console.log(`Updating the full name for user with ID 
        ${context.params.userId}`);

        // Mutate based on the previous fields
        const fullName = `${newValue?.first_name} ${newValue?.last_name}`;

        // Update the full_name field (Without touching first_name and last_name)
        return change.after.ref.set({
            'full_name': fullName,
        }, { 
            merge: true
        });
    });


export const sendBroadcastNotification = functions.https
    .onRequest(async (req, res) => {
        if (req.method !== 'POST') {
            // Handle only POST requests
            return;
        }
        const title = req.body.title;
        const body = req.body.message;
        const tokens = req.body.tokens;
        const message = {
            notification: {
                title: title,
                body: body
            },
            tokens: tokens
        } as messaging.MulticastMessage;
        
        // Send a message to devices subscribed to the provided topic.
        try {
            const response = await admin.messaging().sendMulticast(message);
            // Response is a message ID string.
            console.log('Successfully sent message:', response);
            res.status(200).json(response);
        } catch (error) {
            console.log('Error sending message:', error);
            res.status(500).json({
                error: error
            });
        }
    });