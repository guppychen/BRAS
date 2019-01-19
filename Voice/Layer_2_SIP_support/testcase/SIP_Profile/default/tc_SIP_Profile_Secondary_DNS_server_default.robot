*** Settings ***
Documentation     SIP Profile Secondary DNS server default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Secondary_DNS_server_default
    [Documentation]    1、Enter SIP-Profile without dns-server-secondary, dns-secondary = NULL
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3307    @globalid=2473064    @priority=P3    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Enter SIP-Profile without dns-server-secondary, dns-secondary = NULL
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    dns-secondary=${dns_secondary}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${dns_secondary}    Secondary DNS    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  