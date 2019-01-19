*** Settings ***
Documentation     SIP Profile deletion of RTP Rate Third Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_RTP_Codec_Third_Order
    [Documentation]    1. RTP Rate Third order set to none in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3322    @globalid=2473079    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. RTP Rate Third order set to none in ONT
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec third-order
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

  