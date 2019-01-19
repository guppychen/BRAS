*** Settings ***
Documentation     The CLI MUST provide a way for a user to configure the terminal type
Resource          ./base.robot
Force Tags     @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support        @author=sdas

*** Variables ***
@{type}    generic    xterm    vt100    ansi    linux

*** Test Cases ***
tc_CLI_MUST_allow_the_terminal_type_to_be_configured
    [Documentation]   	
    ...    The CLI MUST provide a way for a user to configure the terminal type.
    ...    The command is "terminal linux" or "terminal vt-100" for examples.
    ...    Type "terminal ?" for the entire list of terminal type options.	                                   As State
    [Tags]       @author=sdas     @TCID=AXOS_E72_PARENT-TC-2431
    [Teardown]   AXOS_E72_PARENT-TC-2431 teardown

    ### STEP:1 The CLI MUST provide a way for a user to configure the terminal type.The command is "terminal linux" or
    ### "terminal  vt-100" for examples.Type "terminal ?" for the entire list of terminal type options.

    :FOR    ${ELEMENT}    IN    @{type}
    \    cli    n1_session1    terminal ${ELEMENT}
    \    cli    n1_session1    show cli | include terminal
    \    Result Should Contain    ${ELEMENT}


*** Keywords ***
AXOS_E72_PARENT-TC-2431 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2431 teardown
    ### config default terminal type
    cli    n1_session1    terminal @{type}[4]
    cli    n1_session1    show cli | include terminal
    Result Should Contain    @{type}[4]
