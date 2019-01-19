*** Settings ***
Documentation     SIP Service caller-id default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_caller_id_default
    [Documentation]    1. Enter SIP service with no Caller ID enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890, caller-id, show running-config interface pots |details
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3421    @globalid=2473178    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service with no Caller ID enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890, caller-id, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
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