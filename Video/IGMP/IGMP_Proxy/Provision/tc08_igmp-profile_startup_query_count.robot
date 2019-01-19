*** Settings ***
Documentation     Test suite verifies igmp-profile startup-query-count
Resource          ../base.robot

*** Variables ***
${igmp_profile}    1
${attribute}    startup-query-count
${default_interval}    2
${allow_interval}    8
${illegal_interval}    11

*** Test Cases ***
tc_igmp_profile_startup-query-count
 
    [Documentation]       Test suite verifies igmp-profile startup-query-count
     
     ...    1.  Create new igmp-profile and verify that default startup-query-count is 2
     ...    2.  Change startup-query-count within acceptable range (1-10) and verify change
     ...    3.  Change startup-query-count outside of acceptable range and verify change
          
    [Tags]    @author=llim    @globalid=2276033    @tcid=AXOS_E72_PARENT-TC-517    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    
    log    STEP:1 verify that igmp-profile default startup-query-count is 2
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${default_interval}

    log    STEP:2 Change startup-query-count within acceptable range (1-10) and verify change
    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${allow_interval}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${allow_interval}
    
    log    STEP:3 Change startup-query-count outside of acceptable range and verify change
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