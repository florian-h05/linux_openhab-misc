# Easy-RSA

Easy-RSA is a CA management tool by the OpenVPN team ([OpenVPN/easy-rsa](https://github.com/OpenVPN/easy-rsa)).

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
# Must match with the Certificate Authority previously created using easy-rsa!
COUNTRY="DE"
STATE="Berlin"
LOCALITY="Berlin"
ORGANIZATION="Sample Corp."
```

### Generate a client bundle

```shell
./pki.bash -cn=$COMMONNAME -ou=$ORGANIZATIONUNIT -e=create_client_with_p12
```

| Argument                  | Description              | Required          |
|---------------------------|--------------------------|-------------------|
| -e, --exec                | command to execute       | always            |
| -cn, --commonname         | Common Name              | for most commands |
| -ou, --organizationalunit | Organizational Unit (OU) | never             |

For general usage, just ask the script for help:

```shell
./pki.bash --help
```

In case a parameter is missing, the script will let you know.
