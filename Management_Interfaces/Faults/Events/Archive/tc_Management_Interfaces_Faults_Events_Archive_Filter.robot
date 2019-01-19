*** Settings ***
Documentation     A page means a fixed number of sorted historical alarm instances starting at some offset from the first historical alarm instance. The page includes a notion of how many historical alarm instances there are in total. This applies to filtered and non-filtered queries.
...
...               This retrieval mechanism must support pagination of historical acknowledged/cleared alarm instances
...
...               Purpose
...               ========
...               EXA device must support retrieving a page of archive alarm instances.This retrieval mechanism must support pagination of historical acknowledged/cleared alarm instances
Force Tags     @author=gpalanis   @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Filter_archive
    [Documentation]    1 Configure Network as shown in diagram. Network is up and connected with no alarms.
    ...    2 Create a bunch of events on EUT#2 Do 'show event ' and make sure you see the events in event logs
    ...    3 Clear the events in step 2 Do 'show event' make sure all event in step 2 not there.
    ...    4 Check for archive events Do 'show events archive' and you should see all records of events from previous boots and from step 2 & step 3
    ...    5 Filter by range show event archive range start-range 1 end -range 10 ( try multiple values starting from 10 , giving end value very long values etc.) Test with different offset values for example if there are 100 records start from offset 55 to end offest of 59 etc.
    [Tags]    @author=gpalanis    @tcid=AXOS_E72_PARENT-TC-2876
    [Setup]      RLT-TC-13955 setup
    [Teardown]   RLT-TC-13955 teardown

    log    STEP:2 Create a bunch of events on EUT#2 Do 'show event ' and make sure you see the events in event logs

    # Trigger bunch of events
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}

    ${current_event}    cli    n1_session1    show event | nomore    \\#    30
    Should Not Be Empty    ${current_event}

    cli    n1_session1    show event | nomore | include DBCHANGE    \\#    30
    Result Should Contain    name db-change category DBCHANGE

    # Retrieve Instance-ID, time, ID for DB-events created
    ${res}    cli    n1_session1    show event filter name db-change | include instance-id    \\#    30
    @{instance_id}    should match regexp    ${res}    instance-id ([\\d.]+)[\\s\\S]+instance-id ([\\d.]+)

    ${res}    cli    n1_session1    show event filter name db-change | include ne-event-time    \\#    30
    @{time}    should match regexp    ${res}    ne-event-time (\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}[+|-]\\d{2}:\\d{2})

    ${res}    cli    n1_session1    show event filter name db-change | include " id \\d{3}"    \\#    30
    @{id}    should match regexp    ${res}    id (\\d{3})


    log    STEP:4 Check for archive events Do 'show events archive' and you should see all records of events from previous boots and from step 2 & step 3
    cli    n1_session1    show event archive | nomore | include DBCHANGE    \\#    300
    Result Should Contain    name db-change category DBCHANGE

    cli    n1_session1    show event archive filter name db-change | include instance-id     \\#    30
    Result Should Not Contain    instance-id @{instance_id}[1]
    Result Should Not Contain    instance-id @{instance_id}[2]

    # Reload and check if the events from step 2 and 3 are seen in archive
    reload    n1_session1

    cli    n1_session1    show event archive | include instance-id     \\#    300
    Result Should Contain    instance-id @{instance_id}[1]
    Result Should Contain    instance-id @{instance_id}[2]

    log    STEP:3 Clear the events in step 2 Do 'show event' make sure all event in step 2 not there.

    # Clear the events
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    show event | nomore | include DBCHANGE    \\#    300
    Result Should Not Contain    name db-change category DBCHANGE

    log    STEP:5 Filter by range show event archive range start-range 1 end -range 10 ( try multiple values starting from 10 , giving end value very long values etc.) Test with different offset values for example if there are 100 records start from offset 55 to end offest of 59 etc.

    cli    n1_session1    show event archive filter name db-change    \\#    300
    Result Should Contain    instance-id @{instance_id}[1]

    cli    n1_session1    show event archive filter time @{time}[1]    \\#    300
    Result Should Contain    instance-id @{instance_id}[1]

    cli    n1_session1    show event archive filter id @{id}[1]    \\#    300
    Result Should Contain    instance-id @{instance_id}[1]

    cli    n1_session1    show event archive filter instance-id @{instance_id}[1]    \\#    300
    Result Should Contain    instance-id @{instance_id}[1]

*** Keywords ***
RLT-TC-13955 setup
    [Documentation]    ROLT Test Setup
    [Arguments]
    log    Enter RLT-TC-13955 setup
    sleep   1s    wait for clear event log active.
    cli    n1_session1    show event | nomore | include DBCHANGE    \\#    300
    # Clear the events in both active and archive
    sleep   1s    wait for clear event log active.
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    cli    n1_session1    show event | nomore | include DBCHANGE    \\#    300
    Result Should Not Contain    name db-change category DBCHANGE
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}


RLT-TC-13955 teardown
    [Documentation]    ROLT Test teardown
    [Arguments]
    log    Enter RLT-TC-13955 teardown

    # Clear the events in both activie and archive
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    cli    n1_session1    show event | nomore | include DBCHANGE    \\#    30
    Result Should Not Contain    name db-change category DBCHANGE
