*** Settings ***
Documentation     SIP Profile RTP Port default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_RTP_Port_default
    [Documentation]    1. Enter SIP-Profile without rtp-port, rtp-port = 49152, RTP Port = 49152
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3396    @globalid=2473153    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without rtp-port, rtp-port = 49152, RTP Port = 49152
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-port=${rtp_port}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_port}    RTP Port


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  