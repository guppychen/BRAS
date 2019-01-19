*** Settings ***
Documentation     Test suite verifies pbit for multicast vlan
Resource          ../base.robot

*** Variables ***
${igmp_profile}    1
${attribute}    pbit-priority
${default_interval}    5
${allow_interval}    0
${illegal_interval}    8

*** Test Cases ***
tc_igmp_profile_pbit_for_multicast_vlan
 
    [Documentation]       Test suite verifies pbit for multicast vlan
     
     ...    1.  Create new igmp-profile and verify that default pbit-priority is 10
     ...    2.  Change pbit-priority within acceptable range (0-7) and verify change
     ...    3.  Change pbit-priority outside of acceptable range and verify change
          
    [Tags]    @author=llim    @globalid=2276041    @tcid=AXOS_E72_PARENT-TC-525    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    
    log    STEP:1 verify that igmp-profile default pbit-priority is 10
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${default_interval}

    log    STEP:2 Change pbit-priority is within acceptable range (0-7) and verify change
    prov_igmp_profile    eutA    ${igmp_profile}    ${attribute}=${allow_interval}
    check_running_configure    eutA    igmp-profile    ${igmp_profile}    subview2=${attribute}    ${attribute}=${allow_interval}
    
    log    STEP:3 Change pbit-priority is outside of acceptable range and verify change
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
    