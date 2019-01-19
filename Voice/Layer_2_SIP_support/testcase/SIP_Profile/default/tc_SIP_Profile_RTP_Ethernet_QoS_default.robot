*** Settings ***
Documentation     SIP Profile RTP Ethernet QoS default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_RTP_Ethernet_QoS_default
    [Documentation]    1. Enter SIP-Profile without rtp-eth-qos, rtp-eth-qos = 6, RTP 802.1p = 6
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3380    @globalid=2473137    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without rtp-eth-qos, rtp-eth-qos = 6, RTP 802.1p = 6
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-eth-qos=${rtp_eth_qos}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_eth_qos}    RTP 802.1p


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  