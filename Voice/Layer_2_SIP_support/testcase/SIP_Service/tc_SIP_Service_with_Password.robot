*** Settings ***
Documentation     SIP Service with Password
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_with_Password
    [Documentation]    1. Enter a password of 24 chars: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 1234567890!@#$%^&*()1234 uri 2012069019, Present in running-config
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3413    @globalid=2473170    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter a password of 24 chars: interface pots 211/p1 sip-service Daniel ip-host 1 user 1234567890 password 1234567890!@#$%^&*()1234 uri 2012069019, Present in running-config
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password24}    ${dial_plan}  
    Wait Until Keyword Succeeds    2min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    uri=${uri_number1}    user=${user_number1}    password=${password24}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    Password    ${password24}   
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    ${dial_plan}  
    Wait Until Keyword Succeeds    2min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    uri=${uri_number1}    user=${user_number1}    password=${password}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    Password    ${password}   

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown