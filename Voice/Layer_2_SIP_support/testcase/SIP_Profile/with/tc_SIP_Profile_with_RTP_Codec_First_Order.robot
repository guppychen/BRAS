*** Settings ***
Documentation     SIP Profile with RTP Rate First Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_RTP_Codec_First_Order
    [Documentation]    1、Enter SIP-Profile rtp-codec codec-first-order = ulaw, A-Law, G729, rtp-codec first-order = selection
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3312    @globalid=2473069    @priority=P1    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Enter SIP-Profile rtp-codec codec-first-order = ulaw, A-Law, G729, rtp-codec first-order = selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec first-order=ulaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec first-order=uLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Codec    ulaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec first-order=ALaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec first-order=aLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Codec    alaw

    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec first-order=G729
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec first-order=G729
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Codec    g729
    
    
    

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec first-order
  