*** Settings ***
Documentation     Snoop Per-Port-per-vlan Lease Limit independent of any static hosts
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Snoop_Per_Port_per_vlan_Lease_Limit_independent_of_any_static_hosts
    [Documentation]    1	Enable DHCP snoop.	DHCP snoop enabled
    ...    2	Configure DHCP lease limit to 5 per VLAN and per PORT. 	Configuration takes.
    ...    3	Add a static DHCP entry into the snoop data base with the same vlan and port.	configuration takes.
    ...    4	Force 5 subscribers to obtain an IP address via DHCP on the same port as the static host and VLAN.	Subscribers initiate DHCP transaction and obtains an IP address.
    ...    5	Force another subscriber to obtain an IP address via DHCP on the same port and VLAN as configured above.	Subscriber initiates DHCP transaction but does not obtain an IP address. Lease limit exceeded.
    ...    6	Release one of 5 subscriber leases.	configuration takes
    ...    7	Force two subscriber to obtain an IP address via DHCP on the same port and VLAN.	Only one subscriber obtains an IP address. Verify DHCP lease database.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2095    @globalid=2343903    @subfeature=DHCP_Lease_Limits    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable DHCP snoop. DHCP snoop enabled
    log    STEP:2 Configure DHCP lease limit to 5 per VLAN and per PORT. Configuration takes.
    prov_dhcp_profile    eutA    ${l2_profile_name}    lease-limit ${lease_limit}
    log    STEP:3 Add a static DHCP entry into the snoop data base with the same vlan and port. configuration takes.
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${stag_vlan}    ${lease_start}    gateway1 ${server_ip} mac ${client_mac}
    log    STEP:4 Force 5 subscribers to obtain an IP address via DHCP on the same port as the static host and VLAN. Subscribers initiate DHCP transaction and obtains an IP address.
    log    STEP:5 Force another subscriber to obtain an IP address via DHCP on the same port and VLAN as configured above. Subscriber initiates DHCP transaction but does not obtain an IP address. Lease limit exceeded.
    log    STEP:6 Release one of 5 subscriber leases. configuration takes
    log    STEP:7 Force two subscriber to obtain an IP address via DHCP on the same port and VLAN. Only one subscriber obtains an IP address. Verify DHCP lease database.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac_2}    ${Qtag_vlan}    session=${lease_number_1}
    Tg Control Dhcp Server    tg1    ${server_name}    start
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
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${stag_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cfg_prefix=1
    prov_dhcp_profile    eutA    ${l2_profile_name}    no lease-limit