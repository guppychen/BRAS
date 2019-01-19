*** Settings ***
Documentation     SIP Profile RTP Rate Third Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_RTP_Codec_Third_Order_default
    [Documentation]    1. Enter SIP-Profile without rtp-codec third-order, rtp-codec third-order = none
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3319    @globalid=2473076    @priority=P3    @eut=GPON-8r2    @user_interface=CLI    
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without rtp-codec third-order, rtp-codec third-order = none
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=none
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA     3rd Order    Codec    ulaw



*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec third-order
  