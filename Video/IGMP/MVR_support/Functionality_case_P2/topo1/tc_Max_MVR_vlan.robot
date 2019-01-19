*** Settings ***
Documentation     Calix MVR shall support mapping up to 4 Video VLAN per subscriber data service VLAN
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Layer3_Applications_Video_Max_MVR_vlan
    [Documentation]    1	Configure a trunk port with all the MVR vlans	Trunk port with all vlans should be created	Use the command "show bridge table" to verify	
    ...    2	Configure STC port with 4 IGMP quirier with the corresponding MVR vlans	Trunk port should become router port and in HAPPY state	Use the command "show igmp ports" and "show igmp domains"to verify	
    ...    3	Send multicast streams with the MVR muticast address range and associated vlan from the same STC port			
    ...    4	Configure an MVR profile that uses 4 vlans with different multicast address range	The profile is accepted		
    ...    5	Configure UNI service with a vlan other than the MVR vlans and apply the mvr and mcast profile	UNI service should be created	configure several service use mvr vlans and provision same profile gli# show running-config mvr-profile mv mvr-profile mv address 225.1.1.1 225.1.1.1 790 address 255.1.1.3 255.1.1.3 791 service-instance 790 790 790 service-instance 791 791 790 http://jira.calix.local/browse/EXA-13798	
    ...    6	Join the muticast group of all 4 vlans	Able to join the multicast group	Use wireshark and cature ithe IGMP joins make sure it has the correct vlan 	
    ...    7	Configure a trunk port with the service vlan			
    ...    8	Send Bidirectional unicast traffic on the UNI port			
    ...    9	Using wireshark capture the packets on the trunk port with service vlan	Unicast traffic should be received with the service vlan	
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1441    @globalid=2321509    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Template]    template_mvr_video
    ${p_igmp_version}    subscriber_point1    service_point_list1
