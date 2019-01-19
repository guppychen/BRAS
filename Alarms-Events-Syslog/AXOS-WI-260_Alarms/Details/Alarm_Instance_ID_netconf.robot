*** Settings ***
Documentation     This test suite is going to verify whether the alarm instance-id is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar

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
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2827    @functional    @priority=P2      @user_interface=netconf      @runtime=long


    Log    *** Getting instance-id for Triggered Alarms ***
    ${running_config_instance-id}       Getting instance-id from Triggered alarms using netconf      n1_netconf       running_config_unsaved
    ${ntp_prov_instance-id}       Getting instance-id from Triggered alarms using netconf      n1_netconf       ntp_prov
    #${ethernet_rmon_instance-id}       Getting instance-id from Triggered alarms using netconf      n1_netconf        ethernet_rmon

    Log    *** Verifying Alarm instance-id is displayed correctly in Active alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf       ${running_config_instance-id}      active     running_config
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf       ${ntp_prov_instance-id}     active    ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf       ${ethernet_rmon_instance-id}    active     ethernet_rmon

    Log    *** Verifying Alarm instance-id is displayed correctly in Alarm definitions(Not Applicable, So SKIPPING IT) ***

    Log    *** Verifying Alarm instance-id is displayed correctly in Alarm history ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf     ${running_config_instance-id}    history     running_config
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf     ${ntp_prov_instance-id}    history     ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf     ${ethernet_rmon_instance-id}    history     ethernet_rmon

    Log    *** Verifying Alarm instance-id is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure        Suppressing Active alarms using netconf    n1_netconf
    #Run Keyword And Continue On Failure        Alarm_Instance-id_netconf        n1_netconf     ${running_config_instance-id}    suppressed      running_config
    #Run Keyword And Continue On Failure       Alarm_Instance-id_netconf        n1_netconf     ${ethernet_rmon_instance-id}     suppressed      ethernet_rmon
    #Run Keyword And Continue On Failure       Unsuppressing Active alarms using netconf   n1_netconf

    Log    *** Verifying Alarm instance-id is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms using netconf    n1_netconf       instance-id      shelved_runningconfig_unsaved

    Log    *** Verifying Alarm instance-id is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged using netconf     n1_netconf       instance-id

    Log    *** Verifying Alarm instance-id is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm using netconf      n1_netconf
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload The System using netconf     n1_netconf      n1_sh
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf     ${running_config_instance-id}    archive      running_config
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf     ${ntp_prov_instance-id}    archive      ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_Instance-id_netconf        n1_netconf     ${ethernet_rmon_instance-id}   archive      ethernet_rmon

