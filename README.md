# Keystone Docker

 Configuring keystone to use for sodafoundation.

## Steps to use

* Replace HOST_IP and OS_AUTH_URL environment variable in docker-compose.yml with your IP address starting with 192.x.x.x
* This will bring up an instance of keystone with credentials
```
      HOST_IP: "192.168.1.4"
       OS_AUTH_URL: "http://192.168.1.4:5000/v3"
       OS_USERNAME: admin
       OS_PASSWORD: "opensds#123"
       OS_PROJECT_NAME: admin
       OS_USER_DOMAIN_NAME: Default
       OS_PROJECT_DOMAIN_NAME: Default
```

### For those who are referring to build their own docker container

* Edit the section in the file ```entrypoint.sh``` as per your project.

```bash
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
```

* Define you own (project) policy in ```keystone.policy.json```

**Note:**  This is just a sample docker-compose.yml file in production environment replace all hard-coded passwords with docker secrets
