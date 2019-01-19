*** Settings ***
Documentation     SIP Service with three-way-calling
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_with_three_way_calling
    [Documentation]    1. Enter SIP service with Message Waiting indicator enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 three-way-calling, three-way-calling, show running-config interface pots |details
    ...    2. 3-Way Calling: enable, dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3442    @globalid=2473199    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service with Message Waiting indicator enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 three-way-calling, three-way-calling, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    three-way-calling=${EMPTY}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    three-way-calling=${EMPTY}
    
    log    STEP:2. 3-Way Calling: enable, dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    3-way Calling    enabled


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    three-way-calling=${EMPTY}

case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  