*** Settings ***
Documentation     SIP Profile deletion of RTP Rate First Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_RTP_Codec_First_Order
    [Documentation]    1. no rtp-rate-first-order, rtp-codec first-order = uLaw
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3314    @globalid=2473071    @priority=P3    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no rtp-rate-first-order, rtp-codec first-order = uLaw
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec first-order
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

  