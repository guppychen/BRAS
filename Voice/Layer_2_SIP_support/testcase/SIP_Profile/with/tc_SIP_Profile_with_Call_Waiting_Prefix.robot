*** Settings ***
Documentation     SIP Profile with Call Waiting Prefix
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_Call_Waiting_Prefix
    [Documentation]    1. Enter SIP-Profile call-waiting-prefix = abcdefghijklmnopqrst, call-waiting-prefix = abcdefghijklmnopqrst
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3365    @globalid=2473122    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile call-waiting-prefix = abcdefghijklmnopqrst, call-waiting-prefix = abcdefghijklmnopqrst
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    call-waiting-prefix=${call_waiting_prefix_modi}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    call-waiting-prefix=${call_waiting_prefix_modi}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${call_waiting_prefix_modi}    Call Waiting Prefix
    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =call-waiting-prefix

  