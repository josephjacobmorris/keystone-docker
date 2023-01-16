#!/bin/bash

# Default host ip.
#HOST_IP=0.0.0.0
# OpenSDS version configuration.
OPENSDS_VERSION=${OPENSDS_VERSION:-v1beta}
# OpenSDS service name in keystone.
OPENSDS_SERVER_NAME=${OPENSDS_SERVER_NAME:-opensds}

TLS_ENABLED=${TLS_ENABLED:-false}

# Multi-Cloud service name in keystone
MULTICLOUD_SERVER_NAME=${MULTICLOUD_SERVER_NAME:-multicloud}
# Multi-cloud version in keystone
MULTICLOUD_VERSION=${MULTIexitCLOUD_VERSION:-v1}
KEYSTONE_DB_ROOT_PASSWD=$STACK_PASSWORD
KEYSTONE_DB_PASSWD=$STACK_PASSWORD

setup() {
    # Update keystone.conf
    sed -i 's/connection = sqlite:\/\/\/\/var\/lib\/keystone\/keystone.db/connection = mysql+pymysql:\/\/keystone:KEYSTONE_DB_PASSWORD@opensds-mariadb\/keystone/g' /etc/keystone/keystone.conf

    # Update the keytone token provider to fernet
    sed -i 's\#provider =\provider =\g' /etc/keystone/keystone.conf
    sed -i "s/KEYSTONE_DB_PASSWORD/$KEYSTONE_DB_PASSWD/g" /etc/keystone/keystone.conf

    su -s /bin/sh -c "keystone-manage db_sync" keystone
   
    export OS_PASSWORD=$KEYSTONE_DB_PASSWD


    echo "Host ip....$HOST_IP"
    echo "OS_PASSWORD....$KEYSTONE_DB_PASSWD"
    echo "OS_USERNAME....$OS_USERNAME"
    echo "OS_AUTH_URL....$OS_AUTH_URL"
    echo "OS_PROJECT_NAME....$OS_PROJECT_NAME"
    echo "OS_USER_DOMAIN_NAME....$OS_USER_DOMAIN_NAME"
    echo "OS_PROJECT_DOMAIN_NAME....$OS_PROJECT_DOMAIN_NAME"
    echo "OS_IDENTITY_API_VERSION....$OS_IDENTITY_API_VERSION"

    ## Checking connectivity with database
    apt-get install -y iputils-ping
    ping -c 3 opensds-mariadb && echo "succeeded"
    apt remove -y iputils-ping

    cat /etc/keystone/keystone.conf|grep admin_endpoint | echo
    echo "ServerName $HOST_IP" >> /etc/apache2/apache2.conf



    sed -i "s,^admin_endpoint.*$,admin_endpoint = http://$HOST_IP:5000/v3/,g" /etc/keystone/keystone.conf
    sed -i "s,^public_endpoint.*$,public_endpoint = http://$HOST_IP:5000/v3/,g" /etc/keystone/keystone.conf

    su -s /bin/sh -c "keystone-manage db_sync" keystone

    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

    keystone-manage bootstrap --bootstrap-password $KEYSTONE_DB_PASSWD --bootstrap-admin-url $OS_AUTH_URL \
        --bootstrap-internal-url $OS_AUTH_URL \
        --bootstrap-public-url $OS_AUTH_URL \
        --bootstrap-region-id RegionOne

    service apache2 restart

}

create_user_and_endpoint() {

    # for_hotpot
    openstack user create --domain default --password $STACK_PASSWORD $OPENSDS_SERVER_NAME
    openstack role add --project service --user opensds admin
    openstack group create service
    openstack group add user service opensds
    openstack role add service --project service --group service
    openstack group add user admins admin
    openstack service create --name opensds$OPENSDS_VERSION --description "OpenSDS Block Storage" opensds$OPENSDS_VERSION
    openstack endpoint create --region RegionOne opensds$OPENSDS_VERSION public http://$HOST_IP:50040/$OPENSDS_VERSION/%\(tenant_id\)s
    openstack endpoint create --region RegionOne opensds$OPENSDS_VERSION internal http://$HOST_IP:50040/$OPENSDS_VERSION/%\(tenant_id\)s
    openstack endpoint create --region RegionOne opensds$OPENSDS_VERSION admin http://$HOST_IP:50040/$OPENSDS_VERSION/%\(tenant_id\)s

    # for_gelato
    openstack user create --domain default --password "$STACK_PASSWORD" "$MULTICLOUD_SERVER_NAME"
    openstack role add --project service --user "$MULTICLOUD_SERVER_NAME" admin
    openstack service create --name "multicloud$MULTICLOUD_VERSION" --description "Multi-cloud Block Storage" "multicloud$MULTICLOUD_VERSION"
    openstack endpoint create --region RegionOne "multicloud$MULTICLOUD_VERSION" public "http://$HOST_IP:8089/$MULTICLOUD_VERSION/%(tenant_id)s"
    openstack endpoint create --region RegionOne "multicloud$MULTICLOUD_VERSION" internal "http://$HOST_IP:8089/$MULTICLOUD_VERSION/%(tenant_id)s"
    openstack endpoint create --region RegionOne "multicloud$MULTICLOUD_VERSION" admin "http://$HOST_IP:8089/$MULTICLOUD_VERSION/%(tenant_id)s"
}

install() {
    setup
    echo "**************************************************Creating endpoints .... ************************************************"
    create_user_and_endpoint

    sleep 100000
}

install
