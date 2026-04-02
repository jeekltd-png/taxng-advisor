#!/bin/bash

# SSL/TLS Certificate Setup Script
# Generates self-signed certificates and configures HTTPS

set -e

echo "🔐 Osusu SSL/TLS Certificate Setup"
echo "==================================="

CERT_DIR="./config/certs"
DAYS_VALID=365

# Check if Let's Encrypt option
if [ "$1" = "letsencrypt" ]; then
    echo "Setting up Let's Encrypt certificates..."
    echo "Please ensure certbot is installed: sudo apt-get install certbot python3-certbot-nginx"
    echo ""
    echo "Run the following command:"
    echo "  certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com"
    echo ""
    echo "Then set environment variables:"
    echo "  SSL_CERT_PATH=/etc/letsencrypt/live/yourdomain.com/fullchain.pem"
    echo "  SSL_KEY_PATH=/etc/letsencrypt/live/yourdomain.com/privkey.pem"
    echo ""
    exit 0
fi

# Create certificate directory
mkdir -p "$CERT_DIR"

echo "Generating self-signed certificate for $DAYS_VALID days..."
echo ""

# Generate private key and certificate
openssl req -x509 -newkey rsa:4096 -keyout "$CERT_DIR/key.pem" -out "$CERT_DIR/cert.pem" -days $DAYS_VALID -nodes -subj "/C=GB/ST=England/L=London/O=Osusu/CN=localhost"

echo "✅ Certificates generated:"
echo "  Private Key: $CERT_DIR/key.pem"
echo "  Certificate: $CERT_DIR/cert.pem"
echo ""
echo "📝 Environment Variables to set:"
echo "  SSL_CERT_PATH=$CERT_DIR/cert.pem"
echo "  SSL_KEY_PATH=$CERT_DIR/key.pem"
echo "  FORCE_HTTPS=true"
echo ""
echo "🚀 The server will now use HTTPS on port 443 (requires sudo)"
echo ""
echo "For production:"
echo "  1. Use Let's Encrypt: ./scripts/setup-ssl.sh letsencrypt"
echo "  2. Or provide commercial certificate paths"
echo "  3. Always use FORCE_HTTPS=true in production"
