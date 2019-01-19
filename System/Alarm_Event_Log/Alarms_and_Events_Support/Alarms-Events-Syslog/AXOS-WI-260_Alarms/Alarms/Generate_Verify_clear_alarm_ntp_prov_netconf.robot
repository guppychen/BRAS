*** Settings ***
Documentation     This test suite is going to verify whether ntp prov alarm can be triggered and cleared 
Suite Setup       Clearing alarm history logs using netconf      n1_netconf
Library           String
Library           Collections
Library           XML    use_lxml=True
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Generate_Verify_clear_alarm_ntp_prov
    [Documentation]    Test case verifies ntp prov alarm is triggered and cleared, maintained in historical alarms
    ...    1. Generate ntp prov alarm
    ...    2. Verify alarm is stored in active and history table
    ...    3. Clear the alarm
    ...    4. Verify the ntp prov alarm is cleared 
    ...    5. Retrieve historial alarms by show alarm history and make sure you see both above events logged
    ...    6. Make sure these alarms are not there in standing alarms table
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2822    @functional    @priority=P3        @user_interface=NETCONF

    Log    *** Verifying ntp prov alarm can be triggered and cleared, maintained in historical alarms ***
    ${instance_id}     Wait Until Keyword Succeeds    30 seconds    5 seconds    Trigerring NTP prov alarm netconf    n1_netconf      
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Clearing NTP prov alarm netconf      n1_netconf       ${instance_id} 

