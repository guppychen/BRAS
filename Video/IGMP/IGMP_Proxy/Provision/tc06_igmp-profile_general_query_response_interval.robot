*** Settings ***
Documentation     Test suite verifies igmp-profile general-query-response-interval
Resource          ../base.robot

*** Variables ***
${igmp_profile}    1
${attribute}    general-query-response-interval
${default_interval}    100
${allow_interval}    200
${illegal_interval}    201

*** Test Cases ***
tc_igmp_profile_general_query_response_interval
 
    [Documentation]       Test suite verifies igmp-profile general-query-response-interval
     
     ...    1.  Create new igmp-profile and verify that default general-query-response-interval is 100
     ...    2.  Change general-query-response-interval within acceptable range (50-600) and verify change
     ...    3.  Change general-query-response-interval outside of acceptable range and verify change
          
    [Tags]    @author=llim    @globalid=2276031    @tcid=AXOS_E72_PARENT-TC-515    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown

    log    STEP:1 verify that igmp-profile default general-query-response-interval is 100 (10ths of seconds)
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${default_interval}

    log    STEP:2 Change general-query-response-interval within acceptable range (50-600) and verify change
    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${allow_interval}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${allow_interval}
    
    log    STEP:3 Change general-query-response-interval outside of acceptable range and verify change
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