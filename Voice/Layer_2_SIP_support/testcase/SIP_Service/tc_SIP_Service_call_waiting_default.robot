*** Settings ***
Documentation     SIP Service call-waiting default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_call_waiting_default
    [Documentation]    1. Enter SIP service with no Call Waiting enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890, call-waiting
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3417    @globalid=2473174    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service with no Call Waiting enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890, call-waiting
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    Wait Until Keyword Succeeds    5min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    call-waiting=  
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Call Waiting    enabled

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

