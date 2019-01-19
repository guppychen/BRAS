*** Settings ***
Documentation     Note that a single tagged VLAN may be transmitted out the subscriber port untagged.
Resource          ./base.robot


*** Variables ***
${igmp_version}    v2

*** Test Cases ***
tc_MVR_support_mapping_video_VLAN_to_data_service_VLAN
    [Documentation]    1	Configure a trunk port with all the MVR vlans	Trunk port with all vlans should be created	Use the command "show bridge table" to verify
    ...    2	Configure STC port with 4 IGMP quirier with the corresponding MVR vlans	Trunk port should become router port and in HAPPY state	Use the command "show igmp ports" and "show igmp domains"to verify
    ...    3	Send multicast streams with the MVR muticast address range and associated vlan from the same STC port		
    ...    4	Configure an MVR profile that uses 4 vlans with different multicast address range	The profile is accepted	
    ...    5	Configure UNI service with a vlan other than the MVR vlans and apply the mvr and mcast profile	UNI service should be created	
    ...    6	Join the muticast group of all 4 vlans	Able to join the multicast group	Use wireshark and cature ithe IGMP joins make sure it has the correct vlan
    ...    7	Configure a trunk port with the service vlan		
    ...    8	Send Bidirectional unicast traffic on the UNI port		
    ...    9	Using wireshark capture the packets on the trunk port with service vlan	Unicast traffic should be received with the service vlan	
    ...    10	Using wireshark capture the packets on the uni port	Unicast traffic should be received untagged	
    ...    11	Remove service from the uni port	Remove operation should be successful	
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1443    @globalid=2321511    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    
    [Template]    template_mvr_video
    ${igmp_version}    subscriber_point1    service_point_list1
