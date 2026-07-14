import nodemailer from 'nodemailer';

/**
 * Dispatch event update email notifications to all users who booked the event.
 * @param {string[]} emails List of booked users' emails
 * @param {object} event The populated event object
 */
export const sendEventUpdateEmail = async (emails, event) => {
  try {
    if (!emails || emails.length === 0) return;

    // Output visual test logging to backend console so developers can verify easily
    console.log('\n=================== EMAIL SERVICE LOGS ===================');
    console.log(`[EMAIL DISPATCH] Triggering event update emails to: ${emails.join(', ')}`);
    console.log(`[EMAIL SUBJECT] Notification: Event "${event.title}" Details Updated`);
    console.log(`[EMAIL BODY PREVIEW]:
Dear Guest,

The event "${event.title}" that you booked has been updated.
Updated details:
Date: ${new Date(event.date).toUTCString()}
Location: ${event.location}

If you have any questions, please contact event organizers.

Best regards,
Event Management App Team`);
    console.log('==========================================================\n');

    // Create transport (defaults to Mailtrap or local dev server)
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.mailtrap.io',
      port: parseInt(process.env.SMTP_PORT || '2525', 10),
      auth: {
        user: process.env.SMTP_USER || '',
        pass: process.env.SMTP_PASS || '',
      },
    });

    const title = `Notification: Event "${event.title}" Details Updated`;
    const textContent = `Dear Guest,

The event "${event.title}" that you booked has been updated.

Here are the updated details:
Date: ${new Date(event.date).toUTCString()}
Location: ${event.location}

If you have any questions, please contact event organizers.

Best regards,
Event Management App Team`;

    // Only attempt real send if credentials are provided to prevent crash/errors
    if (process.env.SMTP_USER && process.env.SMTP_PASS) {
      for (const email of emails) {
        try {
          await transporter.sendMail({
            from: '"Event Management App" <noreply@eventapp.com>',
            to: email,
            subject: title,
            text: textContent,
          });
          console.log(`[EMAIL SENT] Successfully dispatched email to ${email}`);
        } catch (mailError) {
          console.error(`[EMAIL ERROR] Failed to send email to ${email}:`, mailError.message);
        }
      }
    } else {
      console.log('[EMAIL SERVICE] No SMTP credentials provided in .env. Skipping real mail dispatch.');
    }

  } catch (error) {
    console.error('[EMAIL SERVICE ERROR] Failed to dispatch notifications:', error);
  }
};
