*** Settings ***
Documentation     Snoop Lease Limit ont-port with mac-limit
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Snoop_Lease_Limit_ont_port
    [Documentation]    1	Enable DHCP snoop on PON ONT Eth port A	Configuration Takes
    ...    2	configure lease limit on vlan , l2-dhcp-profile lease limit as 8	Configuration Takes
    ...    3	configure mac-limit 5 on ont-port	Configuration Takes
    ...    4	Force 8 subscribers to obtain an IP address via DHCP on port A	Only 5 subscribers obtain an IP address on the port.
    ...    5	change mac-limit on ont-port to 10	can get 8 dhcp leases
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2097    @globalid=2343905    @subfeature=DHCP_Lease_Limits    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable DHCP snoop on PON ONT Eth port A Configuration Takes
    log    STEP:2 configure lease limit on vlan , l2-dhcp-profile lease limit as 8 Configuration Takes
    prov_dhcp_profile    eutA    ${l2_profile_name}    lease-limit ${lease_limit}
    log    STEP:3 configure mac-limit 5 on ont-port Configuration Takes
    prov_interface    eutA    ont-ethernet    ${service_model.subscriber_point1.name}    mac-limit=${mac_limit}
    log    STEP:4 Force 8 subscribers to obtain an IP address via DHCP on port A Only 5 subscribers obtain an IP address on the port.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}    session=${lease_number_1}
    tg save config into file   tg1   /tmp/${TEST NAME}.xml
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    run keyword and ignore error    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    ${mac_limit}
    log    STEP:5 change mac-limit on ont-port to 10 can get 8 dhcp leases
    Tg Control Dhcp Client    tg1    ${group_name}    stop
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    0
    prov_interface    eutA    ont-ethernet    ${service_model.subscriber_point1.name}    mac-limit=${mac_limit_2}
    Tg Control Dhcp Client    tg1    ${group_name}    start
    run keyword and ignore error    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    ${lease_limit}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=1

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    dprov_interface    eutA    ont-ethernet    ${service_model.subscriber_point1.name}    mac-limit=
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cfg_prefix=1
    prov_dhcp_profile    eutA    ${l2_profile_name}    no lease-limit
