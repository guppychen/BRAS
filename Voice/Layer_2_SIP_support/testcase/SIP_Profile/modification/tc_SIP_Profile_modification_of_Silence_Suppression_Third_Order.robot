*** Settings ***
Documentation     SIP Profile modification of Silence Suppression Third Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Silence_Suppression_Third_Order
    [Documentation]    1. Edit SIP-Profile silence-suppression third-order, silence-suppression third-order, Silence Suppression 3rd order enabled in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3345    @globalid=2473102    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile silence-suppression third-order, silence-suppression third-order, Silence Suppression 3rd order enabled in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw 
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    silence-suppression third-order=
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    silence-suppression third-order=    
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Silence Suppression    ${sil_sup_modi}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =silence-suppression
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec third-order
  