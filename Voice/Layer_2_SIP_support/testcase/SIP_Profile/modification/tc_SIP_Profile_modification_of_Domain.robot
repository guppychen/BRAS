*** Settings ***
Documentation     SIP Profile modification of Domain
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Domain
    [Documentation]    1. Edit SIP-Profile domain = a.cdefghijklmnopqrstuvwxyz.ABCDEFGHIGKLMNOPQRSTUWWXYZ1234567890, domain = a.cdefghijklmnopqrstuvwxyz.ABCDEFGHIGKLMNOPQRSTUWWXYZ1234567890
    ...    2. Edit SIP-Profile domain > 63 char, Command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3386    @globalid=2473143    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile domain = a.cdefghijklmnopqrstuvwxyz.ABCDEFGHIGKLMNOPQRSTUWWXYZ1234567890, domain = a.cdefghijklmnopqrstuvwxyz.ABCDEFGHIGKLMNOPQRSTUWWXYZ1234567890
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    domain=${domain_2}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    domain=${domain_2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${domain_2}    Domain 
    
    log    STEP:2. Edit SIP-Profile domain > 63 char, Command rejected
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_Profile} domain ${domain_3}
    should contain    ${res}    Command Rejected
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
    dprov_sip_profile    eutA    ${sip_profile}    =domain