*** Settings ***
Documentation     SIP service mandatory parameters
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_service_mandatory_parameters
    [Documentation]    1. Enter POTS interface with all mandatory parameters: interface pots 211/p1 sip-service Daniel ip-host 1 user 2012069019 password 2012069019 uri 2012069019, command accepted and parameters present in running config.
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3408    @globalid=2473165    @eut=GPON-8r2     @priority=P1    @user_interface=CLI 
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter POTS interface with all mandatory parameters: interface pots 211/p1 sip-service Daniel ip-host 1 user 2012069019 password 2012069019 uri 2012069019, command accepted and parameters present in running config.
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1 
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    
    Wait Until Keyword Succeeds    5min    10sec    check_interface_pots_detail    eutA    ${pots_id1}    ${ua_id}    uri=${uri_number1}    user=${user_number1}    password=${password}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  