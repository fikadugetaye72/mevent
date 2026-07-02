import { getMessaging } from 'firebase-admin/messaging';
import firebaseAdmin from '../config/firebase.js';
import User from '../models/user.js';

/**
 * Dispatch push notifications when an event is created or updated.
 * Renders both topic broadcasts and multicast direct device notifications.
 * @param {object} event The populated event object
 * @param {'create'|'update'} actionType The operation type
 */
export const sendEventNotification = async (event, actionType) => {
  try {
    if (!firebaseAdmin) {
      console.warn('[FCM] Firebase not initialized. Skipping push notification.');
      return;
    }

    const messaging = getMessaging(firebaseAdmin);
    const title = actionType === 'create' ? 'New Event Scheduled!' : 'Event Settings Updated!';
    const body = `"${event.title}" is happening on ${new Date(event.date).toLocaleDateString()} at ${event.location}.`;

    // 1. Dispatch broadcast message to "events" topic
    const topicMessage = {
      notification: { title, body },
      data: { 
        eventId: event.id || String(event._id),
        type: 'event_update'
      },
      topic: 'events',
    };

    console.log('[FCM] Broadcasting push notification to "events" topic...');
    const topicResponse = await messaging.send(topicMessage);
    console.log('[FCM] Topic broadcast success:', topicResponse);

    // 2. Multicast to registered active devices in MongoDB User collection
    const usersWithTokens = await User.find({ fcmToken: { $ne: null, $ne: '' } }).select('fcmToken');
    const fcmTokens = usersWithTokens.map(u => u.fcmToken);

    if (fcmTokens.length > 0) {
      console.log(`[FCM] Sending multicast push notification to ${fcmTokens.length} devices...`);
      const multicastMessage = {
        tokens: fcmTokens,
        notification: { title, body },
        data: { 
          eventId: event.id || String(event._id),
          type: 'event_update'
        },
      };
      const multicastResponse = await messaging.sendEachForMulticast(multicastMessage);
      console.log(`[FCM] Multicast success: ${multicastResponse.successCount}, failure: ${multicastResponse.failureCount}`);
    } else {
      console.log('[FCM] No registered user device tokens found in database. Skipping multicast.');
    }

  } catch (error) {
    console.error('[FCM ERROR] Failed to send push notifications:', error);
  }
};
