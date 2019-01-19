*** Settings ***
Documentation     SIP Profile RTP Rate Second Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_RTP_Codec_Second_Order_default
    [Documentation]    1. Enter SIP-Profile without rtp-codec second-order, rtp-codec second-order = none
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3315    @globalid=2473072    @priority=P3    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without rtp-codec second-order, rtp-codec second-order = none
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec second-order=none
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    2nd Order    Codec    ulaw


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  