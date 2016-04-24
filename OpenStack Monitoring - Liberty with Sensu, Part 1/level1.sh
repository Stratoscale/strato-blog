!/usr/bin/python
#Keystone Sensu Availability Health check      
# 
# import sys 
import urllib2
import base64 
import json
import logging
import argparse
import requests

def sensuHealth():
    request = requests.get('http://192.168.16.100:5000, timeout=1)
    if request.status_code == 204:
        print "Keystone OK"
        sys.exit(0)
        
    elif request.status_code == 503:
        print "Keystone Critical"
        sys.exit(2)
    
    else:
        print "Sensu -Unknown Problem- Warning "
        sys.exit(1)
sensuHealth()`

