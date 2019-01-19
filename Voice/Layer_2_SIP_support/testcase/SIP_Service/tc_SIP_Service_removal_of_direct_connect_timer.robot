*** Settings ***
Documentation     SIP Service removal of direct-connect-timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_removal_of_direct_connect_timer
    [Documentation]    1. Edit SIP service without dial plan: sip-service Daniel no direct-connect-timer, no direct-connect-timer, show running-config interface pots |details
    ...    2. Direct Connect Timer: 0(sec), dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3436    @globalid=2473193    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service without dial plan: sip-service Daniel no direct-connect-timer, no direct-connect-timer, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    ${res}    cli    eutA    show running-config interface pots ${pots_id1} | details 
    ${res1}    Get Lines Containing String    ${res}    direct-connect-timer        
    should not be equal    ${res1}    direct-connect-timer
    
    log    STEP:2. Direct Connect Timer: 0(sec), dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Direct Connect Timer    ${direct_connect_timer}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
