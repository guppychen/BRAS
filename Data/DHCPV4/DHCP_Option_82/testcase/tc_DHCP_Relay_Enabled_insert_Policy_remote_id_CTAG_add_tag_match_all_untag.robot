*** Settings ***
Documentation     DHCP Relay Enabled insert Policy remote-id %CTAG. add-tag match all untag
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Relay_Enabled_insert_Policy_remote_id_CTAG_add_tag_match_all_untag
    [Documentation]    1	create svc: add-tag match all untag, 	success
    ...    2	Force an access subscriber(ethernet interface) to obtain IP address via DHCP and capture conversation forwarded from the SUT to the server. Uplink trunk is ethernet interface. -> Opt82 is inserted as remote-id qtag	All Step action expected Results must be correct.For a dual tagged service, the inner tag VLAN id
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2174    @globalid=2343990    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create svc: add-tag match all untag, success
    log    STEP:2 Force an access subscriber(ethernet interface) to obtain IP address via DHCP and capture conversation forwarded from the SUT to the server. Uplink trunk is ethernet interface. -> Opt82 is inserted as remote-id qtag All Step action expected Results must be correct.For a dual tagged service, the inner tag VLAN id
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}   lease_time=10000
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    check_dhcp_option82_remote_id    tg1    service_p1    ${hostname}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    prov_class_map    eutA    ${class_map_name}    ethernet    flow     1    1    any=
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    flow     1
    subscriber_point_add_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    prov_id_profile    eutA    ${id_profile_name}    remote-id=%CTag%Hostname

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    stop STC
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ethernet ${class_map_name}
    dprov_id_profile    eutA    ${id_profile_name}    option=remote-id