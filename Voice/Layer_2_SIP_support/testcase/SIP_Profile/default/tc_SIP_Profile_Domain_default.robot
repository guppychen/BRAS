*** Settings ***
Documentation     SIP Profile Domain default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Domain_default
    [Documentation]    1. Enter SIP-Profile without domain, domain = no, Domain = 
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3384    @globalid=2473141    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without domain, domain = no, Domain =
    ${res}    cli    eutA    show running-config sip-profile ${sip_profile} | detail    
    should not contain    ${res}    domain 
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${domain}    Domain     
        


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  