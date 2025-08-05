import admin from 'firebase-admin';
import serviceAccount from './firebase-service-account.json';

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

export const sendFCM = async (token: string, title: string, body: string) => {
  const message = {
    notification: { title, body },
    token,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent:', response);
  } catch (error) {
    console.error('FCM error:', error);
  }
};
