*** Settings ***
Documentation     The EXA system must support configuring an administrative state for the alarm associated with an input pin
...    The intent is to enable and disable administratively the alarm generation associated with the input pin.
...    The changing of the admin state needs to be logged recording who, when, what was done.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_system_must_support_configuring_an_administrative_state_for_the_alarm_associated_with_an_input_pin
    [Documentation]    1 Configure each of the 3 input pins as administratively enabled and verify they report an alarm
    ...    2 Administratively disable each of the 3 inputs and verify closing the relay does not produce an alarm
    ...    3 Enable each of the inputs once again and verify they work
    ...    4 Reboot the system, verify the admin state is still enabled by closing the contacts and receiving an alarm
    ...    5 Disable each input, reboot the system while keeping the contacts closed and verify no alarms are received after the system finishes booting
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2310    @globalid=2351307    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown

    log    STEP:4 Reboot the system, verify the admin state is still enabled by closing the contacts and receiving an alarm
    Reload System    eutA

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=enable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=enable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=enable    contact-type=normally-closed

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open


    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL1
    check_environment_alarm_active    eutA    AL1
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL2
    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL3
    check_environment_alarm_active    eutA    AL3




*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    STEP:1 Configure each of the 3 input pins as administratively enabled and verify they report an alarm
    prov_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed
    prov_environment_alarm    eutA    al1    admin-state=enable
    prov_environment_alarm    eutA    al2    admin-state=enable
    prov_environment_alarm    eutA    al3    admin-state=enable

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=enable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=enable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=enable    contact-type=normally-closed

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open

    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL1
    check_environment_alarm_active    eutA    AL1
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL2
    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL3
    check_environment_alarm_active    eutA    AL3


    log    STEP:2 Administratively disable each of the 3 inputs and verify closing the relay does not produce an alarm
    prov_environment_alarm    eutA    al1    admin-state=disable
    prov_environment_alarm    eutA    al2    admin-state=disable
    prov_environment_alarm    eutA    al3    admin-state=disable

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed     ${EMPTY}   open

    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL1
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL2
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL3

    log    STEP:3 Enable each of the inputs once again and verify they work
    prov_environment_alarm    eutA    al1    admin-state=enable
    prov_environment_alarm    eutA    al2    admin-state=enable
    prov_environment_alarm    eutA    al3    admin-state=enable

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    enable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=enable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=enable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=enable    contact-type=normally-closed


    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL1
    check_environment_alarm_active    eutA    AL1
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL2
    check_environment_alarm_active    eutA    AL2
    Wait Until Keyword Succeeds    1 min     3 sec    check_environment_alarm_active    eutA    AL3
    check_environment_alarm_active    eutA    AL3


case teardown
    [Documentation]
    [Arguments]
    log    STEP:5 Disable each input, reboot the system while keeping the contacts closed and verify no alarms are received after the system finishes booting
    prov_environment_alarm    eutA    al1    admin-state=disable
    prov_environment_alarm    eutA    al2    admin-state=disable
    prov_environment_alarm    eutA    al3    admin-state=disable

    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al1    admin-state=disable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al2    admin-state=disable    contact-type=normally-closed
    Wait Until Keyword Succeeds    1 min    3 sec    check_running_config_environment_alarm    eutA    al3    admin-state=disable    contact-type=normally-closed

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open

    log   sleep 4 minutes as AT-5143
    sleep  4min
    Reload System    eutA

    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL1    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL2    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open
    Wait Until Keyword Succeeds    1 min    3 sec    check_environment_alarm    eutA    AL3    ${EMPTY}    disable
    ...    ${EMPTY}    normally-closed    ${EMPTY}    open

    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL1
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL2
    Wait Until Keyword Succeeds     1 min     3 sec    check_environment_alarm_active_iscleared    eutA    AL3
