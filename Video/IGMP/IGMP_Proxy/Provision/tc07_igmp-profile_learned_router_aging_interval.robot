*** Settings ***
Documentation     Test suite verifies igmp-profile learned_router_aging_interval
Resource          ../base.robot   

*** Variables ***
${igmp_profile}    1
${attribute}    learned_router_aging_interval
${default_interval}    2500
${allow_interval}    35000
${illegal_interval}    36001

*** Test Cases ***
tc_igmp_profile_learned_router_aging_interval
 
    [Documentation]       Test suite verifies igmp-profile learned_router_aging_interval
     
     ...    1.  Create new igmp-profile and verify that default learned_router_aging_interval is 2500
     ...    2.  Change learned_router_aging_interval within acceptable range (10-36000) and verify change
     ...    3.  Change learned_router_aging_interval outside of acceptable range and verify change
          
    [Tags]    @author=llim    @globalid=2276032    @tcid=AXOS_E72_PARENT-TC-516    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    
    log    STEP:1 verify that igmp-profile default learned_router_aging_interval is 2500 (10ths of seconds)
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${default_interval}

    log    STEP:2 Change learned_router_aging_interval within acceptable range (10-36000) and verify change
    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${allow_interval}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${allow_interval}
    
    log    STEP:3 Change learned_router_aging_interval outside of acceptable range and verify change
    ${status}    run keyword and return status    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${illegal_interval}
    run keyword if     ${status}==True    Fail    Failure: '${illegal_interval}' illegal_interval  (beyond max limit) provisioned successfully.
        
*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: Create and verify igmp profile
    prov_igmp_profile    eutA    ${igmp_profile}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}
    
case teardown
    [Documentation]    case teardown
    log    case teardown: delete igmp profile
    delete_config_object    eutA    igmp-profile    ${igmp_profile} 