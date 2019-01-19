*** Settings ***
Documentation     SIP Profile deletion of Proxy Server Port 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Proxy_Server_Port
    [Documentation]    1、No Proxy-server-port
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3294    @globalid=2473051    @priority=P3    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、No Proxy-server-port
    dprov_sip_profile    eutA    ${sip_profile}    =proxy-server-port
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    proxy-server-port=${proxy_server_port}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_port}    Proxy Port     


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  