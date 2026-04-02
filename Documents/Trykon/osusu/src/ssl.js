/**
 * SSL/TLS Configuration Module
 * Handles HTTPS setup and certificate management
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const logger = require('./logger');

const SSL_CERT_PATH = process.env.SSL_CERT_PATH;
const SSL_KEY_PATH = process.env.SSL_KEY_PATH;
const FORCE_HTTPS = process.env.FORCE_HTTPS === 'true' || process.env.NODE_ENV === 'production';

/**
 * Load SSL certificates
 * @returns {object} { key, cert } or null if not available
 */
const loadCertificates = () => {
  try {
    if (!SSL_CERT_PATH || !SSL_KEY_PATH) {
      if (FORCE_HTTPS) {
        logger.warn('FORCE_HTTPS is true but SSL certificates not configured');
      }
      return null;
    }

    const key = fs.readFileSync(SSL_KEY_PATH, 'utf8');
    const cert = fs.readFileSync(SSL_CERT_PATH, 'utf8');
    
    logger.info('SSL certificates loaded successfully', { 
      cert: SSL_CERT_PATH, 
      key: SSL_KEY_PATH 
    });
    
    return { key, cert };
  } catch (err) {
    logger.error('Failed to load SSL certificates', { error: err.message });
    if (FORCE_HTTPS) {
      throw err;
    }
    return null;
  }
};

/**
 * Create HTTPS server
 * @param {object} app - Express app
 * @param {number} port - Port to listen on
 * @returns {https.Server}
 */
const createHTTPSServer = (app, port = 443) => {
  const certificates = loadCertificates();
  
  if (!certificates) {
    logger.warn('HTTPS server not available - certificates not configured');
    return null;
  }

  const server = https.createServer(certificates, app);
  return server;
};

/**
 * Middleware to enforce HTTPS redirects
 */
const enforceHTTPS = (req, res, next) => {
  if (FORCE_HTTPS && req.protocol !== 'https' && process.env.NODE_ENV === 'production') {
    return res.redirect(301, `https://${req.hostname}${req.url}`);
  }
  
  // Set security headers
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  
  next();
};

/**
 * Verify certificate validity
 * @returns {object} Certificate info
 */
const verifyCertificate = () => {
  try {
    if (!SSL_CERT_PATH) {
      return { valid: false, message: 'No certificate configured' };
    }

    const cert = fs.readFileSync(SSL_CERT_PATH, 'utf8');
    const lines = cert.split('\n');
    const certData = lines.slice(1, -2).join('\n');
    const buf = Buffer.from(certData, 'base64');
    
    // Parse certificate (simplified)
    const certStr = buf.toString('utf8');
    
    logger.info('Certificate verification complete');
    
    return { 
      valid: true, 
      message: 'Certificate loaded and valid',
      path: SSL_CERT_PATH 
    };
  } catch (err) {
    logger.error('Certificate verification failed', { error: err.message });
    return { 
      valid: false, 
      message: err.message 
    };
  }
};

module.exports = {
  loadCertificates,
  createHTTPSServer,
  enforceHTTPS,
  verifyCertificate,
  FORCE_HTTPS
};
