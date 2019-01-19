*** Settings ***
Documentation     Verify LAG Static  mode configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=smuruges

Suite Setup       Basic_Test_Setup        

Suite Teardown    Basic_Test_Teardown     

*** Variables ***

${max_port_id}     1
${lacp_stat1}      active
${lacp_stat2}      standby
${Alarm1}          lag-group-down-alarm
${Alarm2}          loss-of-signal-alarm
${Alarm_stat1}     set
${Alarm_stat2}     clear

*** Test Cases ***

Verify Link Protection/LAG/Alarms/Link up-down

    [Documentation]    Action Expected Result Notes
    ...      1. Add ethernet interface of E3 device to the LAG group
    ...      2. Verify ethernet interface of E3 device added to the LAG group
    ...      3. Verify the LAG member status static on E3 and E5 devices
    ...      4. Shutdown the neighbour connected interface and verify alarm is generated on connected devices 
    ...      5. Unshut the neighbour connected interface and verify alarm is generated on connected devices
    ...      6. Shutdown the neighbour lag interface and verify alarm is generated on connected devices
    ...      7. Unshut the neighbour connected interface and verify alarm is generated on connected devices.

    [Tags]         @tcid=AXOS_E72_PARENT-TC-1077    @globalid=2316570    @functional    @priority=P1

#    Log   *** Add ethernet interface of device to the LAG group ***
    
    :For     ${num}     IN RANGE       1       3
         \    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p${num}.port}      ${lag_group}    ${slot}

    :For     ${num}     IN RANGE       1       3
         \    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p${num}.port}      ${lag_group}    ${slot}


#    Log   *** Verify ethernet interface of device added to the LAG group ***

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p${num}.port}      ${lag_group}

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p${num}.port}      ${lag_group}

  
#    Log   *** Verify the LAG member status static on E3 and E5 devices ***

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}      ${oper_state1}    ${lacp_stat${num}}

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p${num}.port}      ${oper_state1}    ${lacp_stat${num}}

#    Log   *** Shutdown the neighbour connected interface and verify alarm is generated on connected devices ***
 
    Interface_shut_calix            n2      ${DEVICES.n2.ports.p1.port}     ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Ethernet Status     n1    ${DEVICES.n1.ports.p1.port}       ${Alarm2}      ${Alarm_stat1}

#    Log   *** Unshut the neighbour connected interface and verify alarm is generated on connected devices ***

    Interface_noshut_calix          n2      ${DEVICES.n2.ports.p1.port}     ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Ethernet Status    n1     ${DEVICES.n1.ports.p1.port}     ${Alarm2}      ${Alarm_stat2}

#    Log   *** Shutdown the neighbour lag interface and appropriate alarm is generated on connected devices ***

    Shutdown Lag Interface          n2     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Status    n1     ${lag_group}      ${Alarm1}      ${Alarm_stat1}

#    Log   *** Unshut the neighbour lag interface and appropriate alarm is generated on connected devices ***

    Unshutdown Lag Interface        n2     ${lag_group} 
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Status    n1     ${lag_group}      ${Alarm1}      ${Alarm_stat2}

*** Keywords ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
    ...              1. To Configure LAG Group on both the devices E3 and E5
    ...              2. Verify the LAG Group Status

    [Arguments]     
    
    :For     ${num}     IN RANGE       1       3
         \    Show Image Version   n${num}
     
    :For     ${num}     IN RANGE       1       3
         \    Create LAG Group      n${num}     ${lag_group}     ${lacp_mode1}

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n${num}     ${lag_group}
    
    :For     ${num}     IN RANGE       1       3
         \    Configure LAG Group Max Port     n${num}     ${lag_group}      ${max_port_id}

     :For     ${num}     IN RANGE       1       3
         \    Check LAG Group Max Port      n${num}     ${lag_group}      ${max_port_id}

Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]      
   
#    Log   *** Remove the LAG information from E3 and E5 devices ***

    :For     ${num}     IN RANGE       1       3
         \    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p${num}.port}      ${lag_group}    ${slot}

    :For     ${num}     IN RANGE       1       3
         \    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p${num}.port}      ${lag_group}    ${slot}

    Unconfigure LAG Group        n1      ${lag_group}
    Unconfigure Service Role     n2      ${lag_group}
    Unconfigure LAG Group        n2      ${lag_group}
