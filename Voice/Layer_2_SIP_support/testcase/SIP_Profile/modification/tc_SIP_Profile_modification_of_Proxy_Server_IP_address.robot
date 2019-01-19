*** Settings ***
Documentation     SIP Profile modification of Proxy Server IP address
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Proxy_Server_IP_address
    [Documentation]    1、Make sure the IP address can be modified
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3288    @globalid=2473045    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Make sure the IP address can be modified
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    proxy-server=${proxy_server}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server}    Proxy

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log     case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown    