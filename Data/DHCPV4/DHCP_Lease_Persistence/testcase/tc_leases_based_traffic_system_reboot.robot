*** Settings ***
Documentation     leases based traffic, system reboot
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_leases_based_traffic_system_reboot
    [Documentation]    1	Setup some Dhcp leases and leases-based traffic on card. Reboot system, check leases and traffic after it back -> leases and traffic recover correctly.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2105    @globalid=2343916    @subfeature=DHCP_Lease_Persistence    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Setup some Dhcp leases and leases-based traffic on card. Reboot system, check leases and traffic after it back -> leases and traffic recover correctly. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time_2}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    log    reload system
    Tg Start Arp Nd On All Devices    tg1
    tg_start_arp_nd_on_all_stream_blocks    tg1
    Tg Start All Traffic     tg1
    Reload System    eutA
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    sleep    ${STC_wait_time}
    Tg Start Arp Nd On All Devices    tg1
    tg_start_arp_nd_on_all_stream_blocks    tg1
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    Tg Store Captured Packets    tg1    service_p1    /tmp/${TEST NAME}.pcap
    Tg Store Captured Packets    tg1    subscriber_p1    /tmp/${TEST NAME}2.pcap
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    Wait Until Keyword Succeeds    ${wait_ont_card_up_time}    30s  Verify Cmd Working After Reload
    ...    eutA    show version
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    cli    eutA    copy running-config startup-config