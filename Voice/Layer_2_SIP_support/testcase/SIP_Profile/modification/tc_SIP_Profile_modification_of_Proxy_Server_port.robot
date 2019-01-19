*** Settings ***
Documentation     SIP Profile modification of Proxy Server port
Resource          ./base.robot


*** Variables ***
${proxy_server_port1}    1
${proxy_server_port2}    65535
*** Test Cases ***
tc_SIP_Profile_modification_of_Proxy_Server_port
    [Documentation]    1、Make sure the Proxy Server port can be modified to 1
    ...    2、Make sure the Proxy Server port can be modified 65535
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3293    @globalid=2473050    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Make sure the Proxy Server port can be modified to 1
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${proxy_server_port1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    proxy-server-port=${proxy_server_port1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_port1}    Proxy Port 
    log    STEP:2、Make sure the Proxy Server port can be modified 65535
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${proxy_server_port2}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    proxy-server-port=${proxy_server_port2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_port2}    Proxy Port 


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    cli    eutA    configure
    cli    eutA    sip-profile ${sip_profile}
    cli    eutA    no proxy-server-port 
    cli    eutA    end 
  