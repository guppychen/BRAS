*** Settings ***
Documentation     (IGMPV2)Verify non-mvr Video on the G8032 master node
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${ring_service_point_list}    service_point_list1

*** Test Cases ***
tc_IGMPV2_Verify_non_mvr_Video_on_the_g8032_master_node    
    [Documentation]    Configure G8032 ring and IGMPv2 non-mvr on Topo1
    ...    1    Verify non-mvr Video on the G8032 master node	IPTV works fine
    [Setup]    igmp_over_ring_non_mvr_provision    ${ring_service_point_list}
    [Teardown]    igmp_over_ring_non_mvr_deprovision    ${ring_service_point_list}
    [Template]    template_non_mvr_video
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1725    @globalid=2322253    @priority=P2    @user_interface=CLI    @eut=NGPON2-4    @eut=GPON-8r2
    ${igmp_version}    subscriber_point1    service_point_list2    ${p_ring_type}    ${ring_service_point_list}
