*** Settings ***
Documentation     Verify LAG Static  mode configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Standby Same Card    @author=cindy gao    @author=nkumar   @review=RA_300

Suite Setup       Basic_Test_Setup       

Suite Teardown    Basic_Test_Teardown    


*** Test Cases ***
Verify Link Protection LAG Alarms LACP down alarm

    [Documentation]    Action Expected Result Notes
	...	1. Disable L3 Service from Vlan
        ...	2. L3 Service Disabled
	...	3. Basic Setup for LAG
	...	4. Switching Alarm from one port to other and Verifying the LAG Status

    [Tags]         @tcid=AXOS_E72_PARENT-TC-1112    @globalid=2316618    @functional    @priority=P1


#   Log ***** Disable L3 Service from Vlan ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Disable L3 Service From Vlan      n1     ${vlan_id}


#   Log ***** L3 Service Disabled *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check L3 Service On Vlan      n1     ${vlan_id}

#   Log *** Basic Setup for LAG ***

    : FOR    ${value}    IN RANGE    ${start}    ${stop}

    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Show Image Version     n${value}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group    n${value}     ${lag_group}     ${lacp_mode1}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n${value}     ${lag_group}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p${value}.port}      ${lag_group}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p${value}.port}      ${lag_group}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p${value}.port}      ${lag_group}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p${value}.port}      ${lag_group}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG With Priority    n1     ${DEVICES.n1.ports.p${value}.port}      ${lag_group}    ${lacp_priority}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG With Priority    n2     ${DEVICES.n2.ports.p${value}.port}      ${lag_group}    ${lacp_priority}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Configure LAG Group Max Port      n${value}     ${lag_group}    1 
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group    n${value}     ${lag_group}


#   Log   *** Switching Alarm from one port to other and Verifying the LAG Status ***


    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Status    n1     ${lag_group}    ${Alarm1}    ${Alarm_stat2}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Unconfigure LAG Group From Device Interface    n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Status    n1     ${lag_group}    ${Alarm1}    ${Alarm_stat2}
    Wait Until Keyword Succeeds    150 Seconds    15 Seconds    Check Alarm Status With LACP    n1     ${lacp_mode1}     ${lacp_status_on_port1}


    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Status    n1     ${lag_group}    ${Alarm1}    ${Alarm_stat2}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Unconfigure LAG Group From Device Interface    n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Status    n1     ${lag_group}    ${Alarm1}    ${Alarm_stat2}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Alarm Status With LACP    n1     ${lacp_mode1}     ${lacp_status_on_port1}


    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Status    n1     ${lag_group}    ${Alarm1}    ${Alarm_stat2}


*** Keyword ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1 Unconfigure LAG from all interfaces of the Device1 and Device2
     ...        2 Unconfigure LAG interface and make the setup ready for execution

    [Arguments]    

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...	1. Remove interface from lag
     ...        2. To unconfigure and ensure the device cleanup after testing

    [Arguments]     

#   Log **** Remove interface from lag ****

    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}

    Unconfigure LAG Group     n1      ${lag_group}
    Unconfigure Service Role  n2      ${lag_group}
    Unconfigure LAG Group     n2      ${lag_group}


