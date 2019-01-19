*** Settings ***
Documentation     SIP Profile deletion of RTP Rate Second Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_RTP_Codec_Second_Order
    [Documentation]    1. no rtp-rate second-order, rtp-codec second-order = none
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3318    @globalid=2473075    @priority=P3    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no rtp-rate second-order, rtp-codec second-order = none
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec second-order
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec second-order=none
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
  