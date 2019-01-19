*** Settings ***
Documentation     EXA Device by default should not have the TAC user in it's database
Force Tags        @author=rakrishn    @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support
Resource          ./base.robot

*** Variables ***
${calixsupport_usr}    calixsupport
${device_prompt}    calix

*** Test Cases ***
tc_EXA_Device_by_default_should_not_have_the_TAC_user
    [Documentation]    1.Use the CLI command "show running-config aaa" to verify no user TAC is displayed
    [Tags]    @author=rakrishn    @TCID=AXOS_E72_PARENT-TC-2436   @jira=EXA-30910

    log    STEP:1.Use the CLI command "show running-config aaa" to verify no user TAC is displayed
    cli    n1_session1    show running-config aaa
    Result should not contain    ${calixsupport_usr}

    log    STEP:2 Verify that a password algorithm exists for a Calix tac user to access the EXA device
    wait until keyword succeeds   6x   20s    check clock by dynamic passwaord    dynamic_password_dpu

    cli    dynamic_password_dpu    shell
    Result Should not contain    syntax error

    cli    dynamic_password_dpu    pwd
    Result Should not contain    syntax error

    cli    dynamic_password_dpu    exit