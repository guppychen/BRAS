*** Settings ***
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=bswamina
Resource          base.robot

*** Variables ***
${type_and_select}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="198"> <get-config> <source> <running/> </source> <filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/config/system/hostname"/> </get-config> </rpc> \
${select_alone}    <?xml version="1.0" encoding="utf-8"?> <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="199"> <get-config> <source> <running/> </source> <filter xmlns:t="http://www.calix.com/ns/exa/base" select="/config/system/hostname"/> </get-config> </rpc>
${type_alone}     <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="198"> <get-config> <source> <running/> </source> <filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath"/> </get-config> </rpc>

*** Test Cases ***
tc_EXA_Device_must_set_filter_type_attribute_select_attribute_together_and_alone
    [Documentation]    1. send "get-config" rpc with an XPATH using type=xpath and select={xpath query}
    ...    2. send "get-config" rpc with an XPATH using select={xpath query} and not using type=xpath
    ...    3. send "get-config" rpc with an XPATH using type=xpath and not using select={xpath query}
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1790    @globalid=2322321

    log    STEP:1. send "get-config" rpc with an XPATH using type=xpath and select={xpath query}
    ${hostname}    Get hostname    n1_session1    find_hostname
    ${hostname}    strip string    ${hostname}

    ${elem}    Raw netconf configure    n1_session3    ${type_and_select}    hostname
    ${res}    XML.Get Element Text    @{elem}
    ${res}    strip string    ${res}
    run keyword if    '${res}' == '${hostname}'    log    Hostname of device retrieved by NETCONF matches configuration
    ...    ELSE    fail    msg=Hostname retrieved by NETCONF is diff from configuration

    log    STEP:2. send "get-config" rpc with an XPATH using select={xpath query} and not using type=xpath
    ${elem}    Raw netconf configure    n1_session3    ${select_alone}    data
    ${res}    XML.Get Element Text    @{elem}
    Should Be Empty    ${res}

    log    STEP:3. send "get-config" rpc with an XPATH using type=xpath and not using select={xpath query}
    ${elem}    Raw netconf configure    n1_session3    ${type_alone}    error-tag
    Element Text Should Match    @{elem}    missing-attribute
