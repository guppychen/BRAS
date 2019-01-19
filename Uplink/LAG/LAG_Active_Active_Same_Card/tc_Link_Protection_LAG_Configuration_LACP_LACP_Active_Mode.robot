*** Settings ***
Documentation     Verify LAG Static  mode configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=nkumar

Suite Setup       Basic_Test_Setup        n1     n2   ${lag_group}    ${lacp_mode1}    ${lacp_mode}

Suite Teardown    Basic_Test_Teardown     n1     n2   ${lag_group}

*** Test Cases ***
Verify LAG Active mode configuration

    [Documentation]    Action Expected Result Notes
    ...      1. Add ethernet interface of E3 device to the LAG group
    ...      2. Verify ethernet interface of E3 device added to the LAG group
    ...      3. Add ethernet interface of E5 device to the LAG group
    ...      4. Verify ethernet interface of E5 device added to the LAG group
    ...      5. Verify the inventory status in E5 and E3 devices
    ...      6. Verify the LAG member status on E3 and E5 devices
    ...      7. Configure LAG Group static on both the devices E3 and E5
    ...      8. Verify the inventory status static in E5 and E3 devices
    ...      9. Verify the LAG status static of Lacp Mode on E3 and E5 devices
    ...      10. Verify the LAG member status static on E3 and E5 devices
    ...      11. Remove the LAG information from E3 and E5 devices

    [Tags]         @tcid=AXOS_E72_PARENT-TC-1026    @globalid=2316509    @functional    @priority=P1

    Log   *** Add ethernet interface of E3 device to the LAG group ***

    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}


    Log   *** Verify ethernet interface of E3 device added to the LAG group ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}


    Log   *** Add ethernet interface of E5 device to the LAG group ***

    Add Device Interface To LAG       n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}
    Add Device Interface To LAG       n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}


    Log   *** Verify ethernet interface of E5 device added to the LAG group ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}


    Log   *** Verify the inventory status in E5 and E3 devices ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode         n1     ${lag_group}    ${lacp_mode1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode         n2     ${lag_group}    ${lacp_mode1}


    Log   *** Verify the LAG member status on E3 and E5 devices ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}        ${oper_state1}      active
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}        ${oper_state1}      active

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}        ${oper_state1}      active
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}        ${oper_state1}      active


    Log   *** Configure LAG Group static on both the devices E3 and E5 ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode}


    Log   *** Verify the inventory status static in E5 and E3 devices ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


    Log   *** Verify the LAG status static of Lacp Mode on E3 and E5 devices ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode         n1     ${lag_group}    ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode         n2     ${lag_group}    ${lacp_mode}


    Log   *** Verify the LAG member status static on E3 and E5 devices ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}        ${oper_state1}      static
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}        ${oper_state1}      static

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}        ${oper_state1}      static
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}        ${oper_state1}      static



*** Keywords ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
    ...              1. To Configure LAG Group on both the devices E3 and E5
    ...              2. Verify the LAG Group Status

    [Arguments]     ${device1}     ${device2}     ${lag_group}    ${lacp_mode1}    ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode1}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}

Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]      ${device1}     ${device2}     ${lag_group}

    Log   *** Remove the LAG information from E3 and E5 devices ***

    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}

    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}
    Unconfigure LAG Group     n1      ${lag_group}
    Unconfigure Service Role     n2      ${lag_group}
    Unconfigure LAG Group     n2      ${lag_group}
