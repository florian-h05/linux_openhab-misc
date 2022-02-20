To enable mTLS authentication in your proxy server blocks, add the
following directive to the `server` block of the *.conf* file:
```
    # Client Certificate Authentication
    include /config/nginx/mtls.conf;
```