*** Settings ***
Documentation     SIP Service removal of dial-plan
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_removal_of_dial_plan
    [Documentation]    1. Edit SIP service without dial plan: no sip-service Daniel dial plan, dial plan system-default, show running-config interface pots |details
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3428    @globalid=2473185    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service without dial plan: no sip-service Daniel dial plan, dial plan system-default, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    dial-plan=${EMPTY}    
    check_running_config_interface    eutA    pots    ${pots_id1}    | details    dial-plan=${dial_plan1}
    # the dial-plan isn't system-default  
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
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    ${dial_plan}
    Wait Until Keyword Succeeds    5min    10sec    check_pots_sip_service_status    eutA    ${pots_id1}  