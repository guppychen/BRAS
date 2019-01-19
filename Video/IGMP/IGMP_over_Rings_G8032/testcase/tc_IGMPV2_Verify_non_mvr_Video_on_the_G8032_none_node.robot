*** Settings ***
Documentation     (IGMPV2)Verify non_mvr Video on the G8032 none node
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${ring_service_point_list}    service_point_list4

*** Test Cases ***
tc_IGMPV2_Verify_non_mvr_Video_on_the_g8032_none_node    
    [Documentation]    Configure G8032 ring and IGMPv3 non_mvr on Topo1
    ...    1    Verify non_mvr Video on the G8032 none node	IPTV works fine
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1733    @globalid=2322261    @priority=P2    @user_interface=CLI    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    igmp_over_ring_non_mvr_provision    ${ring_service_point_list}
    [Teardown]    igmp_over_ring_non_mvr_deprovision    ${ring_service_point_list}
    [Template]    template_non_mvr_video
    ${igmp_version}    subscriber_point1    service_point_list2    ${p_ring_type}    ${ring_service_point_list}
