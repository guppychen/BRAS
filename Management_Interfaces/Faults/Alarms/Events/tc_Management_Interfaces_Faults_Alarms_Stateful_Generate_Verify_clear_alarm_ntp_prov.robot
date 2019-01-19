*** Settings ***
Documentation     Verification of Alarm ntp_prov (Alarm id 1919)
Force Tags     @author=bswamina    @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support
Resource          ./base.robot


*** Variables ***
${dummy_ip}    1.1.1.1

*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_ntp_prov
    [Documentation]    Verification of Alarm ntp_prov (Alarm id 1919)
    [Tags]       @author=bswamina     @TCID=AXOS_E72_PARENT-TC-2708
    [Setup]      RLT-TC-1094 setup
    [Teardown]   RLT-TC-1094 teardown

    # Check version
    Cli    n1_session1    show version
    #Result Should Contain    description
    Result Should Contain    detail       # AT-4711


    # Check the current alarm in alarm table in the device
    Cli    n1_session1    show alarm active
    Result Should Contain    alarm active

    #Configure NTP server with dummy IP
    Cli    n1_session1    configure
    Cli    n1_session1    ntp server 1 ${dummy_ip}
    Cli    n1_session1    end
    Cli    n1_session1    show running ntp|nomore    \\#    30
    Result Should Contain    ${dummy_ip}

    #unconfig to generate alarm
    Cli    n1_session1    configure
    Cli    n1_session1    no ntp server 1 ${dummy_ip}
    Cli    n1_session1    end
    Cli    n1_session1    show running ntp|nomore    \\#    30
    Result Should Not Contain    ${dummy_ip}

    #Check alarm configuration and validate "show alarm active"
    Cli     n1_session1    show alarm active | nomore
    Result should contain    id 1919 name ntp-prov

    #Checking the definition for ntp_prov Alarm
    Cli    n1_session1    show alarm active subscope id 1919
    Result should contain    id 1919
    Result Should Contain    name ntp-prov
    Result Should Contain    probable-cause NTP is not provisioned

    #Checking CLI "show alarm active detail" for all the parameters of "ntp_prov Alarm"
    Cli    n1_session1    show alarm active detail | nomore
    Result Match Regexp   id[\\s]+1919
    Result Match Regexp   name[\\s]+ntp-prov
    Result Match Regexp   details[\\s]+"At least one NTP server should be provisioned"
    Result Match Regexp   probable-cause[\\s]+"NTP is not provisioned"

    #Re-configure NTP server with dummy IP
    Cli    n1_session1    configure
    Cli    n1_session1    ntp server 1 ${dummy_ip}
    Cli    n1_session1    end
    Cli    n1_session1    show running-config ntp    timeout_exception=0
    Result should contain    ntp server 1 ${dummy_ip}
 
    #Check alarm configuration and validate "show alarm active"
    Cli     n1_session1    show alarm active | nomore
    Result should not contain    id 1919 name ntp-prov

    #Check alarm configuration and validate "show alarm active"
    Cli     n1_session1    show alarm history | nomore
    Result should contain    id 1919
    Result should contain    name ntp-prov


*** Keywords ***
RLT-TC-1094 setup
    [Documentation]    ROLT Setup
    [Arguments]
    log    Enter RLT-TC-1094 setup

    # Remove configured ntp server
    Cli    n1_session1    configure
    Cli    n1_session1    no ntp server 1
    Cli    n1_session1    end

    # Clear active event and alarm log
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30


RLT-TC-1094 teardown
    [Documentation]    Entering teardown
    [Arguments]

    # Clear active event and alarm log
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

    #unconfig ntp server
    Cli    n1_session1    configure
    Cli    n1_session1    no ntp server 1 ${dummy_ip}
    Cli    n1_session1    end
    Cli    n1_session1    show running ntp|nomore    \\#    30
    Result Should Not Contain    ${dummy_ip}
