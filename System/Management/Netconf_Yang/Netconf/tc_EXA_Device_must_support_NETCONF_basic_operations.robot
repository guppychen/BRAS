*** Settings ***
Documentation     EXA Device must support NETCONF basic operations per RFC 4741/RFC 6241
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=bswamina
Resource          ./base.robot


*** Variables ***

${get_config}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="3"><get-config/></rpc>

${edit_config}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="4"><edit-config/></rpc>

${copy_config}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="5"><copy-config/></rpc>

${delete_config}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="6"><delete-config/></rpc>

${session_lock}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="3"><lock/></rpc>

${session_unlock}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="3"><unlock/></rpc>

${session_kill}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="101"><kill-session/></rpc>

${get_schema}  <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><get><filter type="subtree"><ncm:netconf-state xmlns:ncm="urn:ietf:params:xml:ns:yang:ietf-netconf-monitoring"><ncm:schemas/></ncm:netconf-state></filter></get></rpc>

${close_session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>

*** Test Cases ***
tc_EXA_Device_must_support_NETCONF_basic_operations
    [Documentation]    1. Send an empty "get-config" rpc - rpc-error due to invalid argument
    ...    2. Send an empty "edit-config" rpc - rpc-error due to invalid argument
    ...    3. Send an empty "copy-config" rpc - rpc-error due to invalid argument
    ...    4. Send an empty "delete-config" rpc - rpc-error due to invalid argument
    ...    5. send an empty "lock" rpc - rpc-error due to invalid argument
    ...    6. send an "unlock" rpc - rpc-error due to invalid argument
    ...    7. Send a "get" rpc - returns rpc-reply containing data
    ...    8. send an empty "kill" rpc - rpc-error due to invalid argument
    ...    9.  	send "close" rpc returns rpc "ok" and closes session.
    [Tags]       @TCID=AXOS_E72_PARENT-TC-1817        @globalid=2322348     dual_card_not_support   @jira=EXA-29537

    log    STEP:1. Send an empty "get-config" rpc - rpc-error due to invalid argument
    ${elem}    Raw netconf configure    n1_session3    ${get_config}   error-tag
    Element Text Should Match    @{elem}    missing-element

    log    STEP:2. Send an empty "edit-config" rpc - rpc-error due to invalid argument
    ${elem}    Raw netconf configure    n1_session3    ${edit_config}   error-tag
    Element Text Should Match    @{elem}    missing-element

    log    STEP:3. Send an empty "copy-config" rpc - rpc-error due to invalid argument
    ${elem}    Raw netconf configure    n1_session3    ${copy_config}   error-tag
    Element Text Should Match    @{elem}    missing-element

    log    STEP:4. Send an empty "delete-config" rpc - rpc-error due to invalid argument
    ${elem}    Raw netconf configure    n1_session3    ${delete_config}   error-tag
    Element Text Should Match    @{elem}    missing-element

    log    STEP:5. send an empty "lock" rpc - rpc-error due to invalid argument
    ${elem}    Raw netconf configure    n1_session3    ${session_lock}   error-tag
    Element Text Should Match    @{elem}    missing-element

    log    STEP:6. send an "unlock" rpc - rpc-error due to invalid argument
    ${elem}    Raw netconf configure    n1_session3    ${session_unlock}   error-tag
    Element Text Should Match    @{elem}    missing-element

    log    STEP:7. Send a "get" rpc - returns rpc-reply containing data
    ${elem}    Raw netconf configure    n1_session3    ${get_schema}   identifier
    Should contain  ${elem[0].text}  aaa

    log    STEP:8. send an empty "kill" rpc - rpc-error due to invalid argument
    ${elem}    Raw netconf configure    n1_session3    ${session_kill}   error-tag
    Element Text Should Match    @{elem}    missing-element

    log    STEP:9. send "close" rpc returns rpc "ok" and closes session.
    # close the netconf session
    Raw netconf configure    n1_session3    ${close_session}    ok
