*** Settings ***
Documentation     dhcp snoop same port multiple vlan
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_dhcp_snoop_same_port_multiple_vlan
    [Documentation]    1	enable snoop on vlan 100 and vlan 85	success
    ...    2	set lease limit as 4 and 5 on those two vlans, and add those vlan on port a 	success
    ...    3	get 9 dhcp lease from port a	can get 9 dhcp leases
    ...    4	get one more dhcp lease	fail
    ...    5	set dhcp lease limit to 0	how many dhcp lease can be get is decided by the system
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2100    @globalid=2343908    @subfeature=DHCP_Lease_Limits    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 enable snoop on vlan 100 and vlan 85 success
    log    STEP:2 set lease limit as 4 and 5 on those two vlans, and add those vlan on port a success
    prov_dhcp_profile    eutA    ${l2_profile_name}    lease-limit ${lease_limit}
    prov_dhcp_profile    eutA    ${l2_profile_name_2}    lease-limit ${lease_limit_2}
    log    STEP:3 get 9 dhcp lease from port a can get 9 dhcp leases
    log    STEP:4 get one more dhcp lease fail
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_server    tg1    ${server_name_2}    service_p1    ${server_mac_2}     ${server_ip_2}     ${lease_start_2}    ${Qtag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}    session=${lease_number_1}
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}    ${Qtag_vlan_3}    session=${lease_number_2}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Server    tg1    ${server_name_2}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Control Dhcp Client    tg1    ${group_name_2}    start
    run keyword and ignore error    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases
    ${lease}    evaluate    ${lease_limit}+${lease_limit_2}
    wait until keyword succeeds    10    1    check_l3_hosts    eutA    ${lease}
    log    STEP:5 set dhcp lease limit to 0 how many dhcp lease can be get is decided by the system

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=1
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_3}    ${Qtag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=2

case teardown
    [Documentation]   case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name_2}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name_2}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name_2}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cfg_prefix=1
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_3}    ${Qtag_vlan}    cfg_prefix=2
    prov_dhcp_profile    eutA    ${l2_profile_name}    no lease-limit
    prov_dhcp_profile    eutA    ${l2_profile_name_2}    no lease-limit