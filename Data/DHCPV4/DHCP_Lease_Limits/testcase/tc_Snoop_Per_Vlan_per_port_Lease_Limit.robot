*** Settings ***
Documentation
...
...    DHCPv4 Snoop Agent should support a per-VLAN configurable limit to the number of leases allowed on any member port. This limit applies to all ports on which this VLAN is active and DHCP Snoop is operating
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Snoop_Per_Vlan_per_port_Lease_Limit
    [Documentation]    1	Enable DHCP snoop on SVLAN X (e.g. create DHCP profile for SVLAN X) with uni service 4.	DHCP snooping enabled.
    ...    2	Set the lease limit per VLAN X to 5.	Configuration takes.
    ...    3	Apply the above DHCP profile to UNI port A and B.
    ...    4	bind more than 5 subscribers to obtain an IP address via DHCP on the VLAN X through A and B.	Only 5 subscribers obtains an IP address on each port.
    ...    5	Release 2 leases from the bound DHCP sessions from A and B.
    ...    6	bind more than 2 new DHCP sessions (with different MAC) from A and B.	only another 2 sessions can be bound on each port.
    ...    7	repeat step 1 and 2 for SVLAN Y and set lease limit for SVLAN Y to 6.
    ...    8	bind more than 6 DHCP sessions from other SVLAN Y through A and B.	6 leases can be bound at A and B respectively.
    ...    9	create UNI service X with uni service 1 (C -> S/C).	DHCP snooping and option 82 insertion/removal enabled.
    ...    10	create dhcp profile with lease_limit 5 and apply it to service X.	Configuration takes.
    ...    11	Apply the above service to UNI port A and B.
    ...    12	bind more than 5 subscribers to obtain an IP address via DHCP on the VLAN C through A and B.	Only 5 subscribers obtains an IP address on each port.
    ...    13	Release 2 leases from the bound DHCP sessions from A and B.
    ...    14	bind more than 2 new DHCP sessions (with different MAC) from A and B.	only another 2 sessions can be bound on each port.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2096    @globalid=2343904    @subfeature=DHCP_Lease_Limits    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable DHCP snoop on SVLAN X (e.g. create DHCP profile for SVLAN X) with uni service 4. DHCP snooping enabled.
    log    STEP:2 Set the lease limit per VLAN X to 5. Configuration takes.
    prov_dhcp_profile    eutA    ${l2_profile_name}    lease-limit ${lease_limit}
    log    STEP:3 Apply the above DHCP profile to UNI port A and B.
    log    STEP:4 bind more than 5 subscribers to obtain an IP address via DHCP on the VLAN X through A and B. Only 5 subscribers obtains an IP address on each port.
    log    STEP:5 Release 2 leases from the bound DHCP sessions from A and B.
    log    STEP:6 bind more than 2 new DHCP sessions (with different MAC) from A and B. only another 2 sessions can be bound on each port.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}    session=${lease_number_1}
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}    ${Qtag_vlan_2}    session=${lease_number_1}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Control Dhcp Client    tg1    ${group_name_2}    start

    tg save config into file   tg1   /tmp/${TEST NAME}.xml


    run keyword and ignore error    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    ${tmp}    evaluate    2*${lease_limit}
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    ${tmp}
    log    STEP:7 repeat step 1 and 2 for SVLAN Y and set lease limit for SVLAN Y to 6.
    log    STEP:8 bind more than 6 DHCP sessions from other SVLAN Y through A and B. 6 leases can be bound at A and B respectively.
    log    STEP:9 create UNI service X with uni service 1 (C -> S/C). DHCP snooping and option 82 insertion/removal enabled.
    log    STEP:10 create dhcp profile with lease_limit 5 and apply it to service X. Configuration takes
    log    STEP:11 Apply the above service to UNI port A and B.
    log    STEP:12 bind more than 5 subscribers to obtain an IP address via DHCP on the VLAN C through A and B. Only 5 subscribers obtains an IP address on each port.
    log    STEP:13 Release 2 leases from the bound DHCP sessions from A and B.
    log    STEP:14 bind more than 2 new DHCP sessions (with different MAC) from A and B. only another 2 sessions can be bound on each port.
    prov_dhcp_profile    eutA    ${l2_profile_name_2}    lease-limit ${lease_limit_2}
    Tg Control Dhcp Client    tg1    ${group_name}    stop
    sleep    ${stc_sleep_time}
    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    sleep    ${stc_sleep_time}
    Tg Control Dhcp Server    tg1    ${server_name}    stop
    Tg Delete Dhcp Client    tg1    ${client_name}
    Tg Delete Dhcp Server    tg1    ${server_name}
    Tg Delete Dhcp Client    tg1    ${client_name_2}
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    0
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${Qtag_vlan}    ${ctag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan_4}    session=${lease_number_2}
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}    ${Qtag_vlan_3}    session=${lease_number_2}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Control Dhcp Client    tg1    ${group_name_2}    start
    run keyword and ignore error    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    ${tmp}    evaluate    2*${lease_limit_2}
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    ${tmp}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=1
#    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${ctag_vlan}    cfg_prefix=3
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_3}    ${Qtag_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${ctag_vlan}    cfg_prefix=3
    subscriber_point_add_svc    subscriber_point2    ${Qtag_vlan_2}    ${stag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=2
#    subscriber_point_add_svc    subscriber_point2    ${Qtag_vlan}    ${Qtag_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${ctag_vlan}    cfg_prefix=4
    subscriber_point_add_svc    subscriber_point2    ${Qtag_vlan_4}    ${Qtag_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${ctag_vlan}    cfg_prefix=4

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name_2}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cfg_prefix=1
#    subscriber_point_remove_svc    subscriber_point2    ${Qtag_vlan_2}    ${stag_vlan}    cfg_prefix=2
    subscriber_point_remove_svc    subscriber_point2    ${Qtag_vlan_2}    ${stag_vlan}    cfg_prefix=2
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_3}    ${Qtag_vlan}    cevlan=${ctag_vlan}    cfg_prefix=3
#    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cevlan=${ctag_vlan}    cfg_prefix=3
    subscriber_point_remove_svc    subscriber_point2    ${Qtag_vlan_4}    ${Qtag_vlan}    cevlan=${ctag_vlan}    cfg_prefix=4
    prov_dhcp_profile    eutA    ${l2_profile_name}    no lease-limit
    prov_dhcp_profile    eutA    ${l2_profile_name_2}    no lease-limit