*** Settings ***
Documentation     SIP Profile with of Proxy Server Secondary 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_of_Proxy_Server_Secondary
    [Documentation]    1、Make sure the IP address (aa.bb.cc.dd) can be modified
    ...    2、Enter proxy-server-secondary = hostname
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3296    @globalid=2473053    @priority=P1    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Make sure the IP address (aa.bb.cc.dd) can be modified
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${proxy_server_secondary_ip}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    proxy-server-secondary=${proxy_server_secondary_ip}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_secondary_ip}    Proxy Secondary
    log    STEP:2、Enter proxy-server-secondary = hostname
    cli    eutA    configure
    Axos Cli With Error Check    eutA    sip-profile ${sip_profile}
    ${res}    cli    eutA    proxy-server-secondary ${proxy_server_secondary_host}
    should contain    ${res}    Command Rejected    
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
    dprov_sip_profile    eutA    ${sip_profile}    =proxy-server-secondary