
*** Settings ***
Documentation     The label is descriptive data intended to reflect the semantics associated with the alarm input pin.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_system_must_support_provisioning_of_a_label_describing_the_alarm_mapped_to_an_input_pin
    [Documentation]     The label is descriptive data intended to reflect the semantics associated with the alarm input pin.
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2308    @globalid=2351305    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    prov_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed    label=batt-fail
    ...    alarm-severity=MAJOR
    prov_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed    label=batt-fail
    ...    alarm-severity=MAJOR
    prov_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed    label=batt-fail
    ...    alarm-severity=MAJOR
    prov_environment_alarm    eutA    al4    admin-state=disable    contact-type=normally-closed    label=batt-fail
    ...    alarm-severity=MAJOR
    prov_environment_alarm    eutA    al5    admin-state=disable    contact-type=normally-closed    label=batt-fail
    ...    alarm-severity=MAJOR
    prov_environment_alarm    eutA    al6    admin-state=disable    contact-type=normally-closed    label=batt-fail
    ...    alarm-severity=MAJOR
    prov_environment_alarm    eutA    al7    admin-state=disable    contact-type=normally-closed    label=batt-fail
    ...    alarm-severity=MAJOR

    prov_environment_alarm    eutA    al1    admin-state=enable
    prov_environment_alarm    eutA    al2    admin-state=enable
    prov_environment_alarm    eutA    al3    admin-state=enable
    prov_environment_alarm    eutA    al4    admin-state=enable
    prov_environment_alarm    eutA    al5    admin-state=enable
    prov_environment_alarm    eutA    al6    admin-state=enable
    prov_environment_alarm    eutA    al7    admin-state=enable

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    batt-fail    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    batt-fail    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    batt-fail    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL4    batt-fail    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL5    batt-fail    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL6    batt-fail    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL7    batt-fail    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    label=batt-fail
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    label=batt-fail
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    label=batt-fail
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al4    label=batt-fail
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al5    label=batt-fail
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al6    label=batt-fail
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al7    label=batt-fail
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable


    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL1
    ${instance_id1}    check_environment_alarm_active    eutA    AL1
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id1}
    ...    perceived-severity=MAJOR    description=AL1 - batt-fail alarm
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL2
    ${instance_id2}    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id2}
    ...    perceived-severity=MAJOR    description=AL2 - batt-fail alarm
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL3
    ${instance_id3}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id3}
    ...    perceived-severity=MAJOR    description=AL3 - batt-fail alarm
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL4
    ${instance_id4}    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id4}
    ...    perceived-severity=MAJOR    description=AL2 - batt-fail alarm
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL5
    ${instance_id5}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id5}
    ...    perceived-severity=MAJOR    description=AL3 - batt-fail alarm
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL6
    ${instance_id6}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id6}
    ...    perceived-severity=MAJOR    description=AL3 - batt-fail alarm
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL7
    ${instance_id7}    check_environment_alarm_active    eutA    AL3
    Wait Until Keyword Succeeds    1 min     3 sec    check_alarm_active_by_subscpoe_insance_id    eutA    ${instance_id7}
    ...    perceived-severity=MAJOR    description=AL3 - batt-fail alarm


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log  no case setup

case teardown
    [Documentation]
    [Arguments]
    dprov_environment_alarm2    eutA    al1    admin-state    contact-type
    dprov_environment_alarm2    eutA    al2    admin-state    contact-type
    dprov_environment_alarm2    eutA    al3    admin-state    contact-type
    dprov_environment_alarm2    eutA    al4    admin-state    contact-type
    dprov_environment_alarm2    eutA    al5    admin-state    contact-type
    dprov_environment_alarm2    eutA    al6    admin-state    contact-type
    dprov_environment_alarm2    eutA    al7    admin-state    contact-type
