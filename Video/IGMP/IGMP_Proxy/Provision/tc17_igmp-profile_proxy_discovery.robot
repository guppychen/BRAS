*** Settings ***
Documentation     Test suite verifies igmp-profile proxy-discovery
Resource          ../base.robot

*** Variables ***
${igmp_profile}    1
${attribute}    proxy-discovery
${default_interval}    ENABLED
${allow_interval}    DISABLED
${illegal_interval}    AUTO

*** Test Cases ***
tc_igmp_profile_proxy-discovery
 
    [Documentation]       Test suite verifies igmp-profile proxy-discovery
     
     ...    1.  Create new igmp-profile and verify that default proxy-discovery is ENABLED
     ...    2.  Toggle proxy-discovery value and verify change
     ...    3.  Change proxy-discovery outside of acceptable range and verify change
          
    [Tags]    @author=llim    @globalid=2276043    @tcid=AXOS_E72_PARENT-TC-527    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    
    log    STEP:1 verify that igmp-profile default proxy-discovery is ENABLED
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${default_interval}

    log    STEP:2 Change proxy-discovery to DISABLED
    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${allow_interval}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${allow_interval}
    
    log    STEP:3 Change proxy-discovery is outside of acceptable range and verify change
    ${status}    run keyword and return status    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${illegal_interval}
    run keyword if     ${status}==True    Fail    ${illegal_interval} (illegal value) provisioned successfully.
    
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
