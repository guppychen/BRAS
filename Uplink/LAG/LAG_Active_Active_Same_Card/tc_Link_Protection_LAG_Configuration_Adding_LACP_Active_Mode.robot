*** Settings ***
Documentation     Verify LAG Static  mode configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=smuruges

Suite Setup       Basic_Test_Setup        

Suite Teardown    Basic_Test_Teardown     

*** Test Cases ***

Verify Link Protection/Configuration/Enable LACP mode/Active

    [Documentation]    Action Expected Result Notes
    ...      1. Add ethernet interface of E3 device to the LAG group
    ...      2. Verify ethernet interface of E3 device added to the LAG group
    ...      3. Add ethernet interface of E5 device to the LAG group
    ...      4. Verify ethernet interface of E5 device added to the LAG group
    ...      5. Verify the inventory status in E5 and E3 devices
    ...      6. Verify the LAG member status on E3 and E5 devices
    ...      7. Configure LAG Group on both the devices as active.
    ...      8. Verify the inventory status in E5 and E3 devices as active.
    ...      9. Verify the LAG member status static on E3 and E5 devices as active.

    [Tags]         @tcid=AXOS_E72_PARENT-TC-1035    @globalid=2316521    @functional    @priority=P1

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

  
#    Log   *** Verify the inventory status in E5 and E3 devices ***

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode         n${num}     ${lag_group}    ${lacp_mode}

#    Log   *** Verify the LAG member status static on E3 and E5 devices ***

   :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}        ${oper_state1}      static

    :For     ${num}     IN RANGE       1       3
         \   Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p${num}.port}        ${oper_state1}      static

#    Log   *** Configure LAG Group on both the devices as passive ***

    :For     ${num}     IN RANGE       1       3
         \    Create LAG Group      n${num}     ${lag_group}     ${lacp_mode1}

#    Log   *** Verify the inventory status in E5 and E3 devices as active ***

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode         n1     ${lag_group}    ${lacp_mode1}

#    Log   *** Verify the LAG member status static on E3 and E5 devices as active ***

   :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}        ${oper_state1}     active

    :For     ${num}     IN RANGE       1       3
         \   Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p${num}.port}        ${oper_state1}      active

*** Keywords ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
    ...              1. To Configure LAG Group on both the devices E3 and E5
    ...              2. Verify the LAG Group Status

    [Arguments]     
    
    :For     ${num}     IN RANGE       1       3
         \    Show Image Version   n${num}
     
    :For     ${num}     IN RANGE       1       3
         \    Create LAG Group      n${num}     ${lag_group}     ${lacp_mode}

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n${num}     ${lag_group}

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
