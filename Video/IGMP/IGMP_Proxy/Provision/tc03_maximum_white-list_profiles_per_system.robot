*** Settings ***
Documentation     Test suite verifies maximum whitelist profiles per system
Resource          ../base.robot

*** Variables ***
${whitelist_total}    128
${illegal_whitelist}    129

*** Test Cases ***
tc_maximum_whitelist_profiles_per_system
 
    [Documentation]       Test suite verifies maximum whitelist profiles per system

     ...    1.  Verify that all profiles are successfully created
     ...    2.  Create 129th multicast-whitelist-profile and verify that profile creation is unsuccessful
          
    [Tags]    @author=llim    @globalid=2276027    @tcid=AXOS_E72_PARENT-TC-511    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    
    log    STEP:1 Verify that all profiles are successfully created
    : FOR    ${each}    IN RANGE    1    ${whitelist_total}+1
    \    check_running_configure    eutA    multicast-whitelist-profile    ${each}
    
    log    STEP:2 Create 129th multicast-whitelist-profile and verify that profile creation is unsuccessful    
    ${status}    run keyword and return status    configure_whitelist_profile    eutA    ${illegal_whitelist}
    run keyword if     ${status}==True    delete_config_object    eutA    multicast-whitelist-profile    ${illegal_whitelist} 

    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: Create 128 multicast-whitelist-profiles 
    : FOR    ${each}    IN RANGE    1    ${whitelist_total}+1
    \    configure_whitelist_profile    eutA    ${each}
    
case teardown  
    [Documentation]    case teardown
    log    case teardown: delete mcast-whitelist-profile
    : FOR    ${each}    IN RANGE    1    ${whitelist_total}+1
    \    delete_config_object    eutA    multicast-whitelist-profile    ${each} 