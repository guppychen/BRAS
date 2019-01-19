*** Settings ***
Documentation     SIP Profile deletion of Country Code
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Country_Code
    [Documentation]    1. no country-code, country-code = 1, Country Code = 1
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3391    @globalid=2473148    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no country-code, country-code = 1, Country Code = 1
    dprov_sip_profile    eutA    ${sip_profile}    =country-code
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    country-code=${country_code}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${country_code}    Country Code

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  