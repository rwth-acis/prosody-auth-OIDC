# OIDC Module for Prosody
> A Prosody 0.10 module that allows to login with an OpenID Connect token, how cool is that!

This module for Prosody 0.10 (it doesn't work with 0.9) allows users to log in to the XMPP server with an XAuth token. The password field has to contain the OAUTH2 token which is verified against the OIDC server's userinfo endpoint.

# How-to Use
Simply copy the lua file to your Prosody's modules directory. On Ubuntu, that would be /usr/lib/prosody/modules/.

# Contact
István Koren, contact information available on http://dbis.rwth-aachen.de/cms/staff/koren

# License
This module is licensed under Apache 2.0, (c) 2015 by ACIS group at RWTH Aachen University. We build on prior work from Prosody, please check the lua file.
