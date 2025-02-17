#!/bin/bash

echo "🔐 Starting SSL Certificate Generation..."

# Ensure the certs directory exists
mkdir -p certs

# Check if the CA certificate already exists
if [[ -f "certs/ca.crt" && -f "certs/ca.key" ]]; then
  echo "✅ CA certificate already exists. Skipping CA generation."
else
  echo "🔑 Generating new CA certificate..."
  cat > scripts/ca.cnf <<EOF
[ req ]
default_bits       = 4096
default_md         = sha256
distinguished_name = req_distinguished_name
x509_extensions    = v3_ca
prompt             = no
[ req_distinguished_name ]
C  = US
ST = California
L  = SanFrancisco
O  = MyCompany
OU = IT
CN = ELK-CA
[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign
EOF

  openssl req -x509 -newkey rsa:4096 -keyout certs/ca.key -out certs/ca.crt -days 365 -nodes -config scripts/ca.cnf

  if [[ ! -f certs/ca.crt ]]; then
    echo "❌ Failed to generate CA certificate. Exiting."
    exit 1
  fi
fi

# Generate certificates for each Elasticsearch node
for node in elasticsearch1 elasticsearch2 elasticsearch3; do
  if [[ -f "certs/$node.crt" && -f "certs/$node.key" ]]; then
    echo "✅ Certificate for $node already exists. Skipping."
    continue
  fi

  echo "🔑 Generating certificate for $node..."

  # Create OpenSSL config file with SANs
  cat > scripts/$node.cnf <<EOF
[ req ]
default_bits       = 4096
default_md         = sha256
distinguished_name = req_distinguished_name
req_extensions     = req_ext
prompt             = no
[ req_distinguished_name ]
C  = US
ST = California
L  = SanFrancisco
O  = MyCompany
OU = IT
CN = $node
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = $node
DNS.2 = localhost
IP.1  = 127.0.0.1
IP.2  = 172.18.0.4 # Replace with actual container IP if known
EOF

  # Generate private key and CSR
  openssl req -newkey rsa:4096 -keyout certs/$node.key -out certs/$node.csr -nodes -config scripts/$node.cnf

  if [[ ! -f certs/$node.csr ]]; then
    echo "❌ Failed to generate CSR for $node. Skipping."
    continue
  fi

  # Sign the CSR with the CA certificate
  openssl x509 -req -in certs/$node.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/$node.crt -days 365 -extensions req_ext -extfile scripts/$node.cnf

  if [[ ! -f certs/$node.crt ]]; then
    echo "❌ Failed to generate certificate for $node."
  else
    echo "✅ Certificate for $node generated successfully."
  fi
done

echo "🎉 All certificates generated successfully!"
