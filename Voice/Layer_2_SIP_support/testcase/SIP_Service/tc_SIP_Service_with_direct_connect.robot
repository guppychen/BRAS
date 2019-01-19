*** Settings ***
Documentation     SIP Service with direct-connect
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_with_direct_connect
    [Documentation]    1. Enter SIP service with direct-connect 15 digits G72: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 345 direct-connect 123456789012345, direct-connect 123456789012345, show running-config interface pots |details
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3430    @globalid=2473187    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP service with direct-connect 15 digits G72: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri 345 direct-connect 123456789012345, direct-connect 123456789012345, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    direct-connect=${direct_connect1} 
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    direct-connect=${direct_connect1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Direct Connect    ${direct_connect1}
    


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
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    direct-connect=${direct_connect1} 

  