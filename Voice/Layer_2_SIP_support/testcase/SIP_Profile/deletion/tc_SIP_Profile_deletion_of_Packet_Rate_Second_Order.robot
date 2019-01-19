*** Settings ***
Documentation     SIP Profile deletion of Packet Rate Second Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Packet_Rate_Second_Order
    [Documentation]    1. no packet-rate second-order, packet-rate second-order = 10, Packet Rate 2nd order set to 10ms in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3330    @globalid=2473087    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no packet-rate second-order, packet-rate second-order = 10, Packet Rate 2nd order set to 10ms in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec second-order=ulaw 
    dprov_sip_profile    eutA    ${sip_profile}    =packet-rate second-order
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate second-order=${packet_rate1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    2nd Order    Packet Rate    ${packet_rate1}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  