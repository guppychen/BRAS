*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_config-file-deleted_Snmp
    [Documentation]    Testcase to verify the if the events are generated when config file is deleted.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-293   @user=root   @user=root    @globalid=2226214    @priority=P1    @user_interface=Snmp
    Command    n1_session1    clear active event
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    #create a new config file by copying the running-config to a new file.
    Command    n1_session1    accept running-config
    ${copy-status}=    Command    n1_session1    copy config from running-config to config.txt
    Should contain    ${copy-status}    Copy completed.
    #Delete the config file created by the user
    ${copy-status}=    Command    n1_session1    delete file config filename config.txt
    Should contain    ${copy-status}    OK
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    Configuration file was deleted
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_config-file-deleted_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_config-file-deleted_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
