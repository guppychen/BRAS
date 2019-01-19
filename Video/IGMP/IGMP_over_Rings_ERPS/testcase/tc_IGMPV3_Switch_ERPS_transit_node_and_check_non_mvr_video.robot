*** Settings ***
Documentation     (IGMPV3)Switch ERPS transit node and check non-mvr video
Resource          ./base.robot

*** Variables ***
${igmp_version}    v3
${ring_service_point_list}    service_point_list3
${switch_port}    ${service_model.service_point5.member.interface2} 

*** Test Cases ***
tc_IGMPV3_Switch_ERPS_transit_node_and_check_non_mvr_video    
    [Documentation]    Configure ERPS ring and IGMPv3 non-mvr on Topo1
    ...    1    Switch ERPS transit node and check non-mvr video	IPTV works fine
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1842    @globalid=2324434    @priority=P2    @user_interface=CLI    @eut=NGPON2-4    @ticket=21518    @eut=GPON-8r2
    [Setup]    igmp_over_ring_non_mvr_provision    ${ring_service_point_list}
    [Teardown]    igmp_over_ring_non_mvr_deprovision    ${ring_service_point_list}
    [Template]    template_ring_switch_non_mvr_video
    ${igmp_version}    subscriber_point1    service_point_list2    ${p_ring_type}    ${ring_service_point_list}    ${switch_port}