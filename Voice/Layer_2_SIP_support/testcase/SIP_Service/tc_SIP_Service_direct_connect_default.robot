*** Settings ***
Documentation     SIP Service direct-connect default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_direct_connect_default
    [Documentation]    1. Enter SIP service without direct-connect 15 digits G72: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 345, no direct-connect, show running-config interface pots |details
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3429    @globalid=2473186    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service without direct-connect 15 digits G72: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 345, no direct-connect, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    ${res}    cli    eutA    show running-config interface pots ${pots_id1} | details 
    ${res1}    Get Lines Containing String    ${res}    direct-connect-timer        
    should not be equal    ${res1}    direct-connect-timer
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Direct Connect    ${direct_connect}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

