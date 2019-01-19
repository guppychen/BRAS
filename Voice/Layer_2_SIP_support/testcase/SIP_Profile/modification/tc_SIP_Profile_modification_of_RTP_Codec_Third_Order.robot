*** Settings ***
Documentation     SIP Profile modification of RTP Rate Third Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_RTP_Codec_Third_Order
    [Documentation]    1. no rtp-rate third-order, rtp-codec third-order = none
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3321    @globalid=2473078    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no rtp-rate third-order, rtp-codec third-order = none
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec third-order
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=none
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Codec    ulaw


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
  