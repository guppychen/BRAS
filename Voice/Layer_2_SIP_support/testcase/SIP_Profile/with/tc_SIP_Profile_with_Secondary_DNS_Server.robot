*** Settings ***
Documentation     SIP Profile with Secondary DNS Server
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_Secondary_DNS_Server
    [Documentation]    1、Enter SIP Profile with dns-secondary = aa.bb.cc.dd, dns-secondary = aa.bb.cc.dd
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3308    @globalid=2473065    @priority=P1    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Enter SIP Profile with dns-secondary = aa.bb.cc.dd, dns-secondary = aa.bb.cc.dd
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    dns-secondary=${dns_secondary_1}    
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    dns-secondary=${dns_secondary_1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${dns_secondary_1}    Secondary DNS



*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =dns-secondary

