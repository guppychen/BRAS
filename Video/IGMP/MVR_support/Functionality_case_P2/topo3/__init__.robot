*** Settings ***
Documentation     Initialization file test suites for mvr topo3
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       mvr_suite_provision
Suite Teardown    mvr_suite_deprovision
Force Tags        @feature=IGMP    @subfeature=MVR support    @author=CindyGao    @topo=2pon2ont
Resource          ./base.robot

*** Variables ***


*** Keywords ***
mvr_suite_provision
    [Documentation]    suite provision for MVR support
    [Tags]       @author=CindyGao
    log    set eut version and release
    set_eut_version
    
    log    suite provision service_point_provision for uplink side
    service_point_prov    service_point_list1
    
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    log    sleep for cli operation response
    sleep    5s
    subscriber_point_prov    subscriber_point3
    
    log    create vlan
    prov_vlan    eutA    ${p_data_vlan}
    : FOR    ${video_vlan}    IN    @{p_video_vlan_list}
    \    prov_vlan    eutA    ${video_vlan}

    log    uplink side provision
    service_point_add_vlan    service_point_list1    ${p_data_vlan},@{p_video_vlan_list}[0]-@{p_video_vlan_list}[-1]
    service_point_prov_igmp    service_point_list1    ${p_igmp_prf}    ${p_proxy.intf_name}    ${p_proxy.ip}    ${p_proxy.mask}    ${p_proxy.gw}    @{p_video_vlan_list}

    log    create test suite global variable
    Set Global Variable    @{p_mvr_network_list}    @{EMPTY}
    Set Global Variable    @{p_mvr_start_ip_list}    @{EMPTY}
    Set Global Variable    @{p_mvr_end_ip_list}    @{EMPTY}
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_vlan_num}+1
    \    Append To List    ${p_mvr_network_list}    225.${index}.1
    \    Append To List    ${p_mvr_start_ip_list}    225.${index}.1.${p_mc_grp_start_idx}
    \    Append To List    ${p_mvr_end_ip_list}    225.${index}.1.${p_mc_grp_end_idx}

mvr_suite_deprovision
    [Documentation]    suite deprovision for MVR support
    [Tags]       @author=CindyGao
    log    suite deprovision subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1   
    log    sleep for cli operation response
    sleep    5s
    subscriber_point_dprov    subscriber_point3
    
    log    uplink side deprovision
    service_point_dprov_igmp    service_point_list1    ${p_igmp_prf}    ${p_proxy.intf_name}    @{p_video_vlan_list}
    service_point_remove_vlan    service_point_list1    ${p_data_vlan},@{p_video_vlan_list}[0]-@{p_video_vlan_list}[-1]
    
    log    service_point remove_svc deprovision
    service_point_dprov    service_point_list1
    
    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan}
    : FOR    ${video_vlan}    IN    @{p_video_vlan_list}
    \    delete_config_object    eutA    vlan    ${video_vlan}
    
    
    