*** Settings ***
Documentation     The EXA system must support reflecting the alarm details configured for an alarm input pin on all alarm instances associated with that input pin
...    When an alarm is signaled on the input pin, the alarm instance raised in the EXA system must reflect the alarm details (label, perceived severity etc...) which represents the alarm condition on the pin in order to facilitate the user's ability to interpret the alarm.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_system_must_support_reflecting_the_alarm_details_configured_for_an_alarm_input_pin_on_all_alarm_instances_associated_with_that_input_pin
    [Documentation]    1 Verify that the logged info for an input alarm includes label and perceived severity information are captured
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2312    @globalid=2351309    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Verify that the logged info for an input alarm includes label and perceived severity information are captured
    prov_environment_alarm    eutA    al1    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al2    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al3    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al4    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al5    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al6    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    prov_environment_alarm    eutA    al7    admin-state=disable    alarm-severity=MINOR    contact-type=normally-closed    label=fire

    prov_environment_alarm    eutA    al1    admin-state=enable
    prov_environment_alarm    eutA    al2    admin-state=enable
    prov_environment_alarm    eutA    al3    admin-state=enable
    prov_environment_alarm    eutA    al4    admin-state=enable
    prov_environment_alarm    eutA    al5    admin-state=enable
    prov_environment_alarm    eutA    al6    admin-state=enable
    prov_environment_alarm    eutA    al7    admin-state=enable

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL4    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL5    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL6    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL7    fire    enable
    ...    MINOR    normally-closed    ${EMPTY}    open

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al4    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al5    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al6    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al7    admin-state=enable
    ...    alarm-severity=MINOR    contact-type=normally-closed    label=fire

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

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL4
    ${instance_id4}    check_environment_alarm_active    eutA    AL1
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id4}    perceived-severity=MINOR
    ...    description=AL1 - fire alarm

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL5
    ${instance_id5}    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id5}    perceived-severity=MINOR
    ...    description=AL2 - fire alarm

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL6
    ${instance_id6}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id6}    perceived-severity=MINOR
    ...    description=AL3 - fire alarm

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL7
    ${instance_id7}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id7}    perceived-severity=MINOR
    ...    description=AL3 - fire alarm

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    STEP:1 Verify that the logged info for an input alarm includes label and perceived severity information are captured


case teardown
    [Documentation]
    [Arguments]
    log    STEP:1 Verify that the logged info for an input alarm includes label and perceived severity information are captured
