#!/bin/bash

set -e

SSH_DIR=~/.ssh
PRIV_KEY=$SSH_DIR/id_rsa
PUBL_KEY=$PRIV_KEY.pub
AUTH_KEYS=$SSH_DIR/authorized_keys

if ! [ "$1" ]; then
	echo "Must specify host."
	exit 1
fi

# Use the real IP address.
SSH_ARG="$USER@$(getent ahostsv4 "$1" | sed -n 's/ *STREAM.*//p')"

# make sure the target directory exists
ssh "$SSH_ARG" mkdir -p $SSH_DIR

# make our key authorized, first
if ssh "$SSH_ARG" stat $AUTH_KEYS \> /dev/null 2\>\&1; then
	TMP_AUTH_KEYS=/tmp/authorized_keys
	scp "$SSH_ARG":$AUTH_KEYS $TMP_AUTH_KEYS > /dev/null
	if grep -Fxq "$(cat $PUBL_KEY)" $TMP_AUTH_KEYS; then
		echo "found public key in $1's authorized_keys, skipping"
	else
		echo "adding public key to $1's (existing) authorized_keys"

		# shellcheck disable=SC2029
		cat $PUBL_KEY | ssh "$SSH_ARG" "cat - >> $AUTH_KEYS"
	fi
	rm $TMP_AUTH_KEYS
else
	echo "adding public key to $1's (new) authorized_keys"

	# shellcheck disable=SC2029
	cat $PUBL_KEY | ssh "$SSH_ARG" "cat - >> $AUTH_KEYS"
fi

add_file_to_remote() {
	if ssh "$SSH_ARG" stat "$2" \> /dev/null 2\>\&1; then
		echo "'$2' exists on '$1', skipping"
	else
		printf "moving '%s' to '%s' ... " "$2" "$1"
		rsync -a --ignore-existing "$2" "$SSH_ARG:$2"
		echo "done"
	fi
}

# add our keys
add_file_to_remote "$1" $PRIV_KEY
add_file_to_remote "$1" $PUBL_KEY
