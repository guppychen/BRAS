*** Settings ***
Documentation     SIP Profile deletion of Proxy Server IP Address 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Proxy_Server_IP_Address
    [Documentation]    1、No Proxy-server
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3291    @globalid=2473048    @priority=P3    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、No Proxy-server
    cli    eutA    configure
    Axos Cli With Error Check    eutA    sip-profile ${sip_profile}
    ${res}    cli    eutA    no proxy-server ${proxy_server}
    should contain    ${res}    element not found    
    cli    eutA    end

         


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  