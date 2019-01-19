*** Settings ***
Documentation     SIP Profile deletion of Proxy Server Secondary
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Proxy_Server_Secondary
    [Documentation]    1、No secondary-proxy-server
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3298    @globalid=2473055    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、No secondary-proxy-server
    cli    eutA    configure
    Axos Cli With Error Check    eutA    sip-profile ${sip_profile}
    ${res}    cli    eutA    no proxy-server-secondary    
    cli    eutA    end
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    proxy-server-secondary=${proxy_server_secondary}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_profile    ontA    ${proxy_server_secondary}    Proxy Secondary      
    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  