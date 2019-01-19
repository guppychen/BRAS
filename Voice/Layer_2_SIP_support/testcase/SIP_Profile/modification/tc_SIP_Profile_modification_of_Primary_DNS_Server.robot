*** Settings ***
Documentation     SIP Profile modification of Primary DNS Server
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Primary_DNS_Server
    [Documentation]    1、Edit SIP Profile with dns-primary=aa.bb.cc.ee, dns-primary = aa.bb.cc.ee
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3305    @globalid=2473062    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Edit SIP Profile with dns-primary=aa.bb.cc.ee, dns-primary = aa.bb.cc.ee
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    dns-primary=${dns_primary_2}    
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    dns-primary=${dns_primary_2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${dns_primary_2}    Primary DNS 

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =dns-primary
  