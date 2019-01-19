*** Settings ***
Documentation     SIP Profile Call pickup code default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Call_Pickup_Code_default
    [Documentation]    1. Enter SIP-Profile without call-pickup-code, call-pickup-code = NULL, Call pickup code =
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3404    @globalid=2473161    @priority=P1    @eut=GPON-8r2    @user_interface=CLI 
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without call-pickup-code, call-pickup-code = NULL, Call pickup code =
    ${res}    cli    eutA    show running-config sip-profile ${sip_profile} | detail
    should not contain    ${res}    call-pickup-code
    cli    eutA    end    
    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  