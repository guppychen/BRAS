*** Settings ***
Documentation     This test suite is going to verify active and cleared alarms can be archived.
Suite Setup       alarm_setup     n1
Library           String
Library           Collections
Library           OperatingSystem
Resource          base.robot
Force Tags

*** Test Cases ***
Alarms_Archive_Filter
    [Documentation]    Test case verifies active and cleared alarms can be archived.
    ...                1.Create a bunch of alarms on EUT#2  Do 'show alarm active ' and make sure you see the alarms
    ...                2.Clear the alarms in step 2 Do 'show alarm active' make sure all alarms in step 1 is not there.   
    ...                3. Check for archive alarms  Do 'show alarm archive' and you should see all records of events from previous boots and from step 2 & step 3   
    ...                4. Filter by range show alarms archive range start-range 1 end -range 10 ( try multiple values starting from 10 , giving end value very long 
    ...                   values etc.) Test with different offset values for example if there are 100 records start from offset 55 to end offest of 59 etc. 
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2859   @user=root    @functional    @priority=P3    @user_interface=CLI

    Log    *** Trigerring Alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec     Trigerring NTP prov alarm      n1
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering CRITICAL alarm       linux=n1_sh     device=n1      user_interface=cli
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    device=n1     user_interface=cli

    Log    *** Getting instance-id for Triggered Alarms ***
    ${ntp_instance_id}       Getting instance-id from Triggered alarms       n1        ntp_prov
    ${app_instance_id}       Getting instance-id from Triggered alarms       n1        app_sus
    ${run_instance_id}       Getting instance-id from Triggered alarms       n1        running_config_unsaved

    Log    *** Clearing Alarms and verifying it is not displaying in active alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm     n1
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing CRITICAL alarm      n1_sh      n1     cli
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     device=n1      user_interface=cli

    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload System     n1

    Log    ******* Verifying active and cleared alarms are archived after DUT reboot ********
    @{instance_ids}    Create List     ${ntp_instance_id}      ${app_instance_id}      ${run_instance_id}
    : FOR    ${instance_id}     IN      @{instance_ids}
    \      Wait Until Keyword Succeeds    30 seconds    5 seconds    Archived_Alarms     n1      ${instance_id}

    Log    *** Alarm archive range ***
    ${total_count}     Wait Until Keyword Succeeds    30 seconds    5 seconds       Getting Archived Alarm total count     n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm_archive_log_range    n1       ${total_count}

*** Keyword ***
alarm_setup
    [Arguments]    ${device1}   
    [Documentation]    Clearing archived alarms 

    Log    *** Clearing archived alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing Archive alarm      ${device1}





