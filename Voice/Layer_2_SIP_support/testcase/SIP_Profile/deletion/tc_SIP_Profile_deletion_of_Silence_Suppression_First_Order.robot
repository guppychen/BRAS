*** Settings ***
Documentation     SIP Profile deletion of Silence Suppression First Order
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Silence_Suppression_First_Order
    [Documentation]    1. no silence-suppression first-order, no silence-suppression first-order, Silence Suppression 1st order disabled in ONT
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3338    @globalid=2473095    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no silence-suppression first-order, no silence-suppression first-order, Silence Suppression 1st order disabled in ONT
    dprov_sip_profile    eutA    ${sip_profile}    =silence-suppression first-order
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    no=silence-suppression first-order
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_pro_RTP    ontA    1st Order    Silence Suppression    ${sil_sup_def}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  