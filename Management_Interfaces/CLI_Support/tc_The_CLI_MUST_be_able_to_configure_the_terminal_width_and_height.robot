*** Settings ***
Documentation     The CLI MUST provide a command that can adjust the terminal width and height for a given CLI user session.
Resource          ./base.robot
Force Tags      @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support      @author=upandiri

*** Variables ***
${length}         300
${width}          250

*** Test Cases ***
tc_The_CLI_MUST_be_able_to_configure_the_terminal_width_and_height
    [Documentation]    1 The CLI MUST provide a command that can adjust the terminal width and height for a given CLI user session. The commands are "terminal screen-length 0-32000" and terminal screen-width 0-512 As Stated    #    Action    Expected Result    Notes
    [Tags]    @author=upandiri    @TCID=AXOS_E72_PARENT-TC-2432
    [Teardown]   AXOS_E72_PARENT-TC-2432 teardown

    log    STEP:1 The CLI MUST provide a command that can adjust the terminal width and height for a given CLI user session. The commands are "terminal screen-length 0-32000" and terminal screen-width 0-512 As Stated
    cli    n1_session1    terminal screen-length ${length}
    cli    n1_session1    terminal screen-width ${width}

    #verifying screen length and width
    cli    n1_session1    show cli | include screen
    result match regexp    screen-length\\s+${length}
    result match regexp    screen-width\\s+${width}

*** Keywords ***
AXOS_E72_PARENT-TC-2432 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2432 teardown

    # setting length and width to default
    cli    n1_session1    terminal screen-length 24
    cli    n1_session1    terminal screen-width 80
