*** Settings ***
Documentation     SIP Service removal of t38-fax-relay
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_removal_of_t38_fax_relay
    [Documentation]    1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel t38-fax-relay, T38 FAX disable, show running-config interface pots |details
    ...    2. t38-fax-relay, dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3449    @globalid=2473206    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel t38-fax-relay, T38 FAX disable, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    t38-fax-relay=${EMPTY}         
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    no=t38-fax-relay
    
    log    STEP:2. t38-fax-relay, dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    T38 Fax    disabled


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    
  