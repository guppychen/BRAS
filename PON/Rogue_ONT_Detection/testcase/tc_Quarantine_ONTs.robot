*** Settings ***
Documentation     The purpose of this test case is to Verify that an ONT can be manually quarantined.
...               1.Create ont
...               2.add ont to quarantined-ont
...               3.Check quarantined-ont
...               4.Check all traffics loss

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Quarantine_ONTs.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-3509    @user_interface=CLI      @globalid=2487604    @eut=GPON-8r2    @feature=ONT Support    @subfeature=Rouge ONT    @author=pzhang
    [Documentation]   The purpose of this test case is to Verify that an ONT can be manually quarantined.
    ...               1.Create ont
    ...               2.add ont to quarantined-ont
    ...               3.Check quarantined-ont
    ...               4.Check all traffics loss
    [Setup]      setup

    log     Check quarantined-ont
    check_quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}    manual

    log     discover_ont is unull
    Wait Until Keyword Succeeds   1 min  2s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=missing
    log      remove ont from quarantined-ont
    quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}    no

    log     ONT is discover
    Wait Until Keyword Succeeds    1 min  2s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present


    log    STEP:1 config data service, run data services can get DHCP lease, dhcp bounded traffic is Ok
    create_dhcp_server    tg1    dhcps_stag    service_p1    ${server_mac}    ${server_ip}    ${pool_ip_start}    ${service_vlan}    lease_time=100
    create_dhcp_client    tg1    dhcpc_stag    subscriber_p1    grp_stag     ${client_mac}    ${subscriber_vlan}    session=1
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dhcps_stag    grp_stag    rate_pps=${rate_pps}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    grp_stag    dhcps_stag    rate_pps=${rate_pps}

    Tg Control Dhcp Server    tg1    dhcps_stag    start
    Tg Control Dhcp Client    tg1    grp_stag    start
    tg save config into file   tg1   /tmp/${TEST NAME}.xml
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}

    log    check traffic can pass without loss
    Tg Start All Traffic     tg1
    # wait to start traffic
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1

    # wait to start traffic
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1

    # wait 10s to clear traffic stats
    sleep    ${stop_traffic_time}

    tg_verify_traffic_loss_for_stream_is_within    tg1    dhcp_upstream    ${lost_rate}
    tg_verify_traffic_loss_for_stream_is_within    tg1    dhcp_downstream    ${lost_rate}
    [Teardown]   teardown


*** Keywords ***
setup
   [Documentation]    setup
    Wait Until Keyword Succeeds   1 min  5s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    log     add ont to quarantined-ont
    quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}


teardown
    [Documentation]    teardown
    log      remove ont from quarantined-ont
    Run Keyword And Ignore Error    quarantine_ont    eutA    ${service_model.subscriber_point1.attribute.vendor_id}    ${service_model.subscriber_point1.attribute.serial_number}    no
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1