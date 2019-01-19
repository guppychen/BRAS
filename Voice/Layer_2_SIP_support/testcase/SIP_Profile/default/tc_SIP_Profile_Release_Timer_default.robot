*** Settings ***
Documentation     SIP Profile with Release Timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Release_Timer_default
    [Documentation]    1. Enter SIP-Profile without release-timer, release-timer = 10, Release timer = 10 (sec)
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3392    @globalid=2473149    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without release-timer, release-timer = 10, Release timer = 10 (sec)
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    release-timer=${release_timer}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${release_timer}    Release Timer
    

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  