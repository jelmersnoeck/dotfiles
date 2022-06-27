#!/bin/bash

# The "init" command will set up `kube.sh` in the global path so it can be used
# from anywhere on a consumer's computer.
if [[ $1 == "init" ]]; then
    echo "export PATH=\"$(PWD):\$PATH\"" >> ~/.bash_profile
    source ~/.bash_profile
    exit 0
fi

ENV=$1
COMMAND=$2

shift 2
ARGS=$@

# In our local environment, we want to use "dev" for simplicity. However, the
# context will be called docker-for-desktop (sorry linux users)
CONTEXT=$ENV
if [ "$ENV" == "dev" ]; then
    CONTEXT=docker-for-desktop
fi

if [[ $ENV == "" ]]; then
    echo "Please specify an environment"
    exit 1
fi

# This will validate that the context is present on your system, if not, it will
# error.
CONTEXT_ENV=$(cat ~/.kube/config | grep -A5 context: | grep name: | cut -f4 -d' ' | grep $CONTEXT)
if [[ $ENV != dev && $CONTEXT_ENV != $ENV ]]; then
    echo "Please specify an existing environment"
    exit 1
fi

if [[ $COMMAND == "" ]]; then
    echo "Please specify a command"
    exit 1
fi

# When we're not running against the development environment, we want to make
# sure no intrusive actions are taken without consideration. This will check for
# that.
if [[ $ENV != "dev" && $CI_BUILD != "true" ]] && [[ $COMMAND != "top" && $COMMAND != "get" && $COMMAND != "logs" && $COMMAND != "describe" && $COMMAND != "octant" && $COMMAND != "rollout" && $COMMAND != "port-forward" ]]; then
    echo "You'll be changing a non development environment. Are you sure you want to proceed? (YES/NO)"
    read -p "YES/NO: " answer
    if [ $answer != "YES" ]; then
        echo "Copy that, bye!"
        exit 1
    fi
fi

bold=$(tput bold)
normal=$(tput sgr0)

echo "Using kubctl context ${bold}$CONTEXT${normal}"

echo $COMMAND
case $COMMAND in
    restart)
        ARGS="$ARGS -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}""
        COMMAND="kubectl --context=$CONTEXT patch deployment $ARGS"
        ;;
    dsrestart)
        ARGS="$ARGS -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}""
        COMMAND="kubectl --context=$CONTEXT patch daemonset $ARGS"
        ;;
    octant)
        COMMAND="octant --context=$CONTEXT"
        ;;
    *)
        # Valid kubectl command, keep using that
        COMMAND="kubectl --context=$CONTEXT $COMMAND $ARGS"
        ;;
esac

echo $COMMAND
exec $COMMAND
