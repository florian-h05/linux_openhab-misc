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

## Prints the hash of the private key and the hash of the public key of the certificate and allows for comparison of them.
##
verify_crt_key() {
  require_cn
  echo "Private key hash: $(openssl rsa -noout -modulus -in pki/private/keys/"${commonName}".key | openssl md5)"
  echo "Public key hash:  $(openssl x509 -noout -modulus -in pki/issued/"${commonName}".crt | openssl md5)"
}

## Generates a new ECC key.
##
generate_ecc_key() {
  require_cn
  echo -e "\nGenerating ECC key ...\n"
  openssl ecparam -out "pki/private/keys/${commonName}.key" -name secp521r1 -genkey
}

## Generates a new 4096-bit RSA key.
##
generate_rsa_key() {
  require_cn
  echo -e "\nGenerating RSA key ...\n"
  openssl genrsa -out "pki/private/keys/${commonName}.key" 4096
}

## Generates a new CSR (certificate signing request) for a client certificate.
##
generate_client_csr() {
  require_cn
  mkdir tmp
  echo -e "\nGenerating CSR ...\n"
  openssl req -new -days 1825 -key "pki/private/keys/${commonName}.key" -out "tmp/${commonName}.csr" -addext "${OVPN_CLIENT_KEY_USAGE}" -addext "${OVPN_CLIENT_EXT_KEY_USAGE}" -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${organizationalUnit}/CN=${commonName}"
}

## Generates a new CSR (certificate signing request) for an OpenVPN server certificate.
##
generate_ovpn_server_csr() {
  mkdir tmp
  echo -e "\nGenerating OpenVPN server CSR ...\n"
  openssl req -new -days 3650 -key "pki/private/keys/${commonName}.key" -out "tmp/${commonName}.csr" -addext "${OVPN_SERVER_KEY_USAGE}" -addext "${OVPN_SERVER_EXT_KEY_USAGE}" -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${organizationalUnit}/CN=${commonName}"
}

## Imports the CSR (certificate signing request) into the easy-rsa tool.
##
import_csr() {
  require_cn
  echo -e "\nImporting CSR ...\n"
  ./easyrsa import-req "tmp/${commonName}.csr" "${commonName}"
  rm "tmp/${commonName}.csr"
  rm -r tmp
}

## Signs the CSR (certificate signing request) for a client certificate using the easy-rsa tool.
##
sign_csr_client() {
  require_cn
  echo -e "\nSigning CSR (client) ...\n"
  ./easyrsa sign-req client "${commonName}"
}

## Signs the CSR (certificate signing request) for an OpenVPN server certificate using the easy-rsa tool.
##
sign_csr_server() {
  require_cn
  echo -e "\nSigning CSR (server) ...\n"
  ./easyrsa sign-req server "${commonName}"
}

## Generates a new CRL (certificate revocation list).
##
generate_crl() {
  ./easyrsa gen-crl
}

## Revokes a certificate.
##
revoke_cert() {
  require_cn
  ./easyrsa revoke "${commonName}"
  generate_crl
}

## Generates a new p12 for an existing certificate/key pair.
##
generate_p12() {
  require_cn
  echo -e "\nGenerating p12 bundle ...\n"
  # Adding "-legacy -certpbe pbeWithSHA1And40BitRC2-CBC" for iOS compatibility, see https://github.com/openssl/openssl/issues/19871
  openssl pkcs12 -legacy -certpbe pbeWithSHA1And40BitRC2-CBC -export -out "pki/p12/${commonName}.p12" -inkey "pki/private/keys/${commonName}.key" -in "pki/issued/${commonName}.crt"
}

## Helper function to perform all steps required for creating a new client certificate.
##
create_client() {
  require_cn
  generate_rsa_key
  #generate_ecc_key # TLS Handshake fails with secp521r keys!
  generate_client_csr
  import_csr
  sign_csr_client
}

## Helper function to perform all steps required for creating a new client certificate and pack it as p12 bundle.
##
create_client_with_p12() {
  create_client
  generate_p12
}

## Helper function to perform all steps required for creating a new OpenVPN server certificate.
##
create_ovpn_server() {
  commonName="OpenVPN_Server"
  organizationalUnit="VPN"
  generate_rsa_key
  generate_ovpn_server_csr
  import_csr
  sign_csr_server
}

## Shows the content of the current CRL (certificate revocation list).
##
show_crl() {
  openssl crl -inform PEM -text -noout -in pki/crl.pem
}

## Shows the content of a certificate.
##
show_crt() {
  require_cn
  openssl x509 -in "pki/issued/${commonName}.crt" -text -noout
}

help() {
  echo "Info: The pki/private folder will be used for keys, the pki/p12 folder for p12 bundles."
  echo "Warning: Spaces are not allowed in common name!"
  echo
  echo "Command line args are:"
  echo "  -e=*  --exec=*                   command to run (always required)"
  echo "  -cn=* --commonname=*             common name for client certificate (required for most commands)"
  echo "  -ou=* --organizationalunit=*     organizational unit (OU) for client certificate (never required)"
  echo
  echo "Valid commands are:"
  echo "  create_client_with_p12           create a new client certificate/key pair"
  echo "  create_client_with_p12           create a new client certificate/key pair and pack as p12 bundle"
  echo "  create_ovpn_server               create a new OpenVPN server certificate/key pair"
  echo "  generate_p12                     create a p12 bundle for an existing certificate/key pair"
  echo "  revoke_cert"
  echo "  generate_crl"
  echo "  verify_crt_key                   get key hash for certificate and private key"
  echo "  show_crl                         show certificate revocation list"
  echo "  show_crt                         show certificate infos"
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
    echo "Required command line arguments are missing! Help: -h --help"
    exit 0
    ;;
  esac
done

if [ "${exec}" == "" ]; then
  echo "Required command line arguments are missing! Help: -h --help"
  exit 1
fi

${exec}
