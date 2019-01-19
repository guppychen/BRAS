*** Settings ***
Documentation     SIP Profile deletion of Local Hook Flash
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Local_Hook_Flash
    [Documentation]    1. no local-hook-flash, no local-hook-flash
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3375    @globalid=2473132    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no local-hook-flash, no local-hook-flash
    dprov_sip_profile    eutA    ${sip_profile}    =local-hook-flash
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    local-hook-flash=${EMPTY}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    enabled    Local Hook Flash



*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  