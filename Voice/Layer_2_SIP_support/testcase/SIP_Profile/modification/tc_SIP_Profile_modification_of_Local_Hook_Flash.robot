*** Settings ***
Documentation     SIP Profile with Local Hook Flash
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Local_Hook_Flash
    [Documentation]    1. Edit SIP-Profile local-hook-flash, local-hook-flash, Local Hook Flash = enabled
    ...    2. Edit SIP-Profile no local-hook-flash, no local-hook-flash, Local Hook Flash = enabled
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3374    @globalid=2473131    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile local-hook-flash, local-hook-flash, Local Hook Flash = enabled
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    local-hook-flash=
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    local-hook-flash=
    Wait Until Keyword Succeeds    5min    20sec    check_ont_sip_profile    ontA    enabled    Local Hook Flash
    
    log    STEP:2. Edit SIP-Profile no local-hook-flash, no local-hook-flash, Local Hook Flash = disabled
    dprov_sip_profile    eutA    ${sip_profile}    =local-hook-flash
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    local-hook-flash=
    Wait Until Keyword Succeeds    5min    20sec    check_ont_sip_profile    ontA    disabled    Local Hook Flash

 
*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  