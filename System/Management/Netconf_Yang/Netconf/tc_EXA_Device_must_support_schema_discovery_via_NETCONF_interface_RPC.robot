*** Settings ***
Documentation     Send the necessary RPCs to retreive the schema being used
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=kshettar
Resource          ./base.robot

*** Variables ***
${getschema}      <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><get><filter type="subtree"><ncm:netconf-state xmlns:ncm="urn:ietf:params:xml:ns:yang:ietf-netconf-monitoring"><ncm:schemas/></ncm:netconf-state></filter></get></rpc>

*** Test Cases ***
tc_EXA_Device_must_support_schema_discovery_via_NETCONF_interface_RPC
    [Documentation]    1 Open netconf session: ssh < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password. Enter password
    ...    2 Send "hello" rpc. Does not reject. Enable "urn:ietf:params:netconf:base:1.0" capability
    ...    3 send "get-schema" rpc. Returns the schema. Alternatively, it might be a "get" rpc filtering for the schema.
    [Tags]    @author=kshettar    @TCID=AXOS_E72_PARENT-TC-1813        @globalid=2322344   dual_card_not_support   @jira=EXA-29537
    log    send "get-schema" rpc. Returns the schema. Alternatively, it might be a "get" rpc filtering for the schema.
    
    #Get schema and verify
    @{res}    Raw netconf configure    n1_session3    ${getschema}    identifier
    should be equal as strings    ${res[0].text}    aaa

