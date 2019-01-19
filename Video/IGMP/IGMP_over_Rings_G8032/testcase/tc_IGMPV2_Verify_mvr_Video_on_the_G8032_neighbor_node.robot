*** Settings ***
Documentation     (IGMPV2)Verify mvr Video on the G8032 neighbor node
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${ring_service_point_list}    service_point_list3

*** Test Cases ***
tc_IGMPV2_Verify_mvr_Video_on_the_g8032_neighbor_node    
    [Documentation]    Configure G8032 ring and IGMPv2 mvr on Topo1
    ...    1    Verify mvr Video on the G8032 neighbor node	IPTV works fine
    [Setup]    igmp_over_ring_mvr_provision    ${ring_service_point_list}
    [Teardown]    igmp_over_ring_mvr_deprovision    ${ring_service_point_list}
    [Template]    template_mvr_video
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1730    @globalid=2322258    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    @eut=GPON-8r2
    ${igmp_version}    subscriber_point1    service_point_list2    ${p_ring_type}    ${ring_service_point_list}
