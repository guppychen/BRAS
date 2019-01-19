*** Settings ***
Documentation     SIP Profile modification of Secondary Proxy Server port
Resource          ./base.robot


*** Variables ***



*** Test Cases ***
tc_SIP_Profile_with_Proxy_Server_Port_Secondary
    [Documentation]    1、Edit SIP Profile with proxy-server-port-secondary =1 and 65535, proxy-server-port-secondary=selection
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3300    @globalid=2473057    @priority=P3    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Edit SIP Profile with proxy-server-port-secondary =1 and 65535, proxy-server-port-secondary=selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${proxy_server_secondary1}    ${proxy_server_port_secondary1}    
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    proxy-server-port-secondary=${proxy_server_port_secondary1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_port_secondary1}    Proxy Secondary Port
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${proxy_server_secondary2}    ${proxy_server_port_secondary2}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    proxy-server-port-secondary=${proxy_server_port_secondary2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_port_secondary2}    Proxy Secondary Port

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =proxy-server-port-secondary
    dprov_sip_profile    eutA    ${sip_profile}    =proxy-server-secondary
  