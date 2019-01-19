*** Settings ***
Documentation     SIP Profile RTP Rate First Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_RTP_Rate_First_Order_default
    [Documentation]    1、Enter SIP-Profile without rtp-codec first-order, rtp-codec first-order = uLaw
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3311    @globalid=2473068    @priority=P3    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Enter SIP-Profile without rtp-codec first-order, rtp-codec first-order = uLaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec first-order=uLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Codec    ulaw


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  