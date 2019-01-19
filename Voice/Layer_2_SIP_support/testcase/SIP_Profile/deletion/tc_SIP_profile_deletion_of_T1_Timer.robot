*** Settings ***
Documentation     SIP profile deletion of T1 Timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_profile_deletion_of_T1_Timer
    [Documentation]    1. no t1-timer, t1-timer = 500, T1 Timer = 500 (ms)
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3350    @globalid=2473107    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no t1-timer, t1-timer = 500, T1 Timer = 500 (ms)
    dprov_sip_profile    eutA    ${sip_profile}    =t1-timer
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

  