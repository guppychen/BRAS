*** Settings ***
Documentation     The alarm definition must support the following attributes in order to define an alarm. This only relates to the alarm definition. There will be other instance related attributes that will derived at runtime. 
Resource          ./base.robot
Force Tags     @author=dzala    @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support


*** Variables ***
${dummy_ip}    2.2.2.2

*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_ntp_server_reachability
    [Documentation]    1 Verification of Alarm ntp-server-reachability (Alarm id 1918).
    ...    2 Check the Software version of the device.
    ...    3 Checking the existing alarms in the device before generating ntp-server-reachability.
    ...    4 Configure NTP Server with dummy IP which is not reachable.
    ...    5 Check Alarm after configuration
    ...    6 Validate "show alarm active" where generated alarm gets appear.
    ...    7 Validate ntp-server-reachability paramters using "show alarm definition subscope id <id>" command
    ...    8 Validate "show alarm active detail" and validate all the parameters for ntp server reachability.
    ...    9 Validate "show alarm active" & "show alarm history" after removing ntp configuration with dummy IP.
    [Tags]       @author=dzala     @TCID=AXOS_E72_PARENT-TC-2709
    [Setup]      RLT-TC-1095 setup
    [Teardown]   RLT-TC-1095 teardown
    log    STEP:1 Verification of Alarm ntp-server-reachability (Alarm id 1918).
    log    STEP:2 Check the Software version of the device.
    Cli    n1_session1    show version
    #Result Should Contain    description
    # AT-4711
    Result Should Contain    detail

    log    STEP:3 Checking the existing alarms in the device before generating ntp-server-reachability.
    Cli    n1_session1    show alarm active
    Result Should Contain    alarm active

    log    STEP:4 Configure NTP Server with dummy IP which is not reachable.
    Cli    n1_session1    configure
    Cli    n1_session1    ntp server 1 ${dummy_ip}
    Cli    n1_session1    end
    Cli    n1_session1    show running ntp|nomore    \\#    30
    Result Should Contain    ${dummy_ip}

    log    STEP:5 Check Alarm after configuration
    log    STEP:6 Validate "show alarm active" where generated alarm gets appear.

    wait until keyword succeeds  60  5   Send Command And Confirm Expect    n1_session1    show alarm active        id 1918 name ntp-server-reachability
    log    STEP:7 Validate ntp-server-reachability paramters using "show alarm definition subscope id <id>" command
    Cli    n1_session1    show alarm active subscope id 1918
    Result should contain    probable-cause All provisioned NTP servers are not reachable

    log    STEP:8 Validate "show alarm active detail" and validate all the parameters for ntp server reachability.
    Cli    n1_session1    show alarm active detail
    Result Match Regexp   id[\\s]+1918
    Result Match Regexp   name[\\s]+ntp-server-reachability
    Result Match Regexp   details[\\s]+"One or more ntp servers are not reachable"
    Result Match Regexp   probable-cause[\\s]+"All provisioned NTP servers are not reachable" 

    log    STEP:9 Validate "show alarm active" & "show alarm history" after removing ntp configuration with dummy IP.
    Cli    n1_session1    configure
    Cli    n1_session1    no ntp server 1
    Cli    n1_session1    end
    Cli    n1_session1    show running ntp|nomore    \\#    30
    Result Should Not Contain    ${dummy_ip}

    wait until keyword succeeds  60  5   Send Command And Confirm Expect    n1_session1   show alarm history   name ntp-prov perceived-severity CLEAR
    Cli    n1_session1    show alarm active
    Result should not contain    id 1918 name ntp-server-reachability

*** Keywords ***
RLT-TC-1095 setup
    [Documentation]    ROLT Setup
    [Arguments]
    log    Enter RLT-TC-1095 setup

    # Remove configured ntp server
    Cli    n1_session1    configure
    Cli    n1_session1    no ntp server 1
    Cli    n1_session1    end

    # Clear active event and alarm log
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30


RLT-TC-1095 teardown
    [Documentation]    ROLT Teardown
    [Arguments]
    log    Enter RLT-TC-1095 teardown

    # Clear active event and alarm log
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

    # Remove configured ntp server
    Cli    n1_session1    configure
    Cli    n1_session1    no ntp server 1
    Cli    n1_session1    end
    Cli    n1_session1    show running ntp|nomore    \\#    30
    Result Should Not Contain    ${dummy_ip}
