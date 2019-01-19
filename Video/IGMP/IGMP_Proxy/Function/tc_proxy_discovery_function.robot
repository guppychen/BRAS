*** Settings ***
Documentation     Test suite verifies IGMP V2 proxy-discovery function 
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute}    proxy-discovery
${default_value}    ${p_dflt_igmp_proxy_discovery}
${new_value}    DISABLED

*** Test Cases ***
tc_proxy_discovery_function
    [Documentation]    1	send igmp query per vlan	successful		
    ...    2	retrieve the multicast router interface 	successful		
    ...    3	set the procy-discovery disable 	successful		
    ...    4	retrieve the multicast router interface 	no multicast router can be learned
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276063    @tcid=AXOS_E72_PARENT-TC-547
    ...    @user_interface=CLI    @priority=P1    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    check ${attribute} is default value ${default_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    STEP:1 send igmp query per vlan successful
    tg control igmp querier by name    tg1    igmp_querier    start

    log    STEP:2 retrieve the multicast router interface successful
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}

    log    STEP:3 set the procy-discovery disable successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}=${new_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    ${attribute}=${new_value}

    log    STEP:4 retrieve the multicast router interface no multicast router can be learned
    ${passed}    Run Keyword And Return Status    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    run keyword if     ${passed}    Fail    multicast router shouldn't be learned with ${attribute} ${new_value}

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1 
    
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    
case teardown
    [Documentation]    case teardown
    log    deprovision igmp-profile ${attribute}
    dprov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
