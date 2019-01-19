*** Settings ***
Documentation     SIP Service modification of direct-connect-timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_modification_of_direct_connect_timer
    [Documentation]    1. Enter SIP service without direct-connect-timer 1: direct-connect-timer 1, direct-connect-timer 1, show running-config interface pots |details
    ...    2. Direct Connect Timer: 1 (sec), dcli potsmgr show sip_service
    ...    3. Edit SIP service without direct-connect-timer 35: direct-connect-timer 35, direct-connect-timer 35, show running-config interface pots |details
    ...    4. Direct Connect Timer: 35 (sec), dcli potsmgr show sip_service
    ...    5. Edit SIP service without direct-connect-timer invalid values: sip-service Daniel direct-connect-timer 36, comand rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3435    @globalid=2473192    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service without direct-connect-timer 1: direct-connect-timer 1, direct-connect-timer 1, show running-config interface pots |details
    
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    direct-connect=${direct_connect1}    direct-connect-timer=${direct_connect_timer1}  
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    direct-connect-timer=${direct_connect_timer1}
    
    log    STEP:2. Direct Connect Timer: 1 (sec), dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Direct Connect Timer    ${direct_connect_timer1}
    
    log    STEP:3. Edit SIP service without direct-connect-timer 35: direct-connect-timer 35, direct-connect-timer 35, show running-config interface pots |details
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    direct-connect-timer=${direct_connect_timer35}  
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    direct-connect-timer=${direct_connect_timer35}
    
    log    STEP:4. Direct Connect Timer: 35 (sec), dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Direct Connect Timer    ${direct_connect_timer35}
    
    log    STEP:5. Edit SIP service without direct-connect-timer invalid values: sip-service Daniel direct-connect-timer 36, comand rejected
    cli    eutA    conf
    ${res}    cli    eutA    interface pots ${pots_id1} sip-service ${ua_id} direct-connect-timer ${direct_connect_timer36} 
    should contain    ${res}    "36" is out of range  
    cli    eutA    end  


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    direct-connect-timer=${direct_connect_timer35}