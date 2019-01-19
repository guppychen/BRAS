*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Management      @author=Min Gu

*** Test Cases ***
tc_Verify_craft_connection_after_reboot_the_standby_card
    [Documentation]
      
    ...    1	Provision ip address for craft 1 and login the device	login successful		
    ...    2	reboot the standby card	connection works and has no interrupt.		
    ...    3	wait for the standby card ready	connection works and has no interrupt.		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3749      @subFeature=Local Craft Interface Support      @globalid=2509259      @priority=P2      @eut=DualCard    @eut=10GE-12          @user_interface=CLI    
    log    set eut version and release
    set_eut_version
    
    log    STEP:1 Provision ip address for craft 1 and login the device
    &{dict_card_info}    get_system_equipment_card_info    eutA
    Set Suite Variable    ${old_active_Card}    &{dict_card_info}[active]
    Set Suite Variable    ${old_standby_Card}    &{dict_card_info}[standby]
    
    log    STEP:2 reboot the standby card connection works and has no interrupt. 
    reload_card    eutA    ${old_standby_Card}
    
    log    STEP:3 wait for the standby card ready connection works and has no interrupt.
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_active_Card}    In Service
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_standby_Card}    In Service   
    check_system_equipment_info    eutA    active-controller=${old_active_Card}    standby-controller=${old_standby_Card}
    check_system_equipment_info    eutA    active-controller=${old_standby_Card}    standby-controller=${old_active_Card}    contain=no
    [Teardown]    case teardown
    
*** Keywords ***
case teardown
    log    wait until eutA in service
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_active_Card}    In Service
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_standby_Card}    In Service   