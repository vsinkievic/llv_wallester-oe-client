#!/bin/bash
#
# Import Wallester SSL CA certificates

yum install glibc.i686
/usr/dlc/11.6/bin/certutil -import ./starfield-root-ca.cer
/usr/dlc/11.6/bin/certutil -import ./starfield-root-ca-g2.cer
/usr/dlc/11.6/bin/certutil -import ./amazon-root-ca.cer
/usr/dlc/11.6/bin/certutil -import ./amazon.cer
/usr/dlc/11.6/bin/certutil -import ./wallester-test-domain.cer