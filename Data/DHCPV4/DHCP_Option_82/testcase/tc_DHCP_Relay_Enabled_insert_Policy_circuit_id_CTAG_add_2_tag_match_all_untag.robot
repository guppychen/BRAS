*** Settings ***
Documentation     DHCP Relay Enabled insert Policy circuit-id %CTAG. add-2-tag match all untag
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Relay_Enabled_insert_Policy_circuit_id_CTAG_add_2_tag_match_all_untag
    [Documentation]    1	create svc: add-2-tag(add-cevlan-tag ) match all untag	success
    ...    2	Force an access subscriber(ethernet interface) to obtain IP address via DHCP and capture conversation forwarded from the SUT to the server. Uplink trunk is ethernet interface. -> Opt82 is inserted as circuit-id qtag	All Step action expected Results must be correct.For a dual tagged service, the inner tag VLAN id
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2150    @globalid=2343966    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create svc: add-2-tag(add-cevlan-tag ) match all untag success
    log    STEP:2 Force an access subscriber(ethernet interface) to obtain IP address via DHCP and capture conversation forwarded from the SUT to the server. Uplink trunk is ethernet interface. -> Opt82 is inserted as circuit-id qtag All Step action expected Results must be correct.For a dual tagged service, the inner tag VLAN id
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    ${ctag_vlan}    lease_time=100
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    ivlan=${ctag_vlan}
    stop_capture    tg1    service_p1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${ctag_vlan}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}    add-cevlan-tag    ${ctag_vlan}
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=%CTag

case teardown
    [Documentation]   case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}    ${ctag_vlan}
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id