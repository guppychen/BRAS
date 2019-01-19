*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
Alarms_Active_Category_GENERAL_snmp
    [Documentation]    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, the alarm is sent to the syslog server, and an SNMP trap/inform is sent. Reset the device to clear all the alarm.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-204   @user=root    @globalid=2226113    @priority=P1    @user_interface=snmp
    command    n1_session2    cli
    #configure the SNMP v2
    SNMP_v2_setup    n1_session2
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    command    n1_session2    show alarm active
    command    n1_session2    exit
    #generate the alarms on the device
    Generate_Alarm_General    n1_session2
    command    n1_session2    cli
    #Stop the SNMP trap host. Sleep for 30s as the snmp packets must be received.
    Sleep    60s
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    #Verify if the alarms are generated from the CLI session.
    Verify_Alarm_General    ${snmp_trap}
    [Teardown]    Teardown Alarms_Active_Category_GENERAL_snmp    n1_session2

*** Keywords ***
Teardown Alarms_Active_Category_GENERAL_snmp
    [Arguments]    ${DUT}
    [Documentation]    Disconnect from the device.
    [Tags]    @author=Shesha Chandra
    Clear_Alarm_General    ${DUT}
    #Remove the SNMP v2
    SNMP_v2_teardown    n1_session1
    Disconnect    ${DUT}
