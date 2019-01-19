*** Settings ***
Documentation     SIP Profile with Release Timer
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Release_Timer
    [Documentation]    1. Edit SIP-Profile release-timer = 1 and 20, release-timer = selection, Release timer = selection (sec)
    ...    2. Edit SIP-Profile release-timer > 20, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3394    @globalid=2473151    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile release-timer = 1 and 20, release-timer = selection, Release timer = selection (sec)
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    release-timer=${release_timer_1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    release-timer=${release_timer_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${release_timer_1}    Release Timer
    
    log    STEP:2. Edit SIP-Profile release-timer > 20, command rejected
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_profile} release-timer ${release_timer_2}
    should contain    ${res}    "${release_timer_2}" is out of range
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
    dprov_sip_profile    eutA    ${sip_profile}    =release-timer
  