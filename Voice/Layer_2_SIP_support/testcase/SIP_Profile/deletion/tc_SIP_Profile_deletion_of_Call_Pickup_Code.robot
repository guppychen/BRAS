*** Settings ***
Documentation     SIP Profile deletion of Call Pickup Code
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Call_Pickup_Code
    [Documentation]    1. no call-pickup-code, call-pickup-code = NULL, Call pickup code =
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3407    @globalid=2473164    @priority=P1    @eut=GPON-8r2     @user_interface=CLI   @jira=EXA-24853
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no call-pickup-code, call-pickup-code = NULL, Call pickup code =
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    call-pickup-code=${call_pickup_code}
    #failed, CLI doesn't include this command, unknown command
    dprov_sip_profile    eutA    ${sip_profile}    =call-pickup-code
    
    ${res}    cli    eutA    show running-config sip-profile ${sip_profile}
    should not contain    ${res}    call-pickup-code
    cli    eutA    end   
    
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${call_pickup_code}    Call pickup code

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  