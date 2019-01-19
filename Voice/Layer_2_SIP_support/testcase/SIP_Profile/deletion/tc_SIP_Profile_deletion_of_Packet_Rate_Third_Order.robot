*** Settings ***
Documentation     SIP Profile deletion of Packet Rate Third Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Packet_Rate_Third_Order
    [Documentation]    1. no packet-rate third-order, packet-rate third-order = 10, Packet Rate 3rd order set to 10ms in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3334    @globalid=2473091    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no packet-rate third-order, packet-rate third-order = 10, Packet Rate 3rd order set to 10ms in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw 
    dprov_sip_profile    eutA    ${sip_profile}    =packet-rate third-order
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate third-order=${packet_rate1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Packet Rate    ${packet_rate1}
    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  