*** Settings ***
Documentation     SIP Service removal of three way calling
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_removal_of_three_way_calling
    [Documentation]    1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel t38-fax-relay, no three-way-calling, show running-config interface pots |details
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3445    @globalid=2473202    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel t38-fax-relay, no three-way-calling, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    three-way-calling=${EMPTY}
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    three-way-calling=${EMPTY}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    3-way Calling    enabled

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
