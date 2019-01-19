*** Settings ***
Documentation     Sip Profile Secondary Proxy server port default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Sip_Profile_Secondary_Proxy_server_port_default
    [Documentation]    1、Enter SIP-Profile without specifying proxy-server-port-secondary, proxy-server-port-secondary=5060
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3299    @globalid=2473056    @priority=P1    @eut=GPON-8r2    @user_interface=CLI    
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Enter SIP-Profile without specifying proxy-server-port-secondary, proxy-server-port-secondary=5060
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    proxy-server-port-secondary=${proxy_server_port_secondary}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  