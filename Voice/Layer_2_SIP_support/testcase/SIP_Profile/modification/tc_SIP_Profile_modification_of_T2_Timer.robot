*** Settings ***
Documentation     SIP Profile modification of T2 Timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_T2_Timer
    [Documentation]    1. Edit SIP-Profile t2-timer = 1,4, t2-timer = selection, T2 Timer = Selection (sec)
    ...    2. Edit SIP-Profile t2-timer <1 and > 4, Command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3354    @globalid=2473111    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile t2-timer = 1,4, t2-timer = selection, T2 Timer = Selection (sec)
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    t2-timer=${t2_timer_1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    t2-timer=${t2_timer_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${t2_timer_1}    T2 Timer
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    t2-timer=${t2_timer_4}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    t2-timer=${t2_timer_4}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${t2_timer_4}    T2 Timer
    
    log    STEP:2. Edit SIP-Profile t2-timer <1 and > 5, Command rejected
    cli    eutA    configure
    cli    eutA    sip-profile ${sip_profile} 
    ${res}    cli    eutA    t2-timer ${t2_timer_0} 
    should contain    ${res}    "${t2_timer_0}" is out of range   
    
    cli    eutA    configure
    cli    eutA    sip-profile ${sip_profile} 
    ${res}    cli    eutA    t2-timer ${t2_timer_6} 
    should contain    ${res}    "${t2_timer_6}" is out of range   


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
  