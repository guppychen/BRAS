*** Settings ***
Documentation     SIP Profile deletion of Silence Suppression Second Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Silence_Suppression_Second_Order
    [Documentation]    1. no silence-suppression second-order, no silence-suppression second-order, Silence Suppression 2nd order disabled in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3342    @globalid=2473099    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no silence-suppression second-order, no silence-suppression second-order, Silence Suppression 2nd order disabled in ONT
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-codec second-order=ulaw 
    dprov_sip_profile    eutA    ${sip_profile}    =silence-suppression second-order
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

  