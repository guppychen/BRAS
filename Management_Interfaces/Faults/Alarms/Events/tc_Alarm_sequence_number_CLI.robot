    
*** Settings ***
Documentation     The sequence number is the temporal position of this alarm relative to all alarm notifications originated from the EXA device. Each alarm instance gets a unique sequence number  associated with its position in the chronological order of events as they occur starting from device boot. The sequence number starts at 0 at boot time and increases from there. The sequence number is not unique across reboots.
...    
...    The primary purpose of the sequence number is to enable consumers of alarms to know if they missed any alarm notifications and take action to retrieve missed alarms.
...    Purpose
...    =======
...    EXA device MUST support at the alarm instance the sequence number of the alarm wrt to the EXA device
Force Tags     @author=gpalanis    @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Alarm_sequence_number
    [Documentation]    1 	Trigger alarm by pulling cable and causing a LOS alarm. 	Active alarm is generated. 	Show alarms active detail
    [Tags]       @author=gpalanis     @tcid=AXOS_E72_PARENT-TC-2889
    [Setup]      RLT-TC-1029 setup
    [Teardown]   RLT-TC-1029 teardown
    log    STEP:1 Trigger alarm by pulling cable and causing a LOS alarm. Active alarm is generated. Show alarms active detail

    # Check version 
    ${version}    cli    n1_session1    show version
    Wait Until Keyword Succeeds  30s   3s   check_Active_Alarm  n1_session1   1201
    # Check if the interface has oper status down
    cli    n1_session1    show interface ${DEVICES.n1_session1.ports.service_p1.type} ${DEVICES.n1_session1.ports.service_p1.port}| include "oper-state "
    Result Should Contain    down

    # Trigger shutdown command to generate alarm
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}
    # Sleep provided so that alarm is seen
    sleep    30

    @{port}    Evaluate    "${DEVICES.n1_session1.ports.service_p1.port}".split("/")
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    # Check the updated alarm table in the device
    cli    n1_session1    show alarm history | nomore    \\#    30
    Result Match Regexp    1201.*loss-of-signal.*@{port}[2]
#    Result Match Regexp    1203.*improper-removal.*@{port}[2]


*** Keywords ***
RLT-TC-1029 setup
    [Documentation]    Entering setup
    [Arguments]
    log    Enter RLT-TC-1029 setup

    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

check_Active_Alarm
    [Arguments]  ${device}   ${info}
    [Documentation]  use for check the 1201 alarm
    @{port}    Evaluate    "${DEVICES.n1_session1.ports.service_p1.port}".split("/")
    ${alarm}  cli  ${device}  show alarm active
    Should contain  ${alarm}  ${info}
    Result Match Regexp    1201.*loss-of-signal.*@{port}[2]


RLT-TC-1029 teardown
    [Documentation]    Entering teardown
    [Arguments]
    log    Enter RLT-TC-1029 teardown


    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
