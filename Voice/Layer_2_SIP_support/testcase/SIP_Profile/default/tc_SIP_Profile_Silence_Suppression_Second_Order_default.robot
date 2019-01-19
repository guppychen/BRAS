*** Settings ***
Documentation     SIP Profile Silence Suppression Second Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Silence_Suppression_Second_Order_default
    [Documentation]    1. Enter SIP-Profile without silence-suppression second-order, no silence-suppression second-order, Silence Suppression 2nd order disabled in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3339    @globalid=2473096    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without silence-suppression second-order, no silence-suppression second-order, Silence Suppression 2nd order disabled in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec second-order=ulaw 
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    no=silence-suppression second-order    
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    2nd Order    Silence Suppression    ${sil_sup_def}


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
  