*** Settings ***
Documentation     The EXA system must support configuring a user supplied label and alarm severity for each alarm input pin
...    The EXA system must support a user configuring the alarm detail associated with each alarm input pin
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_system_must_support_configuring_a_user_supplied_label_and_alarm_severity_for_each_alarm_input_pin
    [Documentation]    1 Verify the each of the 3 input alarms can be labeled
    ...    2 Save, reboot and verify the configuration remains
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2311    @globalid=2351308    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Verify the each of the 3 input alarms can be labeled
    prov_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed
    ...    label=central-pwr-fail    alarm-severity=INFO
    prov_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed
    ...    label=central-pwr-fail    alarm-severity=INFO
    prov_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed
    ...    label=central-pwr-fail    alarm-severity=INFO

    log    STEP:2 Save, reboot and verify the configuration remains
    Reload System    eutA

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    central-pwr-fail    disable
    ...    INFO    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    central-pwr-fail    disable
    ...    INFO    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    central-pwr-fail    disable
    ...    INFO    normally-closed    ${EMPTY}    open

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    label=central-pwr-fail
    ...    alarm-severity=INFO    admin-state=disable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    label=central-pwr-fail
    ...    alarm-severity=INFO    admin-state=disable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    label=central-pwr-fail
    ...    alarm-severity=INFO    admin-state=disable    contact-type=normally-closed

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    STEP:1 Verify the each of the 3 input alarms can be labeled

case teardown
    [Documentation]
    [Arguments]
    log    STEP:2 Save, reboot and verify the configuration remains