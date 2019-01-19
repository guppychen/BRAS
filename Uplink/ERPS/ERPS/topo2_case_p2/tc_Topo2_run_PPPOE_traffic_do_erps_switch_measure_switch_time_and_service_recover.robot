*** Settings ***
Documentation     1.Configure two ERPS ring with three nodes
...    2.Configure data service through erps ring
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_Topo1_run_PPPOE_traffic_do_erps_switch_measure_switch_time_and_service_recover
    [Documentation]    1	set up pppoe session	Verify traffic flow between each node.
    ...    2	disable forwarding interface on master node	traffis loss <1s,and noop
    ...    3	show erps ring status	Correct
    ...    4	enable interface	alarm cleared ,and erps-domain switchback , traffic loss <1s,and no loop
    ...    5	show erps ring status	Recover
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1278    @globalid=2319028    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 set up pppoe session Verify traffic flow between each node.
    log    create PPPoE server and client on STC
    TG Create Pppoe v4 Server On Port   tg1    ppps    service_p1    encap=ethernet_ii_vlan    vlan_id=${service_vlan}    vlan_user_priority=0
    ...    vlan_outer_user_priority=0    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port    tg1    pppc    subscriber_p1    encap=ethernet_ii_vlan    vlan_id=${subscriber_vlan}    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${client_mac}
    Tg Control Pppox By Name    tg1    ppps    connect
    Tg Control Pppox By Name    tg1    pppc    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${pppoe_negotiated_time}

    log    create upstream and downstream flow
    Tg Create Bound Untagged Stream On Port    tg1    upstream    subscriber_p1    ppps    pppc    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed
    Tg Create Bound Untagged Stream On Port    tg1    downstream    service_p1    pppc    ppps    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed

    log    check all traffic can pass
    Tg Start All Traffic     tg1
    # wait time to make traffic stable
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${stop_traffic_time}
    TG Verify No Traffic Loss For All Streams    tg1
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${ERPS_max_second_for_switch}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${ERPS_max_second_for_switch}

    
    log    STEP:2 disable forwarding interface on master node traffis loss <1s,and noop
    Tg Start All Traffic     tg1
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${ERPS_max_second_for_switch}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${ERPS_max_second_for_switch}

    log    STEP:3 show erps ring status correct
    check_erps_ring_status    ${service_model.service_point1.device}    ${service_model.service_point1.name}    secondary-interface-fwd-state=forwarding

    log    STEP:4 enable interface alarm cleared ,and erps-domain switchback , traffic loss <1s,and no loop
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${ERPS_max_second_for_switch}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${ERPS_max_second_for_switch}

    log    STEP:5 show erps ring status Recover
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_status    ${service_model.service_point1.device}    ${service_model.service_point1.name}    primary-interface-fwd-state=forwarding


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    service_point_prov    service_point_list1
    service_point_prov    service_point_list2
    service_point_prov    service_point_list3
    
    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1
    service_point_list_check_status_up    service_point_list2    
    log    Configure data service through erps ring
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    log    create id-profile
    \    prov_id_profile    ${service_model.${erps_node}.device}    ${id_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    pppoe-ia-id-profile=${id_profile_name}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list2}
    \    log    create id-profile
    \    prov_id_profile    ${service_model.${erps_node}.device}    ${id_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    pppoe-ia-id-profile=${id_profile_name}
    
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list2    ${service_vlan}
    service_point_add_vlan    service_point_list3    ${service_vlan}
    
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_prov    subscriber_point1
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


case teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    Tg Control Pppox By Name    tg1    pppc    disconnect
    Tg Control Pppox By Name    tg1    ppps    disconnect    
    TG Delete PPPoE v4 Client On Port    tg1    pppc    subscriber_p1
    TG Delete PPPoE v4 Server On Port    tg1    ppps    service_p1
    Tg Delete All Traffic    tg1
    
    log    remove service on ont-port
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    subscriber_point_dprov    subscriber_point1
    
    log    remove all of the erps interface from service vlan and delete related service profile
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list2    ${service_vlan}
    service_point_remove_vlan    service_point_list3    ${service_vlan}    
    
    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2
    service_point_dprov    service_point_list3
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${erps_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${erps_node}.device}    id-profile    ${id_profile_name}
    delete_config_object    eutB    vlan    ${service_vlan}
    delete_config_object    eutB    id-profile    ${id_profile_name}