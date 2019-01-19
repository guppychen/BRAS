*** Settings ***
Documentation   Initialization file of IGMP_Proxy test suites
Suite Setup       igmp_proxy_suite_setup
Suite Teardown    igmp_proxy_suite_teardown
Force Tags        @feature=IGMP    @subfeature=IGMP Proxy   @eut=GPON-8r2
Resource          ./base.robot

*** Keywords ***
igmp_proxy_suite_setup
    [Documentation]    Enable the interface and verify it is up
    [Tags]               @author=CindyGao
    log    set eut version and release
    set_eut_version
    
    log    suite provision service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
	 
    log    create vlan
    prov_vlan    eutA    ${p_video_vlan}

    log    uplink side provision
    service_point_add_vlan    service_point_list1    ${p_video_vlan}
    service_point_prov_igmp    service_point_list1    ${p_igmp_prf}    ${p_proxy.intf_name}    ${p_proxy.ip}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_video_vlan}
    
    log    subscriber side provision
    prov_multicast_profile    eutA    ${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_video_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}  
     
igmp_proxy_suite_teardown
    [Documentation]    unconfigure_Performance Monitoring session and Grade of service profile
    [Tags]               @author=CindyGao
    log    suite deprovision subscriber_point deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_video_vlan}    mcast_profile=${p_mcast_prf}
    subscriber_point_dprov    subscriber_point1   
    subscriber_point_dprov    subscriber_point2

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
	
    log    uplink side deprovision
    service_point_dprov_igmp    service_point_list1    ${p_igmp_prf}    ${p_proxy.intf_name}    ${p_video_vlan}
    service_point_remove_vlan    service_point_list1    ${p_video_vlan}
	
    log    service_point remove_svc deprovision
    service_point_dprov    service_point_list1
	
    log    delete vlan
    delete_config_object    eutA    vlan    ${p_video_vlan}
     

# case setup
    # log    case setup: subscriber side provision
    # prov_multicast_profile    eutA    ${p_mcast_prf}
    # subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_video_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}  

# case teardown
    # log    case teardown: subscriber side deprovision
    # subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_video_vlan}    mcast_profile=${p_mcast_prf}
    # log    delete multicast profile
    # delete_config_object    eutA    multicast-profile    ${p_mcast_prf}