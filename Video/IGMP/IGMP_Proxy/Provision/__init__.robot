*** Settings ***
Documentation   Initialization file of IGMP_Proxy test suites
Suite Setup       igmp_proxy_suite_setup
Suite Teardown    igmp_proxy_suite_teardown
Force Tags        @feature=IGMP    @subfeature=IGMP Proxy  @eut=1ont   @eut=GPON-8r2
Resource          ./base.robot

*** Keywords ***
igmp_proxy_suite_setup
     [Documentation]    Enable the interface and verify it is up
     [Tags]               @author=llim
	 log    subscriber_point_operation for subscriber side
	 subscriber_point_prov    subscriber_point1
	 log    create vlan
	 prov_vlan    eutA    ${p_data_vlan}
	 prov_vlan    eutA    ${p_video_vlan}
     
igmp_proxy_suite_teardown
     [Documentation]    unconfigure_Performance Monitoring session and Grade of service profile
     [Tags]               @author=llim
     log    suite deprovision subscriber_point deprovision
 	 subscriber_point_dprov    subscriber_point1   
	 log    delete vlan
	 delete_config_object    eutA    vlan    ${p_data_vlan}
	 delete_config_object    eutA    vlan    ${p_video_vlan}
     
