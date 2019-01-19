*** Settings ***
Documentation     The EXA system must be able to report through the mgmt plane the configuration of the alarm relay pins
...    The confguration must be reported in the management interfaces; EWI, CLI and Netconf
...     Note: This requirements applies in the case where the device has alarm relay contacts
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_system_must_be_able_to_report_through_the_mgmt_plane_the_configuration_of_the_alarm_relay_pins
    [Documentation]    1 Verify the UI reports all of the configured information regarding the environmental alarm pins.
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2314     @globalid=2351311    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Verify the UI reports all of the configured information regarding the environmental alarm pins.
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    label=fire
    ...    alarm-severity=MAJOR   contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    label=fire
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    label=fire
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al4    label=fire
    ...    alarm-severity=MAJOR   contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al5    label=fire
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al6    label=fire
    ...    alarm-severity=MAJOR   contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al7    label=fire
    ...    alarm-severity=MAJOR    contact-type=normally-closed    admin-state=enable
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL4    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL5    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL6    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL7    fire    enable
    ...    MAJOR    normally-closed    ${EMPTY}    open

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    prov_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al4    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al5    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al6    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire
    prov_environment_alarm    eutA    al7    admin-state=disable    contact-type=normally-closed    alarm-severity=MAJOR    label=fire

    prov_environment_alarm    eutA    al1    admin-state=enable
    prov_environment_alarm    eutA    al2    admin-state=enable
    prov_environment_alarm    eutA    al3    admin-state=enable
    prov_environment_alarm    eutA    al4    admin-state=enable
    prov_environment_alarm    eutA    al5    admin-state=enable
    prov_environment_alarm    eutA    al6    admin-state=enable
    prov_environment_alarm    eutA    al7    admin-state=enable


case teardown
    [Documentation]
    [Arguments]
    dprov_environment_alarm    eutA    al1
    dprov_environment_alarm    eutA    al2
    dprov_environment_alarm    eutA    al3
    dprov_environment_alarm    eutA    al4
    dprov_environment_alarm    eutA    al5
    dprov_environment_alarm    eutA    al6
    dprov_environment_alarm    eutA    al7