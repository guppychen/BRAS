*** Settings ***
Documentation     SIP Profile modification of RTP Rate Third Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Packet_Rate_Third_Order
    [Documentation]    1. Edit SIP-Profile packet-rate third-order = 10ms and 20ms and 30ms, packet-rate third-order = selection, Pkt Rate 3rd order set to selection in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3333    @globalid=2473090    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile packet-rate third-order = 10ms and 20ms and 30ms, packet-rate third-order = selection, Pkt Rate 3rd order set to selection in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw 
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    packet-rate third-order=${packet_rate1}     
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate third-order=${packet_rate1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Packet Rate    ${packet_rate1} 
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw 
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    packet-rate third-order=${packet_rate2}     
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate third-order=${packet_rate2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Packet Rate    ${packet_rate2}  
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    packet-rate third-order=${packet_rate3}     
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate third-order=${packet_rate3}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Packet Rate    ${packet_rate3}     



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
    dprov_sip_profile    eutA    ${sip_profile}    =packet-rate 
  