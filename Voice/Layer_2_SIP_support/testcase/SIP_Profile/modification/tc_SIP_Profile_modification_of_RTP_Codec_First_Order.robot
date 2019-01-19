*** Settings ***
Documentation     SIP Profile modification of RTP Rate First Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_RTP_Codec_First_Order
    [Documentation]    1. Modify the RTP Codec First Order with uLaw and A-Law and G.729, rtp-codec first-order = selection
    ...    2. Edit SIP Profile rtp-codec first-order = none, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3313    @globalid=2473070    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Modify the RTP Codec First Order with uLaw and A-Law and G.729, rtp-codec first-order = selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec first-order=ulaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec first-order=uLaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Codec    ulaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec first-order=Alaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec first-order=Alaw
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Codec    alaw
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec first-order=G729
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-codec first-order=G729
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Codec    g729
    
    log    STEP:2. Edit SIP Profile rtp-codec first-order = none, command rejected
    cli    eutA    configure
    Axos Cli With Error Check    eutA    sip-profile ${sip_profile}
    ${res}    cli    eutA    rtp-codec first-order none    
    should contain    ${res}    first order codec may not be none    
    cli    eutA    end



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
  