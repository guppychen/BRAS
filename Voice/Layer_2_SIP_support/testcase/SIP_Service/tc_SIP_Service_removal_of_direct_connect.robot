*** Settings ***
Documentation     SIP Service removal of direct-connect 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_removal_of_direct_connect
    [Documentation]    1. Edit SIP service without direct-connect: no sip-service Daniel direct-connect, direct-connect "", show running-config interface pots |details
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3432    @globalid=2473189    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service without direct-connect: no sip-service Daniel direct-connect, direct-connect "", show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1       
    ${res}    cli    eutA    show running-config interface pots ${pots_id1} | details 
    ${res1}    Get Lines Containing String    ${res}    direct-connect        
    should not be equal    ${res1}    direct-connect
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Direct Connect    ${EMPTY} 
    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  