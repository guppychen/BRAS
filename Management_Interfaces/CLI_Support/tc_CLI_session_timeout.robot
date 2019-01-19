*** Settings ***
Documentation     The CLI user MUST be provided with a session timeout configuration option. The value range for this should be 0 to 255 minutes, where 0 is used to disable timeouts.
Force Tags        @author=dzala    @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support
Resource          ./base.robot


*** Test Cases ***
tc_CLI_session_timeout
    [Documentation]    1 Issue the CLI command "idle-timeout 0"
    ...    2 Issue the CLI command "idle-timeout 60"
    ...    3 Log back in and Issue the CLI command "idle-timeout 8192"
    ...    4 Issue the CLI command "idle-timeout 8193"
    [Tags]    @author=dzala    @TCID=AXOS_E72_PARENT-TC-2433
    [Teardown]   AXOS_E72_PARENT-TC-2433 teardown
    log    STEP:1 Issue the CLI command "idle-timeout 0"

    cli    n1_session1    idle-timeout 0
    cli    n1_session1    show cli | include idle-timeout
    Result Match Regexp    idle-timeout[\\s]+0

    log    STEP:2 Issue the CLI command "idle-timeout 60"
    cli    n1_session1    idle-timeout 60
    ${result}    cli    n1_session1    show user-sessions session is-our-session TRUE
    ${res}    Build Response Map    ${result}
    ${resp}    Parse Nested Text    ${res}    start_line=2
    ${session-id}    Get Value From Nested Text    ${resp}    session-id

    #Wait 60 seconds for idle timout
    sleep    60
    cli    n1_session1    show user-sessions session session-id
    Result should not contain    session-id ${session-id}

    log    STEP:3 Log back in and Issue the CLI command "idle-timeout 8192"
    cli    n1_session1    idle-timeout 8192
    cli    n1_session1    show cli | include idle-timeout
    Result Match Regexp    idle-timeout[\\s]+8192

    log    STEP:4 Issue the CLI command "idle-timeout 8193"
    cli    n1_session1    idle-timeout 8193
    Result should contain    syntax error: "8193" is out of range

*** Keywords ***
AXOS_E72_PARENT-TC-2433 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2433 teardown

    # setting idle-timeout back to default
    cli    n1_session1    idle-timeout 1800

