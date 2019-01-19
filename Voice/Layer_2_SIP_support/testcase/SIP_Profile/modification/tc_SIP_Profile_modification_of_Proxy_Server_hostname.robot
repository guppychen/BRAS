*** Settings ***
Documentation     SIP Profile modification of Proxy Server hostname
Resource          ./base.robot


*** Variables ***
${proxy_server_newhostname}    newhostname        

*** Test Cases ***
tc_SIP_Profile_modification_of_Proxy_Server_hostname
    [Documentation]    1、Make sure the hostname can be modified
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3290    @globalid=2473047    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Make sure the hostname can be modified
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server_newhostname}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    proxy-server=${proxy_server_newhostname}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_server_newhostname}    Proxy

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  