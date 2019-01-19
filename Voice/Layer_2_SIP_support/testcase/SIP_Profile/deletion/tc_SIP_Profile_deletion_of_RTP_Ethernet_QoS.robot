*** Settings ***
Documentation     SIP Profile deletion of RTP Ethernet QoS
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_RTP_Ethernet_QoS
    [Documentation]    1. no rtp-eth-qos, rtp-eth-qos = 6, RTP 802.1p = 6
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3383    @globalid=2473140    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no rtp-eth-qos, rtp-eth-qos = 6, RTP 802.1p = 6
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-eth-qos
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-eth-qos=${rtp_eth_qos}
    Wait Until Keyword Succeeds    5min    10sec     check_ont_sip_profile    ontA    ${rtp_eth_qos}    RTP 802.1p            
       

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  