*** Settings ***
Documentation     The purpose of this test is to Checking G8032 with CFM switchtime.
...               1.Check g8032 ring with ccm meg mode Y1731
...               2.Shutdown interface ethernet
...               3.Check the ring switch time

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_G8032_Convergence_Phase2_Topology_Interconnected_ring_CCMs_fail_over_shut_down_the_link.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1995     @globalid=2329382    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]    The purpose of this test is to Checking G8032 with CFM switchtime.
    ...               1.Check g8032 ring with ccm meg mode Y1731
    ...               2.Shutdown interface ethernet
    ...               3.Check the ring switch time
    [Setup]      setup
    log     setup megs and chenge ccm interval level 1sec

    prov_meg           eutA    ${meg1}    ccm-interval=1sec
    prov_meg           eutA    ${meg2}    ccm-interval=1sec
    prov_meg           eutB    ${meg3}    ccm-interval=1sec
    prov_meg           eutB    ${meg4}    ccm-interval=1sec

    log     check g8032 status and should be no alarm
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log    STEP:1 config data service, run data services can get DHCP lease, dhcp bounded traffic is Ok
    create_dhcp_server    tg1    dhcps_stag    service_p1    ${server_mac}    ${server_ip}    ${pool_ip_start}    ${service_vlan}    lease_time=100
    create_dhcp_client    tg1    dhcpc_stag    subscriber_p1    grp_stag     ${client_mac}    ${subscriber_vlan}    session=1
    Tg Control Dhcp Server    tg1    dhcps_stag    start
    Tg Control Dhcp Client    tg1    grp_stag    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dhcps_stag    grp_stag    rate_pps=${rate_pps}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    grp_stag    dhcps_stag    rate_pps=${rate_pps}

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

    log    STEP:2 disable forwarding interface on master node, then enable it check packet loss
    Tg Clear Traffic Stats    tg1
    # wait 10s to clear traffic stats
    sleep    10s
    Tg Start All Traffic     tg1

    # wait 10s to start traffic
    sleep    ${traffic_run_time}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface2}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface2}
    wait until keyword succeeds    2 min    5 sec    check_interface_up    eutA    ethernet    ${service_model.service_point1.member.interface2}

    log     check g8032 status and should be no alarm
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     check G8032 switch time
    ${expect_max_pkts}    evaluate    ${rate_pps}*${ERPS_max_second_for_switch}

    Tg Stop All Traffic    tg1

    # wait to clear traffic stats
    sleep    ${stop_traffic_time}
    TG Verify Traffic Statistics Are Less Than    tg1    dropped_pkts    ${expect_max_pkts}

    log     success

    [Teardown]   teardown


*** Keywords ***
setup
    log     change wait-to-restore-time=1
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    wait-to-restore-time=1
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    wait-to-restore-time=1

    log     setup megs and check ccm mode Y1731

    prov_meg           eutA    ${meg1}    ${mep1}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg1}    remote-mep=${mep3}
    check_meg          eutA    ${meg1}    summary     mode    Y1731
    prov_meg           eutA    ${meg2}    ${mep2}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg2}    remote-mep=${mep4}
    check_meg          eutA    ${meg2}    summary     mode    Y1731
    prov_meg           eutB    ${meg3}    ${mep3}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg3}    remote-mep=${mep1}
    check_meg          eutB    ${meg3}    summary     mode    Y1731
    prov_meg           eutB    ${meg4}    ${mep4}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg4}    remote-mep=${mep2}
    check_meg          eutB    ${meg4}    summary     mode    Y1731

    log      assign megs to ethernet ports
    prov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface1}     ${service_model.service_point1.name}     ${EMPTY}    mep     ${meg1}    ${mep1}
    prov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface2}     ${service_model.service_point1.name}     ${EMPTY}    mep     ${meg2}    ${mep2}
    prov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface1}     ${service_model.service_point2.name}     ${EMPTY}    mep     ${meg3}    ${mep3}
    prov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface2}     ${service_model.service_point2.name}     ${EMPTY}    mep     ${meg4}    ${mep4}


teardown
    log      unassign megs to ethernet ports
    dprov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface1}      g8032_ring=${service_model.service_point1.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface2}      g8032_ring=${service_model.service_point1.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface1}      g8032_ring=${service_model.service_point2.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface2}      g8032_ring=${service_model.service_point2.name}     ccm-protection=${EMPTY}

    log     remove ccm and then check g8032 status again
    wait until keyword succeeds    1 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    1 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log      delete megs
    delete_config_object    eutA    meg    ${meg1}
    delete_config_object    eutA    meg    ${meg2}
    delete_config_object    eutB    meg    ${meg3}
    delete_config_object    eutB    meg    ${meg4}
