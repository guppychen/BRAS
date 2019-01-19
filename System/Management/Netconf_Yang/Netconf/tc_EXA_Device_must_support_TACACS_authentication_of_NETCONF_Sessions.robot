*** Settings ***
Documentation     EXA Device must support TACACS+ authentication of NETCONF Sessions
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=ysnigdha
Resource          ./base.robot

*** Variables ***
@{list}           <tacacs><server><host>${tacacs_server1}</host>    <timeout>2</timeout></server></tacacs>
${hostname}       Newhost
${config-tacacs}    <config> <config xmlns="http://www.calix.com/ns/exa/base"> <system><aaa><authentication-order>tacacs-then-local</authentication-order><tacacs><server><host>${tacacs_server1}</host><secret>${tac_secret}</secret><timeout>2</timeout></server></tacacs></aaa> </system></config></config>
${validate-tacacs}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><get-config> <source> <running/> </source><filter type="xpath" select="/* /system/aaa"/></get-config></rpc>
${get-event}      <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="3"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath"    select="/status/system/event"/></get></rpc>
${edit-conf}      <config><config xmlns="http://www.calix.com/ns/exa/base"> <system><hostname>${hostname}</hostname></system></config> </config>
${verify-edit}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="4"><get-config><source><running/></source><filter type="xpath" select="/* /system/hostname"/></get-config></rpc>
${close}          <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><close-session/></rpc>

*** Test Cases ***
tc_EXA_Device_must_support_TACACS_authentication_of_NETCONF_Sessions
    [Documentation]     EXA Device must support TACACS+ authentication of NETCONF Sessions
    [Tags]    @author=ysnigdha    @TCID=AXOS_E72_PARENT-TC-1795        @globalid=2322326

    # Get device hostname
    ${device_name}    Get hostname    n1_session1    find_hostname
    ${device_name}    strip string    ${device_name}

    #Configure tacacs server
    ${tac}    Edit netconf configure    n1_session3    ${config-tacacs}    ok

    #Validate Tacacs Config
    ${val}    Netconf Raw    n1_session3    xml=${validate-tacacs}
    : FOR    ${key}    IN    @{list}
    \    Should Contain    ${val.xml}    ${key}

    #Login as administration and check privileges
    ${conn}=    Session copy info    n1_session3    user=${tac_user}    password=${tac_pwd}
    Session build local    n1_localsession    ${conn}
    
    ${event}    Netconf raw    n1_localsession    xml=${get-event}
    Should contain    ${event.xml}    user-login
    Should contain    ${event.xml}    ${tac_user}

    #validate role by performing edit config and verify change took place
    ${edit}    Edit netconf configure    n1_localsession    ${edit-conf}    ok
    ${verify}    Get attributes netconf    n1_localsession    //system/hostname    hostname
    ${hostname}    strip string    ${hostname}
    Should be Equal as Strings    ${verify[0].text}    ${hostname}
    ${edit-config_original}    set variable    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${device_name}</hostname></system></config></config>
    
    #reverting hostname
    ${var2}=    Edit netconf configure    n1_localsession    ${edit-config_original}    ok
    ${verify}    Get attributes netconf    n1_localsession    //system/hostname    hostname
    Should be Equal as Strings    ${verify[0].text}    ${device_name}
   
    #logout of netconf session 
    ${logout}    Netconf raw    n1_localsession    xml=${close}
    Should contain    ${logout.xml}    rpc-reply
  
    [Teardown]    AXOS_E72_PARENT-TC-1795 teardown    ${device_name}

*** Keywords ***
AXOS_E72_PARENT-TC-1795 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1795 teardown
    [Arguments]    ${device_name}
    log    Enter AXOS_E72_PARENT-TC-1795 teardown

    #reverting hostname
    ${edit-config_original}    set variable    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${device_name}</hostname></system></config></config>
    sleep   3s
    ${var2}=    Edit netconf configure    n1_localsession    ${edit-config_original}    ok
    ${verify}    Get attributes netconf    n1_localsession    //system/hostname    hostname
    Should be Equal as Strings    ${verify[0].text}    ${device_name}

    Session destroy local    n1_localsession
    cli    n1_session1    config
    cli    n1_session1    no aaa tacacs server ${tacacs_server1}
    cli    n1_session1    no aaa authentication-order
    cli    n1_session1    end

