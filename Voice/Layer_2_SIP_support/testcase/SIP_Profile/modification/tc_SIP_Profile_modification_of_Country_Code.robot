*** Settings ***
Documentation     SIP Profile modification of Country Code
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Country_Code
    [Documentation]    1. Edit SIP-Profile country-code = 64, country-code = 64, Country Code = 64
    ...    2. Edit SIP-Profile country-code = 10000, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3390    @globalid=2473147    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile country-code = 64, country-code = 64, Country Code = 64
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    country-code=${country_code_3}        
    
    # check ont is reseting
    Wait Until Keyword Succeeds    5min    10sec    check_ont_not_discovered    eutA    ${service_model.subscriber_point1.attribute.serial_number}    
    Wait Until Keyword Succeeds    5min    10sec    check_ont_discovered    eutA    ${service_model.subscriber_point1.attribute.ont_id}
    check_ont_reset_success    ontA
    
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    country-code=${country_code_3}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${country_code_3}    Country Code
    
    
    log    STEP:2. Edit SIP-Profile country-code = 10000, command rejected
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
    