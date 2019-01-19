*** Settings ***
Documentation     SIP Service with Username
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_modification_of_Username
    [Documentation]    1. Enter a username of 50 chars: interface pots 211/p1 sip-service Daniel ip-host 1 user 12345678901234567890123456789012345678901234567890 password 2012069019 uri 2012069019, Present in running-config, Username: 12345678901234567890123456789012345678901234567890, dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3412    @globalid=2473169    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Modify a username of 50 chars: interface pots 211/p1 sip-service Daniel ip-host 1 user 12345678901234567890123456789012345678901234567890 password 2012069019 uri 2012069019, Present in running-config, Username: 12345678901234567890123456789012345678901234567890, dcli potsmgr show sip_service
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number50A}    ${password}    ${dial_plan}  
    Wait Until Keyword Succeeds    2min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    uri=${uri_number1}    user=${user_number50A}    password=${password}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    Username    ${user_number50A}    
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    ${dial_plan}  
    Wait Until Keyword Succeeds    2min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    uri=${uri_number1}    user=${user_number1}    password=${password}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    Username    ${user_number1}  

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown