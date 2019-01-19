*** Settings ***
Documentation     Subscriber Side VLAN Membership Single Tagged Subscriber Traffic
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_Side_VLAN_Membership_Single_Tagged_Subscriber_Traffic
    [Documentation]    1	Subscriber Side VLAN Membership Single Tagged Subscriber Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a Subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The Subscriber obtains an address. The Subscriber address is listed as a DHCP snoop entry.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-739    @globalid=2307083    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Subscriber Side VLAN Membership Single Tagged Subscriber Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a Subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The Subscriber obtains an address. The Subscriber address is listed as a DHCP snoop entry. All Step action expected Results must be corrects listed as a DHCP snoop entry. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=100
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Save Config Into File    tg1     /tmp/stream.xml
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}