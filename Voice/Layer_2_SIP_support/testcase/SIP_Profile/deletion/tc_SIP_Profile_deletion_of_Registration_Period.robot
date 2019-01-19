*** Settings ***
Documentation     SIP Profile deletion of Registration Period
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Registration_Period
    [Documentation]    1. no registration-period, registration period = 3600, Registration Period = 3600 (sec)
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3359    @globalid=2473116    @eut=GPON-8r2    @priority=P3    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no registration-period, registration period = 3600, Registration Period = 3600 (sec)
    dprov_sip_profile    eutA    ${sip_profile}    =registration-period
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

  