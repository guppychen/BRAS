*** Settings ***
Documentation     There needs to be a single approach to generating session ids for all mgmt sessions. We do not want a distinct approach for netconf that differs from that of other user agents.
Force Tags     @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=upandiri
Resource          ./base.robot

*** Variables ***
${show_usersessions}    //status/system/user-sessions
${get-config}     <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="111"><get-config><source><running/></source></get-config></rpc>

*** Test Cases ***
tc_The_EXA_device_NetConf_session_id_MUST_be_consistent_approach_to_session_ids_created_for_all_mgmt_session
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1776        @globalid=2322307
    [Documentation]    EXA device Netconf session id MUST be consistent approach to session ids created for all mgmt session

    #verifying netconf session ids
    @{verify_sessions}    Get attributes netconf    n1_session3    ${show_usersessions}    session-id
    ${count}    get length    ${verify_sessions}
    : FOR    ${index}    IN RANGE    0    ${count}
    \    Should Match Regexp    ${verify_sessions[${index}].text}    \\d+

