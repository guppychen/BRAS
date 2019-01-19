*** Settings ***
Documentation     Test suite verifies igmp-profile learned route port aging time
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute}    learned_router_aging_interval
${default_value}    ${p_dflt_router_aging_invl}
${new_value}    300

*** Test Cases ***
tc_igmp_profile_learned_route_port_aging_time
    [Documentation]    1	send igmp query to uplink interface	the interface become route port		
    ...    2	no receive any igmp query on uplink interface	the route port will be deleted after 260s		
    ...    3	change the time to other value	the interface become route port		
    ...    4	repeat step 1-2	the route port will be deleted after the time provision
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276061    @tcid=AXOS_E72_PARENT-TC-545
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    check ${attribute} is default value ${default_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    log    according to EXA-18903 the aging time is twice config value
    ${age_sec}    evaluate    (${default_value}/10)*2
    
    log    STEP:1 send igmp query to uplink interface the interface become route port
    log    start and check igmp router summary
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    
    log    STEP:2 no receive any igmp query on uplink interface the route port will be deleted after 260s
    tg control igmp querier by name    tg1    igmp_querier    start
    tg control igmp querier by name    tg1    igmp_querier    stop
    log    ******sleep for aging time ${age_sec}******
    sleep    ${age_sec}
    log    check igmp router aged
    Wait Until Keyword Succeeds    ${age_sec}    10sec    service_point_check_igmp_routers    service_point1    ${p_video_vlan}
    ...    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}   contain=no
    
    log    STEP:3 change the time to other value the interface become route port
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}=${new_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    ${attribute}=${new_value}
    log    according to EXA-18903 the aging time is twice config value
    ${age_sec_new}    evaluate    (${new_value}/10)*2

    log    STEP:4 repeat step 1-2 the route port will be deleted after the time provision
    log    start and check igmp router summary
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    
    log    stop and check igmp router aged
    tg control igmp querier by name    tg1    igmp_querier    start
    tg control igmp querier by name    tg1    igmp_querier    stop
    log    ******sleep for aging time ${age_sec_new}******
    sleep    ${age_sec_new}
    log    check igmp router aged
    Wait Until Keyword Succeeds    ${age_sec}    10sec    service_point_check_igmp_routers    service_point1    ${p_video_vlan}
    ...    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}   contain=no

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
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
    