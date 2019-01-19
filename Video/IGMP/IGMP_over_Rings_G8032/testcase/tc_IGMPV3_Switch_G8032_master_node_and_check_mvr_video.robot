*** Settings ***
Documentation     (IGMPV3)Switch G8032 master node and check mvr video
Resource          ./base.robot

*** Variables ***
${igmp_version}    v3
${ring_service_point_list}    service_point_list1
${switch_port}    ${service_model.service_point1.member.interface2}  

*** Test Cases ***
tc_IGMPV3_Switch_G8032_master_node_and_check_mvr_video 
    [Documentation]    Configure G8032 ring and IGMPv3 mvr on Topo1
    ...    1    Switch G8032 master node and check mvr video	IPTV works fine
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1739    @globalid=2322267    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    igmp_over_ring_mvr_provision    ${ring_service_point_list}
    [Teardown]    igmp_over_ring_mvr_deprovision    ${ring_service_point_list}
    [Template]    template_ring_switch_mvr_video
    ${igmp_version}    subscriber_point1    service_point_list2    ${p_ring_type}    ${ring_service_point_list}    ${switch_port}   
