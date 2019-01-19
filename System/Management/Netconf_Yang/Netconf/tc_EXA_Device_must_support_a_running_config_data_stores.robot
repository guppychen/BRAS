*** Settings ***
Resource          ./base.robot
Force tags       @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao      @author=ysnigdha

*** Variables ***
${get_running}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get-config><source><running/></source></get-config></rpc>
${new_hostname}    NEW_PROMPT
${get_hostname}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="198"> <get-config> <source> <running/> </source> <filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/config/system/hostname"/> </get-config> </rpc> \
${set_hostname}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${new_hostname}</hostname></system></config></config>
${lock_running}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><lock><target><running/></target></lock></rpc>
${unlock_running}    <rpc message-id="110" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><unlock><target><running/></target></unlock></rpc>
${delete_running}    <?xml version="1.0" encoding="UTF-8"?><rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><delete-config><target><running/></target></delete-config></rpc>
${file}           running_copy
${copy_config}    <?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><copy-config><target><url>file:///${file}</url></target><source><running/></source></copy-config></rpc>

*** Test Cases ***
tc_EXA_Device_must_support_a_running_config_data_stores
    [Documentation]    Support running config data stores
    [Tags]    @user=root    @TCID=AXOS_E72_PARENT-TC-1766    @globalid=2322297
    [Setup]    AXOS_E72_PARENT-TC-1766 setup

    #Verifying various possible operations on RUNNING config
    # Check if running config can be retrieved from the Device
    ${run_host}    set variable    <hostname>${device_name}</hostname>
    ${run}    Netconf Raw    n1_session3    xml=${get_running}

    #Checking if hostnameare retrieved from running config
    Should contain    ${run.xml}    ${run_host}

    #Lock Running Datastore
    Raw netconf configure    n1_session3    ${lock_running}    ok

    #Verifying Edit operation on running datastore of Device by modifying hostname
    Edit netconf configure    n1_session3    ${set_hostname}    ok

    # Verify Running config has been modified
    @{elem}    Raw netconf configure    n1_session3    ${get_hostname}    hostname
    log    ${elem[0].text}
    Should be equal as strings    ${elem[0].text}    ${new_hostname}

    # Copy Running config to a file and check for the modification
    ${elem}    Raw netconf configure    n1_session3    ${copy_config}    ok

    #Verify from cli that file is created and has the running config changes
    ${run_host}    set variable    <hostname>${new_hostname}</hostname>
    cli    n1_session2    cd /tmp/confd/state/
    ${runn}    cli    n1_session2    cat ${file} | grep "hostname"    \\#    30
    Should contain    ${runn}    ${run_host}

    #Delete operation on running config should not be supported
    @{del}    Raw netconf configure    n1_session3    ${delete_running}    bad-element
    Should contain    ${del[0].text}    url

    [Teardown]    AXOS_E72_PARENT-TC-1766 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1766 setup
    [Documentation]    AXOS_E72_PARENT-TC-1766 setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1766 setup
    cli    n1_session1    clear active event-log

    #reverting hostname
    ${get_hostname}    Get hostname    n1_session1    ${default_hostname}
    ${get_hostname}    Strip string    ${get_hostname}
    Set Global Variable    ${device_name}    ${get_hostname}

AXOS_E72_PARENT-TC-1766 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1766 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1766 teardown
    #Unlock Running config
    Raw netconf configure    n1_session3    ${unlock_running}    ok

    #remove Running config copy
    cli    n1_session2    rm -f /tmp/confd/state/${file}

    #Revert hostname
    ${hst}    set variable    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${device_name}</hostname></system></config></config>
    Edit netconf configure    n1_session3    ${hst}    ok
