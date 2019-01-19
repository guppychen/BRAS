*** Settings ***
Documentation     SIP Profile deletion of Silence Suppression Third Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Silence_Suppression_Third_Order
    [Documentation]    1. no silence-suppression third-order, no silence-suppression third-order, Silence Suppression 3rd order disabled in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3346    @globalid=2473103    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no silence-suppression third-order, no silence-suppression third-order, Silence Suppression 3rd order disabled in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec third-order=ulaw 
    dprov_sip_profile    eutA    ${sip_profile}    =silence-suppression third-order
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    no=silence-suppression third-order
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    3rd Order    Silence Suppression    ${sil_sup_def}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  