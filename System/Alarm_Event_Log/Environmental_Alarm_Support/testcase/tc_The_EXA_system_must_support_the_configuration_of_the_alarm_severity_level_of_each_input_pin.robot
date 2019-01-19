*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_system_must_support_the_configuration_of_the_alarm_severity_level_of_each_input_pin
    [Documentation]    The EXA system must support the configuration of the alarm severity level of each input pin
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2307    @globalid=2351304    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:The EXA system must support the configuration of the alarm severity level of each input pin



*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    provision environment alarm
    prov_environment_alarm    eutA    al1    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al2    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al3    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire



    prov_environment_alarm    eutA    al1    admin-state=enable
    prov_environment_alarm    eutA    al2    admin-state=enable
    prov_environment_alarm    eutA    al3    admin-state=enable

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open



    log    show alarm active
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL1
    ${instance_id1}    check_environment_alarm_active    eutA    AL1
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id1}    perceived-severity=MINOR
    ...    description=AL1 - fire alarm

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL2
    ${instance_id2}    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id2}    perceived-severity=MINOR
    ...    description=AL2 - fire alarm

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL3
    ${instance_id3}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id3}    perceived-severity=MINOR
    ...    description=AL3 - fire alarm

case teardown
    [Documentation]
    [Arguments]
    dprov_environment_alarm2    eutA    al1    admin-state    contact-type
    dprov_environment_alarm2    eutA    al2    admin-state    contact-type
    dprov_environment_alarm2    eutA    al3    admin-state    contact-type

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=disable
    ...    alarm-severity=MINOR    contact-type=normally-open    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=disable
    ...    alarm-severity=MINOR    contact-type=normally-open    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=disable
    ...    alarm-severity=MINOR    contact-type=normally-open    label=fire

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    fire    disable
    ...    MINOR    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    fire    disable
    ...    MINOR    normally-open    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    fire    disable
    ...    MINOR    normally-open    ${EMPTY}    open

    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL1
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL2
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL3
    Wait Until Keyword Succeeds     1 min     3 sec    check_alarm_history    eutA    AL1    AL2    AL3