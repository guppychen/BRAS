*** Settings ***
Documentation     This test suite is going to verify whether the alarm category is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar

*** Test Cases ***

Alarm_Category
    [Documentation]    Test case verifies alarm category is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition subscope category X
    ...                2.Verify the field is correct in the active alarm. show alarm active subscope category X
    ...                3.Verify the field is correct in the alarm history. show alarm history subscope category X
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed subscope category X
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved subscope category X
    ...                6.Verify the field is correct in the archive alarm. show alarm archive subscope category X
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged subscope category X
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2830      @functional    @priority=P2      @user_interface=netconf       @runtime=long

    Log    ******* Verifying Alarm category is displayed correctly in Active alarms ********
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf        n1_netconf       CONFIGURATION      active_alarm
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf       n1_netconf       NTP         active_alarm
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf       n1_netconf       GENERAL     active_alarm

    Log    *** Verifying Alarm category is displayed correctly in Alarm definitions ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf       n1_netconf       NTP         definition_alarm
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf        n1_netconf       CONFIGURATION      definition_alarm
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf        n1_netconf       GENERAL      definition_alarm

    Log    *** Verifying Alarm category is displayed correctly in Alarm history ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf       n1_netconf       NTP         history_alarm
    Run Keyword And Continue On Failure          Alarm_Category_using_netconf        n1_netconf       CONFIGURATION      history_alarm
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf        n1_netconf      GENERAL       history_alarm

    Log    *** Verifying Alarm category is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure      Suppressing Active alarms using netconf      n1_netconf
    #Run Keyword And Continue On Failure       Alarm_Category_using_netconf        n1_netconf       CONFIGURATION       suppress_alarm
    #Run Keyword And Continue On Failure       Alarm_Category_using_netconf        n1_netconf       GENERAL      suppress_alarm
    #Run Keyword And Continue On Failure      Unsuppressing Active alarms using netconf    n1_netconf

    Log    *** Verifying Alarm category is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms using netconf     n1_netconf       category
  
    Log    *** Verifying Alarm category is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged using netconf     n1_netconf       category

    Log    *** Verifying Alarm category is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm using netconf      n1_netconf
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload The System using netconf     n1_netconf      n1_sh
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf        n1_netconf       CONFIGURATION      archive_alarm
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf       n1_netconf       NTP         archive_alarm
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Category_using_netconf        n1_netconf       GENERAL      archive_alarm



