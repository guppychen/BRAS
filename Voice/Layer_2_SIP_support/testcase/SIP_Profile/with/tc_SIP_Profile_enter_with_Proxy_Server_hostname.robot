*** Settings ***
Documentation     SIP Profile enter with Proxy Server hostname
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_enter_with_Proxy_Server_hostname
    [Documentation]    1、make sure the host name can be entered
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3289    @globalid=2473046    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Make sure the host name can be entered.
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server_hostname}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    proxy-server=${proxy_server_hostname}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_hostname}    Proxy

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown