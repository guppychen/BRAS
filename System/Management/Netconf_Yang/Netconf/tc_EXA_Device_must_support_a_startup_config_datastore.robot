*** Settings ***
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=bswamina
Resource          base.robot

*** Variables ***
${new_hostname}    configB
${type_and_select}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="198"> <get-config> <source> <running/> </source> <filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/config/system/hostname"/> </get-config> </rpc> \
${copy_config}    <?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><copy-configuration xmlns="http://www.calix.com/ns/exa/base"><to>startup-config</to><from>running-config</from></copy-configuration></rpc>
${configB}        <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${new_hostname}</hostname></system></config></config>

*** Test Cases ***
tc_EXA_Device_must_support_a_startup_config_datastore
    [Documentation]    1. Issue a command to save start-up config - copy start-up to running and verify copy completed
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1767     @globalid=2322298

    # Retrieve hostname before modifying
    ${hostname}    Get hostname    n1_session1    find_hostname
    ${device_name}    strip string    ${hostname}

    #AT-4773
    cli    n1_session1    accept running-config

    log    STEP:1. Issue a command to save start-up config - copy start-up to running and Verify copy completed
    #Modifying hostname via RPC
    Edit netconf configure    n1_session3    ${configB}    ok

    #Retrieving hostname using RPC and verification
    ${elem}    Raw netconf configure    n1_session3    ${type_and_select}    hostname
    ${res}    XML.Get Element Text    @{elem}
    ${res}    strip string    ${res}
    run keyword if    '${res}' == '${new_hostname}'    log    Hostname of device retrieved by NETCONF matches configuration
    ...    ELSE    fail    msg=Hostname retrieved by NETCONF is diff from configuration

    #Running to startup config with above config change
    ${elem}    Raw netconf configure    n1_session3    ${copy_config}    status
    Element Text Should Match    @{elem}    Copy completed.

    #Verificatoin of hostname change in database
    cli    n1_session2    cd /etc/config/    \\#    30
    ${res}    cli    n1_session2    cat startup-config.xml | grep -i hostname    \\#    30
    @{res}    should match regexp    ${res}    <hostname>(.*)<\\/hostname>
    run keyword if    '@{res}[1]' == '${new_hostname}'    log    copy run-config to startup-config SUCCESS
    ...    ELSE    fail    msg=copy run-config to startup-config FAILED

    [Teardown]    AXOS_E72_PARENT-TC-1767 teardown    ${device_name}

*** Keywords ***
AXOS_E72_PARENT-TC-1767 teardown
    [Arguments]    ${hostname}
    [Documentation]    AXOS_E72_PARENT-TC-1767 teardown
    log    Enter AXOS_E72_PARENT-TC-1767 teardown
    cli    n1_session1    configure
    cli    n1_session1    hostname ${hostname}
    cli    n1_session1    end
    cli    n1_session1    copy running-config startup-config
