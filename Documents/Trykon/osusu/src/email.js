/**
 * Email Service Module
 * Handles sending emails for password resets, notifications, and alerts
 * Currently configured for SendGrid - easily swappable for Mailgun, AWS SES, etc.
 */

const nodemailer = require('nodemailer');
const logger = require('./logger');

// Email configuration
const EMAIL_SERVICE = process.env.EMAIL_SERVICE || 'sendgrid'; // 'sendgrid', 'mailgun', 'smtp'
const EMAIL_FROM = process.env.EMAIL_FROM || 'noreply@osusu.app';
const EMAIL_API_KEY = process.env.EMAIL_API_KEY || '';
const EMAIL_SMTP_HOST = process.env.EMAIL_SMTP_HOST || '';
const EMAIL_SMTP_PORT = process.env.EMAIL_SMTP_PORT || 587;
const EMAIL_SMTP_USER = process.env.EMAIL_SMTP_USER || '';
const EMAIL_SMTP_PASSWORD = process.env.EMAIL_SMTP_PASSWORD || '';

// Initialize transporter based on service
let transporter = null;

const initializeTransporter = () => {
  if (EMAIL_SERVICE === 'sendgrid' && EMAIL_API_KEY) {
    // SendGrid configuration
    transporter = nodemailer.createTransport({
      host: 'smtp.sendgrid.net',
      port: 587,
      auth: {
        user: 'apikey',
        pass: EMAIL_API_KEY
      }
    });
  } else if (EMAIL_SERVICE === 'mailgun' && EMAIL_API_KEY) {
    // Mailgun configuration
    transporter = nodemailer.createTransport({
      host: 'smtp.mailgun.org',
      port: 587,
      auth: {
        user: `postmaster@${process.env.MAILGUN_DOMAIN}`,
        pass: EMAIL_API_KEY
      }
    });
  } else if (EMAIL_SERVICE === 'smtp' && EMAIL_SMTP_HOST) {
    // Generic SMTP configuration
    transporter = nodemailer.createTransport({
      host: EMAIL_SMTP_HOST,
      port: EMAIL_SMTP_PORT,
      secure: EMAIL_SMTP_PORT === 465,
      auth: {
        user: EMAIL_SMTP_USER,
        pass: EMAIL_SMTP_PASSWORD
      }
    });
  } else if (process.env.NODE_ENV === 'development') {
    // Development: Use Ethereal (fake SMTP for testing)
    transporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      auth: {
        user: process.env.ETHEREAL_USER || 'test@ethereal.email',
        pass: process.env.ETHEREAL_PASSWORD || 'test'
      }
    });
  } else {
    logger.warn('Email service not configured. Email functionality disabled.');
  }
};

/**
 * Send password reset email
 * @param {string} email - User's email address
 * @param {string} resetToken - JWT token for password reset
 * @returns {Promise}
 */
const sendPasswordResetEmail = async (email, resetToken) => {
  try {
    if (!transporter) {
      initializeTransporter();
    }

    if (!transporter) {
      logger.error('Email transporter not initialized');
      return { success: false, error: 'Email service unavailable' };
    }

    const resetLink = `${process.env.APP_URL || 'http://localhost:5000'}/auth/reset-password?token=${resetToken}`;

    const mailOptions = {
      from: EMAIL_FROM,
      to: email,
      subject: 'Password Reset Request - Osusu',
      html: `
        <h2>Password Reset Request</h2>
        <p>You requested a password reset. Click the link below to reset your password:</p>
        <p><a href="${resetLink}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
          Reset Password
        </a></p>
        <p>Or copy this link: ${resetLink}</p>
        <p>This link expires in 1 hour.</p>
        <p>If you didn't request this, please ignore this email.</p>
        <hr />
        <p style="color: #666; font-size: 12px;">© Osusu - Community Savings Groups</p>
      `,
      text: `Password Reset Request\n\nClick the link to reset your password: ${resetLink}\n\nThis link expires in 1 hour.\n\nIf you didn't request this, please ignore this email.`
    };

    const result = await transporter.sendMail(mailOptions);
    logger.info(`Password reset email sent to ${email}`, { messageId: result.messageId });
    return { success: true, messageId: result.messageId };
  } catch (err) {
    logger.error('Failed to send password reset email', { email, error: err.message });
    return { success: false, error: err.message };
  }
};

/**
 * Send admin notification email
 * @param {string} email - Admin's email address
 * @param {string} action - Action performed
 * @param {object} details - Details about the action
 * @returns {Promise}
 */
const sendAdminNotificationEmail = async (email, action, details) => {
  try {
    if (!transporter) {
      initializeTransporter();
    }

    if (!transporter) {
      logger.error('Email transporter not initialized');
      return { success: false, error: 'Email service unavailable' };
    }

    const mailOptions = {
      from: EMAIL_FROM,
      to: email,
      subject: `Admin Alert - ${action} - Osusu`,
      html: `
        <h2>Admin Alert: ${action}</h2>
        <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
        <h3>Details:</h3>
        <pre>${JSON.stringify(details, null, 2)}</pre>
        <hr />
        <p style="color: #666; font-size: 12px;">© Osusu - Community Savings Groups</p>
      `,
      text: `Admin Alert: ${action}\n\nTimestamp: ${new Date().toISOString()}\n\nDetails:\n${JSON.stringify(details, null, 2)}`
    };

    const result = await transporter.sendMail(mailOptions);
    logger.info(`Admin notification sent to ${email}`, { action, messageId: result.messageId });
    return { success: true, messageId: result.messageId };
  } catch (err) {
    logger.error('Failed to send admin notification', { email, action, error: err.message });
    return { success: false, error: err.message };
  }
};

/**
 * Send user welcome email
 * @param {string} email - User's email address
 * @param {string} name - User's name
 * @returns {Promise}
 */
const sendWelcomeEmail = async (email, name = 'User') => {
  try {
    if (!transporter) {
      initializeTransporter();
    }

    if (!transporter) {
      logger.error('Email transporter not initialized');
      return { success: false, error: 'Email service unavailable' };
    }

    const mailOptions = {
      from: EMAIL_FROM,
      to: email,
      subject: 'Welcome to Osusu - Community Savings Groups',
      html: `
        <h2>Welcome to Osusu, ${name}!</h2>
        <p>We're excited to have you join our community of savers.</p>
        <h3>Getting Started:</h3>
        <ol>
          <li>Create or join a savings group</li>
          <li>Make regular contributions</li>
          <li>Receive payouts on your scheduled cycle</li>
        </ol>
        <p><a href="${process.env.APP_URL || 'http://localhost:5000'}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
          Log In to Osusu
        </a></p>
        <hr />
        <p style="color: #666; font-size: 12px;">© Osusu - Community Savings Groups</p>
      `,
      text: `Welcome to Osusu, ${name}!\n\nWe're excited to have you join our community of savers.\n\nGetting Started:\n1. Create or join a savings group\n2. Make regular contributions\n3. Receive payouts on your scheduled cycle`
    };

    const result = await transporter.sendMail(mailOptions);
    logger.info(`Welcome email sent to ${email}`, { messageId: result.messageId });
    return { success: true, messageId: result.messageId };
  } catch (err) {
    logger.error('Failed to send welcome email', { email, error: err.message });
    return { success: false, error: err.message };
  }
};

/**
 * Send group notification email
 * @param {string} email - Recipient email
 * @param {string} groupName - Group name
 * @param {string} message - Message to send
 * @returns {Promise}
 */
const sendGroupNotificationEmail = async (email, groupName, message) => {
  try {
    if (!transporter) {
      initializeTransporter();
    }

    if (!transporter) {
      logger.error('Email transporter not initialized');
      return { success: false, error: 'Email service unavailable' };
    }

    const mailOptions = {
      from: EMAIL_FROM,
      to: email,
      subject: `Group Update - ${groupName} - Osusu`,
      html: `
        <h2>Group Update: ${groupName}</h2>
        <p>${message}</p>
        <p><a href="${process.env.APP_URL || 'http://localhost:5000'}/groups/${groupName}">
          View Group
        </a></p>
        <hr />
        <p style="color: #666; font-size: 12px;">© Osusu - Community Savings Groups</p>
      `,
      text: `Group Update: ${groupName}\n\n${message}`
    };

    const result = await transporter.sendMail(mailOptions);
    logger.info(`Group notification sent to ${email}`, { group: groupName, messageId: result.messageId });
    return { success: true, messageId: result.messageId };
  } catch (err) {
    logger.error('Failed to send group notification', { email, groupName, error: err.message });
    return { success: false, error: err.message };
  }
};

/**
 * Test email configuration
 * @returns {Promise}
 */
const testEmailConfiguration = async () => {
  try {
    if (!transporter) {
      initializeTransporter();
    }

    if (!transporter) {
      return { success: false, error: 'Email transporter not initialized' };
    }

    await transporter.verify();
    logger.info('Email configuration verified successfully');
    return { success: true, message: 'Email service is properly configured' };
  } catch (err) {
    logger.error('Email configuration test failed', { error: err.message });
    return { success: false, error: err.message };
  }
};

// Initialize on module load
if (process.env.NODE_ENV !== 'test') {
  initializeTransporter();
}

module.exports = {
  sendPasswordResetEmail,
  sendAdminNotificationEmail,
  sendWelcomeEmail,
  sendGroupNotificationEmail,
  testEmailConfiguration,
  initializeTransporter
};
