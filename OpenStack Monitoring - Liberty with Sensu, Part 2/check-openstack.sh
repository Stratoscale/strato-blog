#!/bin/bash
#
# OpenStack Monitoring script for Sensu
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Requirement: curl
#

# #RED
set -e

STATE_OK=0
STATE_CRITICAL=1

usage ()
{
    echo "Usage: $0 [OPTIONS]"
    echo " -h               Get help"
    echo " -H <Auth URL>    URL for obtaining an auth token"
    echo " -U <username>    Username to use to get an auth token"
    echo " -P <password>    Password to use ro get an auth token"
}

while getopts 'h:H:U:T:P:' OPTION
do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        H)
            export OS_AUTH_URL=$OPTARG
            ;;
        U)
            export OS_USERNAME=$OPTARG
            ;;
        P)
            export OS_PASSWORD=$OPTARG
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

if ! which curl >/dev/null 2>&1
then
    echo "curl is not installed."
    exit $STATE_UNKNOWN
fi

TOKEN=$(curl -d '{"auth":{"passwordCredentials":{"username": "    '$OS_USERNAME'", "password": "'$OS_PASSWORD'"}}}' -H "Content-type: application/json" ${OS_AUTH_URL}/tokens/ 2>&1 | grep token|awk '{print $8}'|grep -o '".*"' | sed -n 's/.*"\([^"]*\)".*/\1/p')

if [ -z "$TOKEN" ]; then
    echo "Unable to get a token"
    exit $STATE_CRITICAL
else
# Deploy a Heat stack to check all the components
heat --os-auth-token $TOKEN create-stack -f check-openstack.yaml check-openstack
         i="0"
         while [ $i -lt 6 ]
         do
         STATUS=`heat stack-show check-openstack | awk '/stack_status / {print $4}'`
         test  $STATUS != 'CREATE_IN_PROGRESS' && break
         sleep 10
         done
         STATUS=`heat stack-show check-openstack | awk '/stack_status / {print $4}'`
    if [[ $STATUS = 'CREATE_COMPLETE' ]]; then
          return $STATE_OK
    else 
          return $STATE_CRITICAL
    fi         
fi
heat --os-auth-token $TOKEN delete-stack check-openstack

