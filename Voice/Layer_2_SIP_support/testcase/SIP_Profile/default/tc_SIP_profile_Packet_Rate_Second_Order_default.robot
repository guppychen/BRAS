*** Settings ***
Documentation     SIP profile Packet Rate Second Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_profile_Packet_Rate_Second_Order_default
    [Documentation]    1. Enter SIP-Profile without packet-rate second-order, packet-rate second-order = 10
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3327    @globalid=2473084    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without packet-rate second-order, packet-rate second-order = 10
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec second-order=ulaw
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate second-order=${packet_rate1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA     2nd Order    Packet Rate    ${packet_rate1}    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec second-order