*** Settings ***
Documentation     SIP Service modification of URI
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_modification_of_URI
    [Documentation]    1. Modify a URI of 32 chars: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri AAA45678901234567890123456789012, Present in running-config
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3416    @globalid=2473173    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Modify a URI of 32 chars: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 123 uri AAA45678901234567890123456789012, Present in running-config
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number32A}    ${user_number1}    ${password}    ${dial_plan}  
    Wait Until Keyword Succeeds    2min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    uri=${uri_number32A}    user=${user_number1}    password=${password}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    URI    ${uri_number32A}   
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    ${dial_plan}  
    Wait Until Keyword Succeeds    2min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    uri=${uri_number1}    user=${user_number1}    password=${password}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    URI    ${uri_number1}   
*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown