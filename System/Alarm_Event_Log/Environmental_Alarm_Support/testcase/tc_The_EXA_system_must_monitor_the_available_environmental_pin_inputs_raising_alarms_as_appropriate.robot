*** Settings ***
Documentation     The EXA system must monitor the available environmental pin inputs, raising alarms as appropriate
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_The_EXA_system_must_monitor_the_available_environmental_pin_inputs_raising_alarms_as_appropriate
    [Documentation]    The EXA system must monitor the available environmental pin inputs, raising alarms as appropriate
    [Tags]    @author=PEIJUN LIU    @tcid=AXOS_E72_PARENT-TC-2306    @globalid=2351303    @eut=NGPON2-4    @priority=P1
    [Setup]    setup
    [Teardown]    teardown
    log    show alarm active
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL1
    ${instance_id1}    check_environment_alarm_active    eutA    AL1
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id1}    perceived-severity=MAJOR
    ...    description=AL1 - fire alarm

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL2
    ${instance_id2}    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id2}    perceived-severity=MAJOR
    ...    description=AL2 - fire alarm

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL3
    ${instance_id3}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id3}    perceived-severity=MAJOR
    ...    description=AL3 - fire alarm



*** Keywords ***
setup
    [Documentation]    setup
    log    provision environment-alarm
    
    prov_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al1    admin-state=enable
    prov_environment_alarm    eutA    al2    admin-state=enable
    prov_environment_alarm    eutA    al3    admin-state=enable

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    label=fire
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    label=fire
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    label=fire
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable

teardown
    [Documentation]    teardown
    log    deprovision environment-alarm
    dprov_environment_alarm2    eutA    al1    admin-state    contact-type
    dprov_environment_alarm2    eutA    al2    admin-state    contact-type
    dprov_environment_alarm2    eutA    al3    admin-state    contact-type

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=disable
    ...    alarm-severity=MAJOR    contact-type=normally-open    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=disable
    ...    alarm-severity=MAJOR    contact-type=normally-open    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=disable
    ...    alarm-severity=MAJOR    contact-type=normally-open    label=fire

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    fire    disable
    ...    MAJOR    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    fire    disable
    ...    MAJOR    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    fire    disable
    ...    MAJOR    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL1
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL2
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL3
    Wait Until Keyword Succeeds     1 min     3 sec    check_alarm_history    eutA    AL1    AL2    AL3


