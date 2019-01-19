*** Settings ***
Documentation     A page means a fixed number of sorted alarm instances starting at some offset from the first alarm instance. The page includes a notion of how many alarm instances there are in total. This applies to filtered and non-filtered queries.
...
...
...               Purpose
...               =======
...
...               EXA device must support retrieving a page of alarm instances (Default is paginated for CLI). A page means a fixed number of sorted alarm instances starting at some offset from the first alarm instance. The page includes a notion of how many alarm instances there are in total. This applies to filtered and non-filtered queries.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Active_Pagination_Cli
    [Documentation]    Testcase to verify if pagination can be enabled/disabled. The alarm count must be same when pagination is enabbled/disabled. Generate around 20 alarms so that we can Verify when more than one page of alarms are active with pagination true amd false
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-259    @globalid=2226171    @priority=P1    @user_interface=cli
    Command    n1_session1    Show version
    ${alarm}=    cli    n1_session1    show alarm active
    ${Total_line}=    Get Line    ${alarm}    2
    ${Total_count}=    Remove String    ${Total_line}    total-count
    ${alarm_count}=    Get line    ${alarm}    -2
    ${alarm_num}=    Remove String    ${alarm_count}    alarm
    Run keyword if    ${alarm_num} == ${Total_count}    Log    Alarm counts are same
    command    n1_session1    paginate false
    ${palarm}=    cli    n1_session1    show alarm active
    ${pTotal_line}=    Get Line    ${palarm}    2
    ${pTotal_count}=    Remove String    ${pTotal_line}    total-count
    ${palarm_count}=    Get line    ${palarm}    -2
    ${palarm_num}=    Remove String    ${palarm_count}    alarm
    Run keyword if    ${pTotal_count}== ${palarm_num}    Log    Alarm counts are same after disabling the paginate
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Active_Pagination_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Active_Pagination_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Disconnect    ${DUT}
