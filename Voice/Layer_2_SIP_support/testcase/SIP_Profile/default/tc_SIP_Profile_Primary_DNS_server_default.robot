*** Settings ***
Documentation     SIP Profile Primary DNS server default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Primary_DNS_server_default
    [Documentation]    1、SIP-Profile entered without dns-primary, dns-primary = NULL
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3303    @globalid=2473060    @priority=P3    @eut=GPON-8r2    @user_interface=CLI  
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、SIP-Profile entered without dns-primary, dns-primary = NULL
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    dns-primary=${dns_primary}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${dns_primary}    Primary DNS     

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  