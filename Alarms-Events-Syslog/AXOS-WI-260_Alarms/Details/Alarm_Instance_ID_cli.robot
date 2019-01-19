*** Settings ***
Documentation     This test suite is going to verify whether the alarm instance-id is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms     n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Suite Teardown     Clearing_Alarms       n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar    @reload

*** Test Cases ***

Alarm_Instance_ID
    [Documentation]    Test case verifies alarm instance-id is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition subscope instance-id X
    ...                2.Verify the field is correct in the active alarm. show alarm active subscope instance-id X
    ...                3.Verify the field is correct in the alarm history. show alarm history subscope instance-id X
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed subscope instance-id X
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved subscope instance-id X
    ...                6.Verify the field is correct in the archive alarm. show alarm archive subscope instance-id X
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged subscope instance-id X
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2827    @functional    @priority=P2      @user_interface=CLI      @runtime=long


    Log    *** Getting instance-id for Triggered Alarms ***
    ${signal_loss_instance-id}       Getting instance-id from Triggered alarms       n1        loss_of_signal
    ${ntp_prov_instance-id}       Getting instance-id from Triggered alarms       n1        ntp_prov
    #${ethernet_rmon_instance-id}       Getting instance-id from Triggered alarms       n1        ethernet_rmon

    Log    *** Verifying Alarm instance-id is displayed correctly in Active alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1       ${signal_loss_instance-id}      active     signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1       ${ntp_prov_instance-id}      active     ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1       ${ethernet_rmon_instance-id}    active     ethernet_rmon

    Log    *** Verifying Alarm instance-id is displayed correctly in Alarm definitions(Not Applicable, So SKIPPING IT) ***

    Log    *** Verifying Alarm instance-id is displayed correctly in Alarm history ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1     ${signal_loss_instance-id}    history     signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1     ${ntp_prov_instance-id}      history     ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1     ${ethernet_rmon_instance-id}    history     ethernet_rmon

    Log    *** Verifying Alarm instance-id is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure      Suppressing Active alarms    n1
    #Run Keyword And Continue On Failure      Alarm_Instance-id        n1     ${signal_loss_instance-id}    suppressed      signal_loss
    #Run Keyword And Continue On Failure     Alarm_Instance-id        n1     ${ethernet_rmon_instance-id}     suppressed      ethernet_rmon
    #Run Keyword And Continue On Failure     Unsuppressing Active alarms    n1
   
    Log    *** Verifying Alarm instance-id is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms    n1       instance-id      shelved_runningconfig_unsaved

    Log    *** Verifying Alarm instance-id is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged     n1       instance-id

    Log    *** Verifying Alarm instance-id is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm      n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload System     n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1     ${signal_loss_instance-id}    archive      signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1     ${ntp_prov_instance-id}    archive      ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id        n1     ${ethernet_rmon_instance-id}   archive      ethernet_rmon


