*** Settings ***
Documentation     SIP Profile with Registration Period
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_Registration_Period
    [Documentation]    1. Enter SIP-Profile registration-period = 60 and 86400, registration period = selection, Registration Period = selection (sec)
    ...    2. Enter a SIP-Profile registration-period < 60 and > 86400, Command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3357    @globalid=2473114    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile registration-period = 60 and 86400, registration period = selection, Registration Period = selection (sec)
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    registration-period=${registration_period_60}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    registration-period=${registration_period_60}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${registration_period_60}    Registration Period    
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    registration-period=${registration_period_86400}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    registration-period=${registration_period_86400}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${registration_period_86400}    Registration Period    
    
    log    STEP:2. Enter a SIP-Profile registration-period < 60 and > 86400, Command rejected
    cli    eutA    configure
    cli    eutA    sip-profile ${sip_profile} 
    ${res}    cli    eutA    registration-period ${registration_period_59} 
    should contain    ${res}    "${registration_period_59}" is out of range   
    cli    eutA    sip-profile ${sip_profile} 
    ${res}    cli    eutA    registration-period ${registration_period_86401}
    should contain    ${res}    "${registration_period_86401}" is out of range   
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
    dprov_sip_profile    eutA    ${sip_profile}    =registration-period

  