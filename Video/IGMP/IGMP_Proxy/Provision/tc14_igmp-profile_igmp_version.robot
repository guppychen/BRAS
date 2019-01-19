*** Settings ***
Documentation     Test suite verifies igmp-profile igmp-version
Resource          ../base.robot

*** Variables ***
${igmp_profile}    1
${attribute}    igmp-version
${default_interval}    AUTO
${allow_interval}    V2
${allow_interval2}    V3
${illegal_interval}    11

*** Test Cases ***
tc_igmp_profile_igmp-version
 
    [Documentation]       Test suite verifies igmp-profile igmp-version
     
     ...    1.  Create new igmp-profile and verify that default igmp-version is auto
     ...    2.  Change igmp-version to V2 and verify change
     ...    3.  Change igmp-version to V3 and verify change
     ...    4.  Change igmp-version to 11 and verify change
          
    [Tags]    @author=llim    @globalid=2276039    @tcid=AXOS_E72_PARENT-TC-523    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    
    log    STEP:1 verify that igmp-profile default igmp-version is auto
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${default_interval}

    log    STEP:2 Change igmp-version to V2 and verify change
    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${allow_interval}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${allow_interval}
    
    log    STEP:3 Change igmp-version to V3 and verify change
    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${allow_interval2}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${allow_interval2}
    
    log    STEP:4 Change igmp-version to 11 and verify change
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
  