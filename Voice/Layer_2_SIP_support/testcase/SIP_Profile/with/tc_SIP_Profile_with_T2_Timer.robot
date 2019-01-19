*** Settings ***
Documentation     SIP Profile with T2 Timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_T2_Timer
    [Documentation]    1. Enter SIP-Profile t2-timer = 1,4, t2-timer = selection, T2 Timer = 3 (sec)
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3352    @globalid=2473109    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile t2-timer = 1,4, t2-timer = selection, T2 Timer = 4 (sec)
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    t2-timer=${t2_timer_1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    t2-timer=${t2_timer_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${t2_timer_1}    T2 Timer
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    t2-timer=${t2_timer_4}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    t2-timer=${t2_timer_4}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${t2_timer_4}    T2 Timer


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =t2-timer

  