*** Settings ***
Documentation     SIP Profile Silence Suppression Third Order default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Silence_Suppression_Third_Order_default
    [Documentation]    1. Enter SIP-Profile without silence-suppression third-order, no silence-suppression third-order, Silence Suppression 3rd order disabled in ONT
    ...    
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3343    @globalid=2473100    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without silence-suppression third-order, no silence-suppression third-order, Silence Suppression 3rd order disabled in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw 
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    no=silence-suppression third-order    
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Silence Suppression    ${sil_sup_def}
    




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

  