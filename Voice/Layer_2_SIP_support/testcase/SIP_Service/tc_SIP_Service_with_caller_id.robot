*** Settings ***
Documentation     SIP Service with caller-id
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_with_caller_id
    [Documentation]    1. Enter SIP service with Caller ID: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 caller-id, caller-id, show running-config interface pots |details
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3422    @globalid=2473179    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service with Caller ID: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 caller-id, caller-id, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    caller-id=${EMPTY} 
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    caller-id=
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Caller ID    enabled


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

