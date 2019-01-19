*** Settings ***
Documentation     SIP Service modification of t38-fax-relay
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_modification_of_t38_fax_relay
    [Documentation]    1. Edit SIP service with no Call Waiting enabled: sip-service Daniel t38-fax-relay, t38-fax-relay, show running-config interface pots |details
    ...    2. T38 FAX enable, dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3448    @globalid=2473205    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service with no Call Waiting enabled: sip-service Daniel t38-fax-relay, t38-fax-relay, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    t38-fax-relay=${EMPTY}
    Wait Until Keyword Succeeds    5min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    t38-fax-relay=${EMPTY}  
    
    log    STEP:2. T38 FAX enable, dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    T38 Fax    enabled


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
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    t38-fax-relay=${EMPTY}