*** Settings ***
Documentation     EXA Device must support filtering of alarms by severity for logging to the console or terminal.The user must be able to configure the minimum alarm severity threshold an alarm must have for it to be logged to the terminal or console per terminal or console session. Note the default severity threshold for a console is WARNING
Force Tags        @author=rakrishn    @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support
Resource          ./base.robot

*** Variables ***
${severity-level}    INFO
${alarm-type}     running-config-lock

*** Test Cases ***
tc_EXA_Device_must_support_filtering_of_alarms_by_severity_for_logging_to_the_console_or_terminal
    [Documentation]    Use the CLI command "session notification severity" to set filtering of alarms by severity for logging to the console or terminal. Note - Sets the minimum alarm severity level to display for the current session; as well as the associated clear notification. For example specifying MAJOR reports both major and critical alarms; and the associated clear notifications. Note: A notification matching the specified set-category or severity displays.
    [Tags]    @author=rakrishn    @TCID=AXOS_E72_PARENT-TC-2427
    [Teardown]   AXOS_E72_PARENT-TC-2427 teardown

    log    STEP:Use the CLI command "session notification severity" to set filtering of alarms by severity for logging to the console or terminal. Note - Sets the minimum alarm severity level to display for the current session; as well as the associated clear notification. For example specifying MAJOR reports both major and critical alarms; and the associated clear notifications. Note: A notification matching the specified set-category or severity displays.
    cli    n1_session1    session notification severity ${severity-level}

    # lock database and check for notification with the severity level
    cli    n1_session1    lock datastore running
    Result should contain    CONFIGURATION ALARM ${severity-level} '${alarm-type}'

    # unlock database and check for notification
    cli    n1_session1    unlock datastore running
    Result should contain    CONFIGURATION ALARM CLEAR '${alarm-type}'

    # verify the severity
    cli    n1_session1    show alarm definitions subscope name running-config-lock
    Result should contain    ${alarm-type}
    Result should contain    perceived-severity ${severity-level}

*** Keywords ***
AXOS_E72_PARENT-TC-2427 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2427 teardown

    # unlock database and check for notification
    cli    n1_session1    unlock datastore running
