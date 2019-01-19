*** Settings ***
Documentation     Define the default state of the input pin for environmental alarm
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_The_EXA_system_must_default_each_input_only_pin_to_disabled_and_alarm_type_normally_open
    [Documentation]    1 Execute a "show running environmental alarm" on a DUT that has a default startup configuration .
    ...    The three input alarms should all be set to disabled and the contact type should be "normally open"
    ...    2 To validate the state is disabled close the external contacts (requires a harness that can break out the pins) and verify the input alarm doesn't generate an active alarm
    [Tags]    @author=PEIJUN LIU    @TCID=AXOS_E72_PARENT-TC-2315    @globalid=2351312    @eut=NGPON2-4    @priority=P1     @reboot_default
    [Setup]    case setup
    log    STEP:1 Execute a "show running environmental alarm" on a DUT that has a default startup configuration .
    Reload System    eutA
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    label=not-assigned
    ...    alarm-severity=INFO    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    label=not-assigned
    ...    alarm-severity=INFO    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    label=not-assigned
    ...    alarm-severity=INFO    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    not-assigned
    ...    disable    INFO    normally-open    disabled    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    not-assigned
    ...    disable    INFO    normally-open    disabled    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    not-assigned
    ...    disable    INFO    normally-open    disabled    open
    log    STEP:2 To validate the state is disabled close the external contacts (requires a harness that can break out the pins) and verify the input alarm doesn't generate an active alarm
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL1
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL2
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL3
    [Teardown]    case teardown


*** Keywords ***
case setup
    dprov_environment_alarm    eutA    al1
    dprov_environment_alarm    eutA    al2
    dprov_environment_alarm    eutA    al3
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    label=not-assigned
    Wait Until Keyword Succeeds    1 min    3 sec     check_running_config_environment_alarm    eutA    al2    label=not-assigned
    Wait Until Keyword Succeeds    1 min    3 sec     check_running_config_environment_alarm    eutA    al3    label=not-assigned

case teardown
    log    case teardown
#    ${res}    cli    eutA    copy config from running-config-safe to startup-config
#    should contain    ${res}    Copy completed
#    Reload System    eutA
