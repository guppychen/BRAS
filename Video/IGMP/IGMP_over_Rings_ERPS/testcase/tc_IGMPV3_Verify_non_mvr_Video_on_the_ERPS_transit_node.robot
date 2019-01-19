*** Settings ***
Documentation     (IGMPV3)Verify non-mvr Video on the ERPS transit node
Resource          ./base.robot

*** Variables ***
${igmp_version}    v3
${ring_service_point_list}    service_point_list3

*** Test Cases ***
tc_IGMPV3_Verify_non_mvr_Video_on_the_ERPS_transit_node    
    [Documentation]    Configure ERPS ring and IGMPv3 non-mvr on Topo1
    ...    1    Verify non-mvr Video on the ERPS transit node	IPTV works fine
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1839    @globalid=2324431    @priority=P2    @user_interface=CLI    @eut=NGPON2-4    @ticket=21518    @eut=GPON-8r2
    [Setup]    igmp_over_ring_non_mvr_provision    ${ring_service_point_list}
    [Teardown]    igmp_over_ring_non_mvr_deprovision    ${ring_service_point_list}
    [Template]    template_non_mvr_video
    ${igmp_version}    subscriber_point1    service_point_list2    ${p_ring_type}    ${ring_service_point_list}
