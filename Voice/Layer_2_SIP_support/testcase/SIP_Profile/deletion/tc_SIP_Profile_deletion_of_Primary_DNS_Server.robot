*** Settings ***
Documentation     SIP Profile deletion of Primary DNS Server
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Primary_DNS_Server
    [Documentation]    1、No dns-primary, dns-primary = NULL
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3306    @globalid=2473063    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、No dns-primary, dns-primary = NULL
    dprov_sip_profile    eutA    ${sip_profile}    =dns-primary
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

  