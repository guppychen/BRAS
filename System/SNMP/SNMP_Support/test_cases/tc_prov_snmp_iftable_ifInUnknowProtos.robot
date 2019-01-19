*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_iftable_ifInUnknownProtos
    [Documentation]    prov snmp v2 iftable_ifInUnknownProtos
    [Tags]    @author=Sean Wang    @globalid=2358304   @tcid=AXOS_E72_PARENT-TC-2416    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p2    p1      vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512
    ...    length_mode=fixed    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ARP    ip_src_addr=${ip1}    ip_dst_addr=${ip2}
    ...    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    
    log    start traffic to lean mac on device
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    
    
    ${admin}    cli    eutA    show interface ethernet ${service_model.service_point1.member.interface1} counters
    ${re_m}    ${re_UnknownProtos}    should match regexp    ${admin}    rx-unknown-protos\\s+(\\d+)
    ${result}=    snmp get    eutA_snmp_v2    ifInUnknownProtos.${port_1_oid}
    ${re}    Convert To Integer    ${result}
    Should be true    ${re}-${re_UnknownProtos}>=0

    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    snmp
    snmp_admin    eutA    enable
    log     ${service_model.service_point1.member.interface1}
    service_point_prov    service_point_list1
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}

case teardown
    log    Enter case teardown
    # Axos Cli With Error Check   eutA    v2 admin-state disable
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_dprov    service_point_list1
    delete_config_object    eutA    vlan    ${service_vlan}
    
snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end
