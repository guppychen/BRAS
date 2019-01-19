*** Settings ***
Documentation     SIP Service with dial-plan
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_with_dial_plan
    [Documentation]    1. Enter SIP service with dial plan: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 dial plan MyDialPlan, dial plan MyDialPlan
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3426    @globalid=2473183    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service with dial plan: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 dial plan MyDialPlan, dial plan MyDialPlan
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    ${dial_plan}
    Wait Until Keyword Succeeds    5min    10sec    check_pots_sip_service_status    eutA    ${pots_id1}  
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    dial-plan=${dial_plan}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Dial Plan    DIAL_PLAN_1


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  