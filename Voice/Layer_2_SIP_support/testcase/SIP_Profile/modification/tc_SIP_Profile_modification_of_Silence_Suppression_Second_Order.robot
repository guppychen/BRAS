*** Settings ***
Documentation     SIP Profile modification of Silence Suppression Second Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Silence_Suppression_Second_Order
    [Documentation]    1. Edit SIP-Profile silence-suppression second-order, silence-suppression second-order, Silence Suppression 2nd order enabled in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3341    @globalid=2473098    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile silence-suppression second-order, silence-suppression second-order, Silence Suppression 2nd order enabled in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec second-order=ulaw 
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    silence-suppression second-order=
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    silence-suppression second-order=    
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    2nd Order    Silence Suppression    ${sil_sup_modi}


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
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-codec second-order