# Caerbannog

This package embeds a Python interpreter into a macOS app.  It also provides the support to allow a Python module to be written in Swift and be imported and called from the Python code.

To build a macOS app that embeds Python and allows calling into or migrating code into Swift, one adds this package as a dependency.  Then, create a python virtual environment containing the required Python dependencies and sources.  Embed the virtual environment as the Resource folder 'venv'.

A sample application using Caerbannog is in the github repository r0ml/CaerbannogSample

============================

1) I need to embed the Python3.framework from XCode-beta in the application that uses Caerbannog because I can't embed it in the package
2) I need to set the Framework search path in the application to include /Applications/Xcode-beta.app/Contents/Developer/Library/Frameworks/ because the Xcode-beta library path for included frameworks is not searched by default
3) the "code sign after copy" option on the Python3.framework needs to be disabled (because the codesign fails)
4) need to "disable library validation" on the 'signing and capabilities' tab because codesigning was disabled on the embedded framework.
5) Create a virtual environment in the app, and pip install the necessary frameworks.   Change directory to the root directory of the application and run  'python3 -m venv venv'    followed by  '. venv/bin/activate'



6) In 3.7, SSL_CERTS are required, and are verified, and that doesn't work for some reason in embedded Python.  By inserting this line:           ssl._create_default_https_context = ssl._create_unverified_context
in the initialization, it seems starts working again.

// FIXME:
This can possibly be fixed by setting SSL_CERT_FILE to something else, the default being /usr/loal/etc/openssl/cert.pem

========================================================

1) Also see:  Beeware (https://beeware.org) , Pyto (https://pyto.app)


