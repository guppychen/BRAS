*** Settings ***
Documentation     SIP Profile T1 Timer default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_T1_Timer_default
    [Documentation]    1. Enter a SIP-Profile without t1-timer, t1-timer = 500, T1 Timer = 500 (ms)
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3347    @globalid=2473104    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter a SIP-Profile without t1-timer, t1-timer = 500, T1 Timer = 500 (ms)
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    t1-timer=${t1_timer}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${t1_timer}    T1 Timer
     

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  