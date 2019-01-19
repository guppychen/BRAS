*** Settings ***
Documentation     This test suite is going to verify whether ntpd down alarm can be triggered and cleared 
Suite Setup       Clearing alarm history logs using netconf      n1_netconf
Library           String
Library           Collections
Library           XML    use_lxml=True
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Generate_Verify_clear_alarm_ntpd_down
    [Documentation]    Test case verifies ntpd down alarm is triggered and cleared, maintained in historical alarms
    ...    1. Generate ntpd down alarm
    ...    2. Verify alarm is stored in active and history table
    ...    3. Clear the alarm
    ...    4. Verify the ntpd down alarm is cleared 
    ...    5. Retrieve historial alarms by show alarm history and make sure you see both above events logged
    ...    6. Make sure these alarms are not there in standing alarms table
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2820     @functional    @priority=P3        @user_interface=NETCONF

    Log    *** Verifying ntpd down alarm can be triggered and cleared, maintained in historical alarms ***
    ${instance_id}     Wait Until Keyword Succeeds    30 seconds    5 seconds    Trigerring NTPD down alarm netconf    n1_netconf       ${DEVICES.n1_local_pc.ip}
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Clearing NTPD down alarm netconf      n1_netconf       ${instance_id} 

