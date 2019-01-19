*** Settings ***
Documentation     renewal time shorter than 30 minutes
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_renewal_time_shorter_than_30_minutes
    [Documentation]    1	Setup Dhcp on cards, lease duration 10 minutes. Wait and check saved lease file after lease renewal -> lease updated correctly.	All Step action expected Results must be correct	http://jira.calix.local/browse/EXA-20804
    ...    2	reboot card ,and check l3-host after card boot up	dhcp lease shorter than 30 minutes is not existed
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2103    @globalid=2343914    @subfeature=DHCP_Lease_Persistence    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Setup Dhcp on cards, lease duration 10 minutes. Wait and check saved lease file after lease renewal -> lease updated correctly. All Step action expected Results must be correct http://jira.calix.local/browse/EXA-20804
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:2 reboot card ,and check l3-host after card boot up dhcp lease shorter than 30 minutes is not existed
    Reload System    eutA
    check_l3_hosts    eutA    0


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    Wait Until Keyword Succeeds    ${wait_ont_card_up_time}    30s  Verify Cmd Working After Reload
    ...    eutA    show version
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    cli    eutA    copy running-config startup-config