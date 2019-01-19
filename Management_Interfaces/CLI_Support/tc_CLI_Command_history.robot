*** Settings ***
Documentation     The CLI session MUST provide a command history, that the user may use to retrieve previous commands.There MUST also be a command provided to clear the history
Force Tags        @author=rakrishn    @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support
Resource          ./base.robot

*** Variables ***
${command}        show running-config class-map

*** Test Cases ***
tc_CLI_Command_history_Rama
    [Documentation]    The CLI session MUST provide a command history, that the user may use to retrieve previous commands.There MUST also be a command provided to clear the history. Use the up arrow to retrieve previous commands. Then issue the command "clear history" and verify subsequent up arrows only display the one command "clear history".
    [Tags]    @author=rakrishn    @TCID=AXOS_E72_PARENT-TC-2435
    log    STEP:The CLI session MUST provide a command history, that the user may use to retrieve previous commands.There MUST also be a command provided to clear the history. Use the up arrow to retrieve previous commands. Then issue the command "clear history" and verify subsequent up arrows only display the one command "clear history".

    # Run any command to check in show history
    cli    n1_session1    ${command}
    cli    n1_session1    show history
    Result should contain    ${command}

    # Use up arrow key twice to check the last run command
    cli    n1_session1    \x1B[A
    cli    n1_session1    \x1B[A
    Result should contain    ${command}

    # Run clear history and to verify that it is last run command
    cli    n1_session1    clear history
    cli    n1_session1    \x1B[A
    Result should contain    clear history
