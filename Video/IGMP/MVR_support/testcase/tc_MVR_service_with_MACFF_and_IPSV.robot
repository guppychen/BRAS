*** Settings ***
Documentation     verfify the mvr service with MACFF and IPSV
Resource          ./base.robot


*** Variables ***
${igmp_version}    v2

*** Test Cases ***
tc_MVR_service_with_MACFF_and_IPSV
    [Documentation]    1	Create service vlan, create igmp profile, set vlan igmp mode proxy, version v2, add the service vlan to uplink port	success	
    ...    2	enable MACFF and IPSV for service vlan	success	
    ...    3	create mcast vlan, set igmp profile, add mcast vlan to uplink port	success	
    ...    4	create mvr profile and set the range of group with mcast vlan	success	
    ...    5	create multicast-profile and set the mvr-profile	success	
    ...    6	configure the multicast-profile for ont-port	success	
    ...    7	create the dhcp client and dhcp server for service vlan	success	
    ...    8	start the dhcp server and dhcp client	The client get the IP address.	
    ...    9	generate the bi-directional unicast traffic for the client	the traffic works well	
    ...    10	start the IGMP query at uplink	The igmp router summary can be shown with the right vlan	
    ...    11	generate the downstream multicast stream for the groups in the range of mvr profile	the client cannot receive the traffic	
    ...    12	make the client join the groups	the igmp group can be shown. The client can receive the multicast traffic	
    ...    13	the client leaves the groups	the igmp group cannot be shown and the traffic does not work.
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1476    @globalid=2321545    @priority=P1    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown   
    [Template]    template_mvr_video
    ${igmp_version}    subscriber_point1    service_point_list1

*** Keywords ***
case setup
    [Documentation]    case setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${p_dhcp_prf}
    log    enable MACFF and IPSV for service vlan
    prov_vlan    eutA    ${p_data_vlan}    ${p_dhcp_prf}    source-verify=enable    mff=enable
    : FOR    ${video_vlan}    IN    @{p_video_vlan_list}
    \    prov_vlan    eutA    ${video_vlan}    ${p_dhcp_prf}    source-verify=enable    mff=enable

case teardown
    [Documentation]    case teardown
    log    disable MACFF and IPSV for service vlan
    prov_vlan    eutA    ${p_data_vlan}    source-verify=disable    mff=disable
    dprov_vlan    eutA    ${p_data_vlan}    l2-dhcp-profile
    : FOR    ${video_vlan}    IN    @{p_video_vlan_list}
    \    prov_vlan    eutA    ${video_vlan}    source-verify=disable    mff=disable
    \    dprov_vlan    eutA    ${video_vlan}    l2-dhcp-profile
    log    delete dhcp-profile
    delete_config_object    eutA    l2-dhcp-profile    ${p_dhcp_prf}