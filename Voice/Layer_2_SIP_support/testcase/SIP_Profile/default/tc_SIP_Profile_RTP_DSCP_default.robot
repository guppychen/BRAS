*** Settings ***
Documentation     SIP Profile Local Hook Flash default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_RTP_DSCP_default
    [Documentation]    1. Enter SIP-Profile without rtp-dscp, rtp-dscp = 46, RTP DSCP = 46
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3376    @globalid=2473133    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without rtp-dscp, rtp-dscp = 46, RTP DSCP = 46
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-dscp=${rtp_dscp_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_dscp}    RTP DSCP
    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  