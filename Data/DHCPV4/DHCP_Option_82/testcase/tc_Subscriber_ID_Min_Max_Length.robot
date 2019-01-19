*** Settings ***
Documentation     Subscriber ID Min/Max Length
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_ID_Min_Max_Length
    [Documentation]    1	Create service with target tag-action	Succeed
    ...    2	Force a client to obtain a dynamic address	Opt82 is inserted into DHCP frames with Remote ID and valid circuit ID
    ...    3	Capture the DHCP conversation	Opt 82 is removed from DHCP frames forwarded to client
    ...    4	The Subscriber ID value is provisioned with the maximum length of 63 characters	Opt82 is inserted into DHCP frames with Remote ID and valid circuit ID
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2213    @globalid=2344029    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Create service with target tag-action Succeed
    log    STEP:2 Force a client to obtain a dynamic address Opt82 is inserted into DHCP frames with Remote ID and valid circuit ID
    log    STEP:3 Capture the DHCP conversation Opt 82 is removed from DHCP frames forwarded to client
    log    STEP:4 The Subscriber ID value is provisioned with the maximum length of 63 characters Opt82 is inserted into DHCP frames with Remote ID and valid circuit ID
    configure_interface_ont_ethernet    eutA    ${service_model.subscriber_point1.name}   subscriber-id=Text:Text:Text:Text:Text:Text:Text:Text:Text:Text:Text:Text:T
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    check_dhcp_option82_circuit_id    tg1    service_p1    Text:Text:Text:Text:Text:Text:Text:Text:Text:Text:Text:Text:T


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=%Desc

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    delete_interface_ont_ethernet_configuration    eutA    ${service_model.subscriber_point1.name}    subscriber-id
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id