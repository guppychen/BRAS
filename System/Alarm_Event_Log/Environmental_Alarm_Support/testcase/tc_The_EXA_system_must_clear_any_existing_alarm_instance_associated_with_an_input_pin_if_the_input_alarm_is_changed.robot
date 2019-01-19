*** Settings ***
Documentation     The EXA system must clear any existing alarm instance associated with an input pin if the input alarm is changed
...    If an input pin alarm is changed, meaning its a different alarm, and there is a standing alarm related to that pin, the existing instance must be cleared, and an new alarm instance raised for the new condition.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_system_must_clear_any_existing_alarm_instance_associated_with_an_input_pin_if_the_input_alarm_is_changed
    [Documentation]    1 Verify that if an input alarm is triggered and the condition is then removed, the alarm that was generated by the input alarm is subsequently removed
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2313    @globalid=2351310    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Verify that if an input alarm is triggered and the condition is then removed, the alarm that was generated by the input alarm is subsequently removed

    prov_environment_alarm    eutA    al4    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al4    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL4    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al4
    ...    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active    eutA    AL4
    dprov_environment_alarm2    eutA    al4    admin-state    contact-type
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL4    ${EMPTY}    disable
    ...    ${EMPTY}    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al4
    ...    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL4


    prov_environment_alarm    eutA    al5    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al5    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL5    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al5
    ...    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active    eutA    AL5
    dprov_environment_alarm2    eutA    al5    admin-state    contact-type
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL5    ${EMPTY}    disable
    ...    ${EMPTY}    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al5
    ...    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL5




*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    prov_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al1    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1
    ...    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active    eutA    AL1
    dprov_environment_alarm2    eutA    al1    admin-state    contact-type
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    disable
    ...    ${EMPTY}    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1
    ...    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL1

    prov_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al2    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2
    ...    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active    eutA    AL2
    dprov_environment_alarm2    eutA    al2    admin-state    contact-type
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    disable
    ...    ${EMPTY}    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2
    ...    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL2

    prov_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al3    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3
    ...    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active    eutA    AL3
    dprov_environment_alarm2    eutA    al3    admin-state    contact-type
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    disable
    ...    ${EMPTY}    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3
    ...    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL3

case teardown
    [Documentation]
    [Arguments]
    prov_environment_alarm    eutA    al6    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al6    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL6    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al6
    ...    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active    eutA    AL6
    dprov_environment_alarm2    eutA    al6    admin-state    contact-type
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL6    ${EMPTY}    disable
    ...    ${EMPTY}    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al6
    ...    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL6

    prov_environment_alarm    eutA    al7    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al7    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL7    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al7
    ...    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active    eutA    AL7
    dprov_environment_alarm2    eutA    al7    admin-state    contact-type
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL7    ${EMPTY}    disable
    ...    ${EMPTY}    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al7
    ...    contact-type=normally-open    admin-state=disable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm_active_iscleared    eutA    AL7
