*** Settings ***
Documentation     SIP Profile deletion of Call Waiting Prefix  
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Call_Waiting_Prefix
    [Documentation]    1. no call-waiting-prefix, call-waiting-prefix = CallWaitingTone
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3367    @globalid=2473124    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no call-waiting-prefix, call-waiting-prefix = CallWaitingTone
    dprov_sip_profile    eutA    ${sip_profile}    =call-waiting-prefix
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

  