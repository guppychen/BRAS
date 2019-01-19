*** Settings ***
Documentation     SIP Profile Registration Period default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Registration_Period_default
    [Documentation]    1. Enter SIP-Profile without registration-period, registration period = 3600, Registration Period = 3600 (sec)
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3356    @globalid=2473113    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without registration-period, registration period = 3600, Registration Period = 3600 (sec)
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    registration-period=${registration_period}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${registration_period}    Registration Period    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

