*** Settings ***
Documentation     EXA device MUST support storing passwords in non-volatile store
Test Setup        AXOS_E72_PARENT-TC-2697 setup
Test Teardown     AXOS_E72_PARENT-TC-2697 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
EXA_device_MUST_support_storing_passwords_in_non_volatile_store
    [Documentation]    1 Verify that the passwords are stored in a nin-volatile store
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2697    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    cli    n1    cli
    ${output}    cli    n1    show running-config aaa user   prompt=${eutpmt}
    Result Should Contain    ${output}

*** Keywords ***
AXOS_E72_PARENT-TC-2697 setup
    log    Enter AXOS_E72_PARENT-TC-2697 setup

AXOS_E72_PARENT-TC-2697 teardown
    log    Enter AXOS_E72_PARENT-TC-2697 teardown
    Disconnect    n1
