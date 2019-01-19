*** Settings ***
Documentation     SIP Profile modification of RTP Ethernet QoS
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_RTP_Ethernet_QoS
    [Documentation]    1. Edit SIP-Profile rtp-eth-qos = 0,7, rtp-eth-qos = selection, RTP 802.1p = 7
    ...    2. Edit SIP-Profile rtp-eth-qos > 7, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3382    @globalid=2473139    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile rtp-eth-qos = 0,7, rtp-eth-qos = selection, RTP 802.1p = 7
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-eth-qos=${rtp_eth_qos_1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    rtp-eth-qos=${rtp_eth_qos_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_eth_qos_1}    RTP 802.1p
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-eth-qos=${rtp_eth_qos_2}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    rtp-eth-qos=${rtp_eth_qos_2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_eth_qos_2}    RTP 802.1p
    
    log    STEP:2. Edit SIP-Profile rtp-eth-qos > 7, command rejected
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_profile} rtp-eth-qos ${rtp_eth_qos_3} 
    should contain    ${res}    "${rtp_eth_qos_3}" is out of range  
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
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-eth-qos