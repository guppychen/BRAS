*** Settings ***
Documentation     SIP profile Packet Rate First Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_profile_Packet_Rate_First_Order_default
    [Documentation]    1. Enter SIP-Profile without packet-rate first-order, packet-rate first-order = 10
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3323    @globalid=2473080    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without packet-rate first-order, packet-rate first-order = 10
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    packet-rate first-order=${packet_rate1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA     1st Order    Packet Rate    ${packet_rate1}    
   

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  