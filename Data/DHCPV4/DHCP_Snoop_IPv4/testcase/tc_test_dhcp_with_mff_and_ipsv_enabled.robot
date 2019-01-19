*** Settings ***
Documentation     test dhcp with mff and ipsv enabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_test_dhcp_with_mff_and_ipsv_enabled
    [Documentation]    1	enable mff and ipsv on vlan, and enable dhcp snoop	success
    ...    2	create svc on ont-ethernet port with this vlan	success
    ...    3	get dhcp leases	can get dhcp lease ,and bounded traffic can flow
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-1826    @feature=DHCPV4    @globalid=2322401    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-1826 setup
    [Teardown]   AXOS_E72_PARENT-TC-1826 teardown
    log    STEP:1 enable mff and ipsv on vlan, and enable dhcp snoop success
    prov_vlan    eutA    ${stag_vlan}    mac-learning=enable    source-verify=enable
    log    STEP:2 create svc on ont-ethernet port with this vlan success
    log    STEP:3 get dhcp leases can get dhcp lease ,and bounded traffic can flow
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}   lease_time=10000
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
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
    #TG Verify No Traffic Loss For All Streams    tg1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}

*** Keywords ***
AXOS_E72_PARENT-TC-1826 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1826 setup
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}


AXOS_E72_PARENT-TC-1826 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1826 teardown
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}