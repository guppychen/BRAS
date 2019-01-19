*** Settings ***
Documentation     SIP Profile with Call pickup code
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_Call_Pickup_Code
    [Documentation]    1. Enter SIP-Profile with call-pickup-code = abc, call-pickup-code = abc, Call pickup code = abc
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3405    @globalid=2473162    @priority=P1    @eut=GPON-8r2    @user_interface=CLI    @jira=EXA-24853
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile with call-pickup-code = abc, call-pickup-code = abc, Call pickup code = abc
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    call-pickup-code=${call_pickup_code}
    #failed, CLI doesn't include this command, unknown command
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    call-pickup-code=${call_pickup_code_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${call_pickup_code_1}    Call pickup code
    

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  