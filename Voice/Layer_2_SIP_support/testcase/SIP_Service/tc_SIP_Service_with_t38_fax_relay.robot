*** Settings ***
Documentation     SIP Service with t38-fax-relay
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_with_t38_fax_relay
    [Documentation]    1. Enter SIP service with Message Waiting indicator enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 t38-fax-relay, t38-fax-relay, show running-config interface pots |details
    ...    2. T38 FAX enable, dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3447    @globalid=2473204    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service with Message Waiting indicator enabled: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 1234567890 t38-fax-relay, t38-fax-relay, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    t38-fax-relay=${EMPTY}
    Wait Until Keyword Succeeds    5min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    t38-fax-relay=${EMPTY}  
    
    log    STEP:2. T38 FAX enable, dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    T38 Fax    enabled


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case teardown

case teardown
    [Documentation]
    [Arguments]
    log    case setup
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    t38-fax-relay=${EMPTY}