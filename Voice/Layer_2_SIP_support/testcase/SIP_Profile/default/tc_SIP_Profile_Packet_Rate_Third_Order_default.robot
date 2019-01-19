*** Settings ***
Documentation     SIP Profile Packet Rate Third Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Packet_Rate_Third_Order_default
    [Documentation]    1. Enter SIP-Profile without packet-rate third-order, packet-rate third-order = 10, Pkt Rate 3rd order set to 10ms in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3331    @globalid=2473088    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without packet-rate third-order, packet-rate third-order = 10, Pkt Rate 3rd order set to 10ms in ONT
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec third-order
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate third-order=${packet_rate1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA     3rd Order    Packet Rate    ${packet_rate1} 


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