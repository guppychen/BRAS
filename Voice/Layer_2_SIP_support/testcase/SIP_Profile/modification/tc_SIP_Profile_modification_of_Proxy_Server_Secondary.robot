*** Settings ***
Documentation     SIP Profile modification of Secondary Proxy Server IP address
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Proxy_Server_Secondary
    [Documentation]    1、Set proxy-server-secondary = aa.bb.cc.ee
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3297    @globalid=2473054    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Set proxy-server-secondary = aa.bb.cc.ee
    ${proxy_ser_sec}    set variable    10.245.250.2
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${proxy_ser_sec}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    proxy-server-secondary=${proxy_ser_sec}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${proxy_ser_sec}    Proxy Secondary


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case sestup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =proxy-server-secondary
  