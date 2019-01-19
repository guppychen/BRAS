*** Settings ***
Documentation     Verify LAG with Traffic
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=nkumar

Suite Setup       Basic_Test_Setup        n1     n2   ${lag_group}    ${lacp_mode}

Suite Teardown    Basic_Test_Teardown     n1     n2   ${lag_group}


*** Variables ***

${value}        	1
${start}		1
${stop}			2
${system_prority}  	1234
${port_priority}   	1
${invalid_lag_group}    laaaaaaaaaa
${max_Lag_value}  	abcdefghijklmnopqrstuvwxyzabcdlkadhfhasdkjfh2sdhjhdsjfkhdkjfhdkj5hdskhfjkdshfjhsdjkfhkjfhsjdhfjshjhsjfjhsdjfhkshfjshfjhsjfhsdfhdjhfkjhfjksdhfjdhjdhjhjfhjkhfjdhfshkshdjhsdjhdskhsddkjfhskdjhkjsdhkjsdhfkjhfkjsdhjhdsjhdsjkfhfhdsjfhjdhjhjhjkhskjhsjfhjhsdhjshjkhjkhsdkjhsdjhkjsdhjkdhjkhdskjhdskfhksjhjkhfjkhf

*** Test Cases ***
Verify Modifications in LAG

    [Documentation]    Action Expected Result Notes

    ...    1. Add ethernet interface of E3 device to the LAG group
    ...    2. Verify ethernet interface of E3 device added to the LAG group
    ...    3. Remove the LAG information from E3 and E5 devices
    ...    4. Check the max number and valid characters of LAG System
    ...    5. Add LACP mode to LAG Group
    ...    6. Shutdown the LAG Interface
    ...    7. Create and check the System Priority for LAG
    ...    8. Check the Port Priority for LAG

    [Tags]         @tcid=AXOS_E72_PARENT-TC-1104    @globalid=2316610    @functional    @priority=P1

    Log   *** Add ethernet interface of E3 device to the LAG group ***

    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}


    Log   *** Verify ethernet interface of E3 device added to the LAG group ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}


    Log   *** Remove the LAG information from E3 and E5 devices ***

    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}


    Log   *** Check the max number and valid characters of LAG System ***

    Check Valid Characters and Bound Status of LAG System    n1   ${invalid_lag_group}
    Check Valid Characters and Bound Status of LAG System    n1   ${max_Lag_value}

    Log   *** Add LACP mode to LAG Group ***

    : FOR    ${value}    IN RANGE    ${start}    ${stop}
    \    Create LAG Group      n1     ${lag_group}     ${lacp_mode${value}}
    \    Check LAG group      n1     ${lag_group}


    Log   *** Shutdown the LAG Interface and Check the Interface ***

    Interface_LAG_shut        n1    ${lag_group}
    Check The LAG Status Shutdown    n1   ${lag_group}
    Interface_LAG_noshut        n1    ${lag_group}
    

    Log   *** Create and check the System Priority for LAG ***

    Create System Priority For LAG    n1     ${system_prority}
    Check System Priority in LAG    n1    ${system_prority}


    Log   *** Check the Port Priority for LAG ***

    Check Port Priority in LAG    n1    ${shelf}   ${slot}   ${DEVICES.n1.ports.p1.port}   ${port_priority}


*** Keywords ***

Basic_Test_Setup

    [Documentation]   Action Expected Result Notes
    ...           1. To Configure LAG Group on both the devices E3 and E5
    ...           2. Verify the inventory status in E5 and E3 devices

    [Arguments]     ${device1}     ${device2}     ${lag_group}    ${lacp_mode}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


Basic_Test_Teardown

    [Documentation]    Action    Expected Result    Notes
     ...               To unconfigure and ensure the device cleanup after testing

    [Arguments]      ${device1}     ${device2}     ${lag_group}

    Unconfigure LAG Group     n1      ${lag_group}
    Unconfigure Service Role   n2      ${lag_group}
    Unconfigure LAG Group     n2      ${lag_group}

