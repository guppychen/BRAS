*** Settings ***
Documentation     The CLI user MUST be able to turn on and off pagination for the current CLI session.
Resource          ./base.robot
Force Tags      @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support        @author=ysnigdha

*** Variables ***

*** Test Cases ***
tc_The_CLI_user_MUST_be_able_to_turn_on_and_off_pagination
    [Documentation]    1 The CLI user MUST be able to turn on and off pagination for the current CLI session. CLI command is "paginate TRUE or FALSE"
    [Tags]    @author=ysnigdha    @TCID=AXOS_E72_PARENT-TC-2434
    [Teardown]   AXOS_E72_PARENT-TC-2434 teardown

    log    STEP:1 The CLI user MUST be able to turn on and off pagination for the current CLI session. CLI command is "paginate TRUE or FALSE"
    # setting pagination to false
    cli    n1_session1    paginate false
    ${res}    cli    n1_session1    show cli | include paginate
    should match regexp    ${res}    paginate[\\s]+false

    # setting pagination to true
    cli    n1_session1    paginate true
    ${res}    cli    n1_session1    show cli | include paginate
    should match regexp    ${res}    paginate[\\s]+true

*** Keywords ***
AXOS_E72_PARENT-TC-2434 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2434 teardown
    # setting pagination to true
    cli    n1_session1    paginate true
    ${res}    cli    n1_session1    show cli | include paginate
    should match regexp    ${res}    paginate[\\s]+true

