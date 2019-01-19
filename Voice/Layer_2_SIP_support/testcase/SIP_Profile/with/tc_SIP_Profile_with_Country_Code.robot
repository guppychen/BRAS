    
*** Settings ***
Documentation     SIP Profile with Country Code
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_Country_Code
    [Documentation]    1. Enter SIP-Profile country-code = 9000, country-code = 9000, Country Code = 9000
    ...    2. Enter SIP-Profile country-code = 10000, command rejected, "10000" is out of range
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3389    @globalid=2473146    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile country-code = 9000, country-code = 9000, Country Code = 9000
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    country-code=${country_code_1}
    # check ont is rebooting
    Wait Until Keyword Succeeds    3min    10sec    check_ont_not_discovered    eutA    ${service_model.subscriber_point1.attribute.serial_number}    
    Wait Until Keyword Succeeds    5min    10sec    check_ont_discovered    eutA    ${service_model.subscriber_point1.attribute.ont_id}
    check_ont_reset_success    ontA
    
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    country-code=${country_code_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${country_code_1}    Country Code
    
    
    log    STEP:2. Enter SIP-Profile country-code = 10000, command rejected, "10000" is out of range
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_Profile} country-code ${country_code_2}
    should contain    ${res}    "${country_code_2}" is out of range
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
    dprov_sip_profile    eutA    ${sip_profile}    =country-code
    Wait Until Keyword Succeeds    3min    10sec    check_ont_not_discovered    eutA    ${service_model.subscriber_point1.attribute.serial_number}    
    
    Wait Until Keyword Succeeds    3min    10sec    check_ont_discovered    eutA    ${service_model.subscriber_point1.attribute.ont_id}
    check_ont_reset_success    ontA

  