# Easy-RSA

Easy-RSA is a CA managment tool by the OpenVPN team ([OpenVPN/easy-rsa](https://github.com/OpenVPN/easy-rsa)).


## Setup the PKI

To set up a PKI (Public Key Infrastructure), follow the excellent guide [community guide at digitalocean.com](https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-a-certificate-authority-ca-on-debian-10) until (including) *Step 4 -- Distributing your Certificate Authority’s Public Certificate*.

## Generate client certificates

To generate client certificate bundles (PKCS #12 / p12), use the [pki.bash](pki.bash) script.
This script wraps some openssl and easy-rsa commands.

You must run the script inside your easy-rsa folder.
The script will create a `pki/p12` folder where it stores the bundled certificate & private key.

### Download

```shell
wget https://raw.githubusercontent.com/florian-h05/linux_openhab-misc/main/_public-key-infrastucture/pki.bash
chmod +x pki.bash
```

### Set up PKI information

On top of the script:

```shell
# Must match with the Certificate Authority!
COUNTRY="DE"
STATE="Berlin"
LOCALITY="Berlin"
ORGANIZATION="Sample Corp."
```

### Generate a client bundle

```shell
./pki.bash -cn=$COMMONNAME -ou=$ORGANIZATIONUNIT -e=create_client_with_p12
```

| Argument                  | Description              | Required                                            |
|---------------------------|--------------------------|-----------------------------------------------------|
| -cn, --commonname         | Common Name              | not for ``generate_ovpn_server``                    |
| -ou, --organizationalunit | Organizational Unit (OU) | only for ``generate_client_p12`` & ``generate_csr`` |
| -e, --exec                | command to execute       | always                                              |

For general usage, just ask the script for help:

```shell
./pki.bash -h
```

In case a parameter is missing, the script will let you know.
