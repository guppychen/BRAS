*** Settings ***
Documentation     SIP Service dial-plan default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_dial_plan_default
    [Documentation]    1. Enter SIP service without dial plan: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri abc, dial plan system-default
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3425    @globalid=2473182    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service without dial plan: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri abc, dial plan system-default
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    dial-plan=${EMPTY}  
    check_running_config_interface    eutA    pots    ${pots_id1}    | details    dial-plan=${dial_plan1}
    # the dial-plan isn't system-default  
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    Dial Plan    DIAL_PLAN_1   


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
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    ${dial_plan}
    Wait Until Keyword Succeeds    5min    10sec    check_pots_sip_service_status    eutA    ${pots_id1}  