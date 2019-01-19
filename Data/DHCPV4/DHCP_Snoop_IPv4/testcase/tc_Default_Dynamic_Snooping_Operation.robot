*** Settings ***
Documentation     Default Dynamic Snooping Operation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Default_Dynamic_Snooping_Operation
    [Documentation]    1	Default Dynamic Snooping Operation: Force subscriber to obtain an IP address via DHCP. show l3-host.	An address is obtained. DHCPv4 Snoop Agent must maintain the following attributes (at a minimum) within the lease database:Client MAC Address Client IPv4 Address Client IPv4 Subnet Mask Client VLAN Client Port DHCP Server IP Address Gateway IP Address Lifetime Start Time Last Renew Timet
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-664    @feature=DHCPV4    @globalid=2307004    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-664 setup
    [Teardown]   AXOS_E72_PARENT-TC-664 teardown
    log    STEP:1 Default Dynamic Snooping Operation: Force subscriber to obtain an IP address via DHCP. show l3-host. An address is obtained. DHCPv4 Snoop Agent must maintain the following attributes (at a minimum) within the lease database:Client MAC Address Client IPv4 Address Client IPv4 Subnet Mask Client VLAN Client Port DHCP Server IP Address Gateway IP Address Lifetime Start Time Last Renew Timet
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ovlan=${stag_vlan}   lease_time=${lease_time}    ip_prefix_length=${mask}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    mac=${client_mac}    mask=${mask_in_cli}    dhcp-server=${server_ip}    gateway1=${server_ip}    host-type=dhcp-lease    up-down-state=up
    check_lease_expire_time    eutA    ${stag_vlan}    ${lease_start}    ${lease_time}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Sleep  ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    

*** Keywords ***
AXOS_E72_PARENT-TC-664 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-664 setup
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}


AXOS_E72_PARENT-TC-664 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-664 teardown
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}