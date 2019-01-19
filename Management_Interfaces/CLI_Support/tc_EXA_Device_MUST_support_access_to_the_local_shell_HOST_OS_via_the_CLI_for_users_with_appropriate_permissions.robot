*** Settings ***
Documentation     In order to access the host OS, users with the appropriate permission must first login into the CLI in a secure manner, and then from there they can access the host OS via a command shell that provides secure access to local host unix shell.
Resource          ./base.robot
Force Tags      @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support        @author=pmunisam

*** Variables ***
${calixsupport_usr}    calixsupport
${device_prompt}    calix

*** Test Cases ***
tc_EXA_Device_MUST_support_access_to_the_local_shell_HOST_OS_via_the_CLI_for_users_with_appropriate_permissions
    [Documentation]    In order to access the host OS, users with the appropriate permission must first login into the CLI in a secure manner; and then from there they can access the host OS via a command shell that provides secure access to local host unix shell. As Stated Note/this is the only available means to access the host OS after the manufacturing process completes.
    [Tags]    @author=pmunisam    @TCID=AXOS_E72_PARENT-TC-2430  @jira=EXA-30910
    log    STEP:In order to access the host OS, users with the appropriate permission must first login into the CLI in a secure manner; and then from there they can access the host OS via a command shell that provides secure access to local host unix shell. As Stated Note/this is the only available means to access the host OS after the manufacturing process completes.

    wait until keyword succeeds   6x   20s    check clock by dynamic passwaord    dynamic_password_dpu

    cli    dynamic_password_dpu    shell
    Result Should not contain    syntax error
    cli    dynamic_password_dpu    exit
    
    # Checking the read operation
    cli    dynamic_password_dpu    show version
    Result Should not contain    syntax error


*** Keywords ***

test using dynamic
    [Documentation] test with dynamic