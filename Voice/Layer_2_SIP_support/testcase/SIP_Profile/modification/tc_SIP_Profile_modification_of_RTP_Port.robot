*** Settings ***
Documentation     SIP Profile modification of RTP Port
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_RTP_Port
    [Documentation]    1. Edit SIP-Profile rtp port 49153 and 65535, rtp-port = selection, RTP Port = selection
    ...    2. Edit SIP-Profile rtp-portt > 65535, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3398    @globalid=2473155    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile rtp port 49153 and 65535, rtp-port = selection, RTP Port = selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-port=${rtp_port_1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    rtp-port=${rtp_port_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_port_1}    RTP Port
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-port=${rtp_port_2}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    rtp-port=${rtp_port_2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_port_2}    RTP Port
    
    log    STEP:2. Edit SIP-Profile rtp-portt > 65535, command rejected
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_profile} rtp-port ${rtp_port_3}
    should contain    ${res}    "${rtp_port_3}" is not a valid value
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
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-port