*** Settings ***
Documentation     SIP Profile with RTP Rate Third Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_RTP_Codec_Third_Order
    [Documentation]    1. Enter SIP-Profile rtp-codec third-order = none and ulaw and A-Law and G729, rtp-codec third-order = selection
    ...    2. Edit the RTP Codec Second Order with none and uLaw and A-Law and G.729, rtp-codec third-order = selection
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3320    @globalid=2473077    @priority=P1    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile rtp-codec third-order = none and ulaw and A-Law and G729, rtp-codec third-order = selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=none
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=none
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Codec    ulaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=uLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Codec    ulaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=Alaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=aLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Codec    alaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=G729
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=G729
    Wait Until Keyword Succeeds    5min    10sec     check_ont_sip_pro_RTP    ontA    3rd Order    Codec    g729
  
    log    STEP:2. Edit the RTP Codec Second Order with none and uLaw and A-Law and G.729, rtp-codec third-order = selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=none
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=none
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Codec    ulaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=uLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Codec    ulaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=Alaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=aLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Codec    alaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=G729
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec third-order=G729
    Wait Until Keyword Succeeds    5min    10sec     check_ont_sip_pro_RTP    ontA    3rd Order    Codec    g729


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

  