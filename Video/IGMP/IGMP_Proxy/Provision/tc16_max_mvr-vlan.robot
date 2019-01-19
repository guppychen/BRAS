*** Settings ***
Documentation     Test suite verifies maximum mvr-profile vlan
Resource          ../base.robot

*** Variables ***
${mvr_total}    1
${mvr_vlan_total}    8

*** Test Cases ***
tc_maximum_mvr_profile_vlan
 
    [Documentation]       Test suite verifies maximum mvr-profile vlan
    
     ...    1.  Add 4 vlan to new mvr-profile 1 and verify that provisioning is successful
     ...    2.  Add 1 more vlan to new mvr-profile 1 and verify provisioning is unsuccessful
          
    [Tags]    @author=llim    @globalid=2276042    @tcid=AXOS_E72_PARENT-TC-526    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown

    log    STEP:1 Add 4 vlan to new mvr-profile 1 and verify that provisioning is successful
    : FOR    ${each}    IN RANGE    1    ${mvr_vlan_total}+1
    \    prov_vlan    eutA    ${each}55
    \    prov_mvr_profile    eutA    ${mvr_total}    225.${each}.0.1	225.${each}.0.10    ${each}55
    : FOR    ${each}    IN RANGE    1    ${mvr_vlan_total}+1
    \    check_running_configure    eutA    mvr-profile    ${mvr_total}    address=225.${each}.0.1 225.${each}.0.10 ${each}55

    log    STEP:2 Add 1 more vlan to new mvr-profile 1 and verify provisioning is unsucessful
    ${illegal_vlan}    evaluate    ${mvr_total}+${mvr_vlan_total}
    prov_vlan    eutA    ${illegal_vlan}55
    ${status}    run keyword and return status    prov_mvr_profile    eutA    ${mvr_total}    225.${illegal_vlan}.0.1	225.${illegal_vlan}.0.10    ${illegal_vlan}55
    run keyword if     ${status}==True    Fail    ${illegal_vlan}th (beyond max limit) provisioned successfully.
        
*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: Create and verify mvr profile
    prov_mvr_profile    eutA    ${mvr_total}
    check_running_configure    eutA    mvr-profile    ${mvr_total}
    
case teardown
    [Documentation]    case teardown
    log    case teardown: Delete mvr-profile
    delete_config_object    eutA    mvr-profile    ${mvr_total} 
    log    delete vlan
    ${illegal_vlan}    evaluate    ${mvr_total}+${mvr_vlan_total}
    delete_config_object    eutA    vlan    ${illegal_vlan}55
    : FOR    ${each}    IN RANGE    1    ${mvr_vlan_total}+1
    \    delete_config_object    eutA    vlan    ${each}55