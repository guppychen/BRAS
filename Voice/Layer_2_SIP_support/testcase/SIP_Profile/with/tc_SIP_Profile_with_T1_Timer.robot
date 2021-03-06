*** Settings ***
Documentation     SIP Profile with T1 Timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_T1_Timer
    [Documentation]    1. Enter a SIP-Profile with t1-timer = 100, t1-timer = 100, T1 Timer = 100 (ms)
    ...    2. Enter a SIP-Profile with t1-timer < 100 and > 1500, Command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3348    @globalid=2473105    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter a SIP-Profile with t1-timer = 100, t1-timer = 100, T1 Timer = 100 (ms)
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    t1-timer=${t1_timer_100}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    t1-timer=${t1_timer_100}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${t1_timer_100}    T1 Timer
    
    log    STEP:2. Enter a SIP-Profile with t1-timer < 100 and > 1500, Command rejected
    cli    eutA    configure
    cli    eutA    sip-profile ${sip_profile} 
    ${res}    cli    eutA    t1-timer ${t1_timer_50} 
    should contain    ${res}    "${t1_timer_50}" is out of range   
    cli    eutA    sip-profile ${sip_profile} 
    ${res}    cli    eutA    t1-timer ${t1_timer_1501} 
    should contain    ${res}    "${t1_timer_1501}" is out of range   
    cli    eutA    end    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =t1-timer
  