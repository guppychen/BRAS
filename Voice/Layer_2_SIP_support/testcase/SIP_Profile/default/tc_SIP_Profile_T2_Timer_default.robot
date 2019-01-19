*** Settings ***
Documentation     SIP Profile T2 Timer default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_T2_Timer_default
    [Documentation]    1. Enter a SIP-Profile without t2-timer, t2-timer = 4, T2 Timer = 4 (sec)
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3351    @globalid=2473108    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter a SIP-Profile without t2-timer, t2-timer = 4, T2 Timer = 4 (sec)
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    t2-timer=${t2_timer}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${t2_timer}    T2 Timer


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  