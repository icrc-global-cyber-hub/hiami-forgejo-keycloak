#! /bin/bash

# in order to copy this file to the container:
# docker cp ./keycloak/cli_init/ 3d202f9b1801:/opt/keycloak/
# docker exec --privileged -i keycloak chmod 755 -R /opt/keycloak/cli_init

set -o allexport
source ./.env
set +o allexport

export PATH=$PATH:$keycloak_path

# Config credentials to connect to the keycloak instance
kcadm.sh config credentials --server "$keycloak_url" \
  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"

# Deleting the realm
if [ $delete_realm = "true" ]; then
  echo "Deleting realm '$REALM'"
  kcadm.sh delete realms/$REALM
else
  echo "Not deleting realm!"
fi


# Create the realm
if [ $create_realm = "true" ]; then
  echo "Creating realm '$REALM'"
  kcadm.sh create realms -s realm=$REALM -s enabled=true
else
  echo "Not creating realm!"
fi

# Create Client
kcadm.sh create clients -r $REALM \
   -s clientId=$client_id \
   -s enabled=true \
   -s publicClient=false \
   -s 'redirectUris=["'$client_redirect_uris'"]' \
   -s 'webOrigins=["'$client_web_origins'"]' \
   -s protocol=openid-connect \
   -s directAccessGrantsEnabled=true \
   -s serviceAccountsEnabled=true \
   -s authorizationServicesEnabled=true \
   -s secret=$client_secret

# # Create a group
# GROUP_NAME=$APP-users
# kcadm.sh create groups -r $REALM -s name=$GROUP_NAME 2>&1 | tee "$TMPFILE"
# GROUP_ID=`cat "$TMPFILE" | cut "-d'" -f2`

# # Create a realm role
# ROLE_NAME=$APP-users
# kcadm.sh create roles -r $REALM -s name=$ROLE_NAME -s "description=Regular $APP user"

# # Add a role to a group
# kcadm.sh add-roles -r $REALM --gname $GROUP_NAME --rolename $ROLE_NAME

# # Create a user
# USER_NAME=sebastian
# kcadm.sh create users -r $REALM -s username=$USER_NAME -s enabled=true  2>&1 | tee "$TMPFILE"
# USER_ID=`cat "$TMPFILE" | cut "-d'" -f2`

# ## Delete a user
# # kcadm.sh delete users/$USER_ID -r $REALM

# # Add a user to a group
# echo "Adding user $USER_NAME ($USER_ID) to group $GROUP_NAME ($GROUP_ID)"
# kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r $REALM -s realm=$REALM \
#   -s userId=$USER_ID -s groupId=$GROUP_ID -n

# ## Remove a user from a group
# # kcadm.sh delete users/$USER_ID/groups/$GROUP_ID -r $REALM

# # TODO: Create/configure a default group for new (all?) users

# # TODO: Add group to another group