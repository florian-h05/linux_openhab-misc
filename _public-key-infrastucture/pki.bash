#!/bin/bash
# Script: pki.bash
# Purpose: Manage client certificates for reverse proxy mTLS auth & OpenVPN clients as well as OpenVPN server using easy-rsa.
# Author: Florian Hotze
# License: MIT

# Must match with the Certificate Authority!
COUNTRY="DE" # Use country letters here
STATE=""
LOCALITY=""
ORGANIZATION=""

# Do not modify!
OVPN_SERVER_KEY_USAGE="keyUsage = nonRepudiation,digitalSignature,keyEncipherment,keyAgreement"
OVPN_SERVER_EXT_KEY_USAGE="extendedKeyUsage = serverAuth"

OVPN_CLIENT_KEY_USAGE="keyUsage = digitalSignature,keyAgreement"
OVPN_CLIENT_EXT_KEY_USAGE="extendedKeyUsage = clientAuth"

# Setup folders
mkdir -p pki/private/keys
mkdir -p pki/p12
mkdir -p tmp

require_cn() {
  if [ "${commonName}" == "" ]; then
    echo "Provide command line argument -cn or --commonname"
    exit 1
  fi
}

require_ou() {
  if [ "${organizationalUnit}" == "" ]; then
    echo "Provide command line argument -ou or --organizationalunit"
    exit 1
  fi
}

verify_crt_key() {
  require_cn
  echo "Private key hash: $(openssl rsa -noout -modulus -in pki/private/keys/"${commonName}".key | openssl md5)"
  echo "Public key hash: $(openssl x509 -noout -modulus -in pki/issued/"${commonName}".crt | openssl md5)"
}

generate_ecc_key() {
  require_cn
  echo -e "\nGenerating ECC key ...\n"
  openssl ecparam -out "pki/private/keys/${commonName}.key" -name secp521r1 -genkey
}

generate_rsa_key() {
  require_cn
  echo -e "\nGenerating RSA key ...\n"
  openssl genrsa -out "pki/private/keys/${commonName}.key" 4096
}

generate_client_csr() {
  require_cn
  require_ou
  echo -e "\nGenerating CSR ...\n"
  openssl req -new -days 1825 -key "pki/private/keys/${commonName}.key" -out "tmp/${commonName}.csr" -addext "${OVPN_CLIENT_KEY_USAGE}" -addext "${OVPN_CLIENT_EXT_KEY_USAGE}" -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${organizationalUnit}/CN=${commonName}"
}

generate_ovpn_server_csr() {
  echo -e "\nGenerating OpenVPN server CSR ...\n"
  openssl req -new -days 3650 -key "pki/private/keys/${commonName}.key" -out "tmp/${commonName}.csr" -addext "${OVPN_SERVER_KEY_USAGE}" -addext "${OVPN_SERVER_EXT_KEY_USAGE}" -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${organizationalUnit}/CN=${commonName}"
}

import_csr() {
  require_cn
  echo -e "\nImporting CSR ...\n"
  ./easyrsa import-req "tmp/${commonName}.csr" "${commonName}"
  rm "tmp/${commonName}.csr"
  rmdir tmp
}

sign_csr_client() {
  require_cn
  echo -e "\nSigning CSR (client) ...\n"
  ./easyrsa sign-req client "${commonName}"
}

sign_csr_server() {
  require_cn
  echo -e "\nSigning CSR (server) ...\n"
  ./easyrsa sign-req server "${commonName}"
}

generate_crl() {
  ./easyrsa gen-crl
}

revoke_cert() {
  require_cn
  ./easyrsa revoke "${commonName}"
  generate_crl
}

generate_p12() {
  require_cn
  echo -e "\nGenerating p12 bundle ...\n"
  openssl pkcs12 -export -out "pki/p12/${commonName}.p12" -inkey "pki/private/keys/${commonName}.key" -in "pki/issued/${commonName}.crt"
}

create_client_with_p12() {
  require_cn
  require_ou
  generate_rsa_key
  #generate_ecc_key # TLS Handshake fails with secp521r keys!
  generate_client_csr
  import_csr
  sign_csr_client
  generate_p12
}

create_ovpn_server() {
  commonName="OpenVPN_Server"
  organizationalUnit="VPN"
  generate_rsa_key
  generate_ovpn_server_csr
  import_csr
  sign_csr_server
}

help() {
  echo "Info: The pki/private folder will be used for keys, the pki/p12 folder for p12 bundles."
  echo "Warning: Spaces are not allowed in common name!"
  echo
  echo "Command line args are:"
  echo "  -cn=* --commonname=*             common name for client certificate"
  echo "  -ou=* --organizationalunit=*     organizational unit (OU) for client certificate"
  echo "  -e=*  --exec=*                   command to run"
  echo
  echo "Valid commands are:"
  echo "  create_client_with_p12           create a new client cert/key pair and pack as p12"
  echo "  create_ovpn_server"
  echo "  generate_p12                     create a p12 bundle for an existing cert/key pair"
  echo "  revoke_cert"
  echo "  generate_crl"
  echo "  verifiy_crt_key                  get key hash for certificate and private key"
}

for arg in "$@"
do
  case $arg in
    -cn=*|--commonname=*)
    commonName="${arg#*=}"
    ;;
    -ou=*|--organizationalunit=*)
    organizationalUnit="${arg#*=}"
    ;;
    -e=*|--exec=*)
    exec="${arg#*=}"
    ;;
    -h|--help)
    help
    exit 0
    ;;
    *)
    echo "Please provide command line args in required format. Use -h or --help to get help"
    exit 1
    ;;
  esac
done

if [ "${exec}" == "" ]; then
  echo "Provide command line argument -e or --exec"
  exit 1
fi

${exec}
