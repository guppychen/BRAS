*** Settings ***
Documentation     SIP Service removal of call-waiting
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_removal_of_call_waiting
    [Documentation]    1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel call-waiting, no call-waiting
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3420    @globalid=2473177    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel call-waiting, no call-waiting
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    call-waiting=${EMPTY}         
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    no=call-waiting
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Call Waiting    disabled
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
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    call-waiting=${EMPTY}
  