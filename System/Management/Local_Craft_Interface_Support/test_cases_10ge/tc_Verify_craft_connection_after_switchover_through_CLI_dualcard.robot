*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Management      @author=Min Gu 

*** Test Cases ***
tc_Verify_craft_connection_after_switchover_through_CLI_dualcard
    [Documentation]
      
    ...    1	Provision ip address for craft 1 and login the device	login successful		
    ...    2	Perform switchover through CLI	connection can work again after seconds interrupt.		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3747      @subFeature=Local Craft Interface Support      @globalid=2509257      @priority=P2      @eut=DualCard    @eut=10GE-12          @user_interface=CLI    
    log    set eut version and release
    set_eut_version
    
    log    STEP:1 Provision ip address for craft 1 and login the device login successful 
    &{dict_card_info}    get_system_equipment_card_info    eutA
    Set Suite Variable    ${old_active_Card}    &{dict_card_info}[active]
    Set Suite Variable    ${old_standby_Card}    &{dict_card_info}[standby]
    
    log    STEP:2 Perform switchover through CLI connection can work again after seconds interrupt. 
    redundancy_switchover    eutA
    Wait Until Keyword Succeeds    ${p_check_switchover_status}    10s    check_switchover_status    eutA    switchover-dm-in-sync-status="All DMs in sync"
    check_card_info    eutA    ${old_active_Card}    In Service
    check_card_info    eutA    ${old_standby_Card}    In Service
    check_system_equipment_info    eutA    active-controller=${old_standby_Card}    standby-controller=${old_active_Card}
    check_system_equipment_info    eutA    active-controller=${old_active_Card}    standby-controller=${old_standby_Card}    contain=no
    [Teardown]    case teardown
    
*** Keywords ***
case teardown
    log    wait until eutA in service
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_active_Card}    In Service
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_standby_Card}    In Service   
    
