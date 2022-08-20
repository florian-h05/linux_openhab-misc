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

# Setup folder
mkdir -p pki/private/keys
mkdir -p pki/p12
mkdir -p tmp

require_cn() {
  if [ "${commonName}" == "" ]; then
    echo "Provide command line argument -cn or --commonname"
    exit 1
  fi
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
  echo -e "\nGenerating CSR ...\n"
  openssl req -new -x509 -days 1825 -key "pki/private/keys/${commonName}.key" -out "tmp/${commonName}.req" -addext "${OVPN_CLIENT_KEY_USAGE}" -addext "${OVPN_CLIENT_EXT_KEY_USAGE}" -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${organizationalUnit}/CN=${commonName}"
}

generate_ovpn_server_csr() {
  echo -e "\nGenerating OpenVPN server CSR ...\n"
  openssl req -new -x509 -days 1825 -key "pki/private/keys/${commonName}.key" -out "tmp/${commonName}.req" -addext "${OVPN_SERVER_KEY_USAGE}" -addext "${OVPN_SERVER_EXT_KEY_USAGE}" -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${organizationalUnit}/CN=${commonName}"
}

import_csr() {
  require_cn
  echo -e "\nImporting CSR ...\n"
  ./easyrsa import-req "tmp/${commonName}.req" "${commonName}"
}

sign_csr() {
  require_cn
  echo -e "\nSigning CSR ...\n"
  ./easyrsa sign-req client "${commonName}"
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

generate_client_p12() {
  require_cn
  generate_rsa_key
  #generate_ecc_key # TLS Handshake fails with secp521r keys!
  generate_client_csr
  import_csr
  sign_csr
  generate_p12
  rm "tmp/${commonName}.req"
}

generate_ovpn_server() {
  commonName="OpenVPN_Server"
  organizationalUnit="VPN"
  generate_rsa_key
  generate_ovpn_server_csr
  import_csr
  sign_csr
  rm "tmp/${commonName}.req"
}

help() {
  echo "Info: The pki/private folder will be used for keys, the pki/p12 folder for p12 bundles."
  echo "Warning: Spaces are not allowed in common name or organizational unit!"
  echo "Command line args are:"
  echo "  -cn=* --commonname=*             common name for client certificate"
  echo "  -ou=* --organizationalunit=*     organizational unit (OU) for client certificate"
  echo "  -e=*  --exec=*                   command to run"
  echo "Valid commands are:"
  echo "  generate_client_p12"
  echo "  generate_ovpn_server"
  echo "  revoke_cert"
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
    ;;
    *)
    echo "Please provide command line args. Help: -h --help"
    ;;
  esac
done

if [ "${exec}" == "" ]; then
  echo "Provide command line argument -e or --exec"
  exit 1
fi

${exec}
