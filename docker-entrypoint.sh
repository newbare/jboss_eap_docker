#!/bin/bash

export JBOSS_HOME=$HOME/${jboss_version}
export JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
export PATH=/home/jboss/${jboss_version}/bin:$PATH

if [ -z "$JBOSS_USER" ]; then
    JBOSS_USER=jbossadmin
fi
if [ -z "$JBOSS_PASSWORD" ]; then
    JBOSS_PASSWORD=jboss@min1
fi
if [ -z "$JBOSS_MODE" ]; then
    JBOSS_MODE=standalone
fi
if [ -z "$JBOSS_CONFIG" ]; then
    JBOSS_CONFIG=$JBOSS_MODE.xml
fi
echo "Using JBOSS_MODE=$JBOSS_MODE and JBOSS_CONFIG=$JBOSS_CONFIG"

if [ $JBOSS_MODE != "domain" ] && [ $JBOSS_MODE != "standalone" ]; then
    echo "JBOSS_MODE should be domain or standalone"
    exit 1
fi

gosu jboss $JBOSS_HOME/bin/add-user.sh -s -u $JBOSS_USER -p $JBOSS_PASSWORD

if [ -d /base ]; then
    echo "=> Copying custom base configuration to $JBOSS_HOME/$JBOSS_MODE/"
    yes | cp -R /base/* $JBOSS_HOME/$JBOSS_MODE/.
fi

echo "=> Starting JBoss EAP server"

if [ "$JBOSS_DEBUG_SUSPEND" = "TRUE" ] || [ "$JBOSS_DEBUG_SUSPEND" = "true" ]; then
   JBOSS_DEBUG_CONFIG="--debug 8787"
   echo "Using debug configuration $JBOSS_DEBUG_CONFIG"
else
   JBOSS_DEBUG_CONFIG=""
   echo "Default mode (no suspend / debug)"
fi


if [ "$1" = 'start-jboss' ]; then
    exec gosu jboss $JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -bmanagement 0.0.0.0 -c $JBOSS_CONFIG $JBOSS_DEBUG_CONFIG 2>&1 | tee /var/log/jboss/console.log


else
    exec gosu jboss nohup $JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -bmanagement 0.0.0.0 -c $JBOSS_CONFIG $JBOSS_DEBUG_CONFIG > /var/log/jboss/console.log 2>&1 &

    echo "=> JBoss EAP server startup complete"

    exec gosu jboss "$@"
fi
