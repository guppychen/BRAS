*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Management      @author=Min Gu

*** Test Cases ***
tc_Verify_craft_connection_after_reboot_the_system
    [Documentation]
      
    ...    1	Provision ip address for craft 1 and login the device	login successful		
    ...    2	reboot the system	connection interrupt.		
    ...    3	wait for the system ready	connection can work again		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3750      @subFeature=Local Craft Interface Support      @globalid=2509260      @priority=P2      @eut=DualCard    @eut=10GE-12          @user_interface=CLI    
    log    set eut version and release
    set_eut_version
      
    log    STEP:1 Provision ip address for craft 1 and login the device login successful 
    &{dict_card_info}    get_system_equipment_card_info    eutA
    Set Suite Variable    ${old_active_Card}    &{dict_card_info}[active]
    Set Suite Variable    ${old_standby_Card}    &{dict_card_info}[standby]
    
    log    STEP:2 reboot the system connection interrupt. 
    reload    eutA
    
    log    STEP:3 wait for the system ready connection can work again 
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_active_Card}    In Service
    Wait Until Keyword Succeeds    ${retry_time}    10s    check_card_info    eutA    ${old_standby_Card}    In Service
    [Teardown]    case teardown
    
*** Keywords ***
case teardown
    log    wait until eutA in service
    Wait Until Keyword Succeeds    ${retry_time}    ${retry_interval}   Verify Cmd Working After Reload    eutA     show version  