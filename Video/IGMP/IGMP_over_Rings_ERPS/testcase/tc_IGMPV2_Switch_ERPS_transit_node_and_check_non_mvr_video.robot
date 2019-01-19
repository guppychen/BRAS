*** Settings ***
Documentation     (IGMPV2)Switch ERPS transit node and check non-mvr video
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${ring_service_point_list}    service_point_list3
${switch_port}    ${service_model.service_point5.member.interface2} 

*** Test Cases ***
tc_IGMPV2_Switch_ERPS_transit_node_and_check_non_mvr_video    
    [Documentation]    Configure ERPS ring and IGMPv2 non-mvr on Topo1
    ...    1    Switch ERPS transit node and check non-mvr video	IPTV works fine
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1834    @globalid=2324426    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    igmp_over_ring_non_mvr_provision    ${ring_service_point_list}
    [Teardown]    igmp_over_ring_non_mvr_deprovision    ${ring_service_point_list}
    [Template]    template_ring_switch_non_mvr_video
    ${igmp_version}    subscriber_point1    service_point_list2    ${p_ring_type}    ${ring_service_point_list}    ${switch_port}