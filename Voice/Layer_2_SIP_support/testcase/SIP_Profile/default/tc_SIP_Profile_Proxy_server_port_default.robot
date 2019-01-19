*** Settings ***
Documentation     SIP Profile Proxy server port default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Proxy_server_port_default
    [Documentation]    1、Make sure the SIP-Profile can be entered without specifying proxy server port
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3292    @globalid=2473049    @priority=P1    @eut=GPON-8r2    @user_interface=CLI    
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Make sure the SIP-Profile can be entered without specifying proxy server port
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    proxy-server-port=${proxy_server_port}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_profile    ontA    ${proxy_server_port}    Proxy Port    

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  