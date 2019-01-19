*** Settings ***
Documentation     SIP Profile Call Waiting Prefix default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Call_Waiting_Prefix_default
    [Documentation]    1. Enter SIP-Profile without call-waiting-prefix, call-waiting -prefix = CallWaitingTone, Call Waiting Prefix = CallWaitingTone
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3364    @globalid=2473121    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without call-waiting-prefix, call-waiting-prefix = CallWaitingTone, Call Waiting Prefix = CallWaitingTone
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    call-waiting-prefix=${call_waiting_prefix}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${call_waiting_prefix}    Call Waiting Prefix


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  