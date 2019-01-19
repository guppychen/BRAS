#---------------------------------------------------------------------
##SCRIPT_PROPERTIES
##--------------------------------------------------------------------
##  Synopsis    : Verify LAG Funtionality Check
##  Test Type   : SMOKE
##  Product     : E5 / ROLT
##  TB topo name: NA
##  Area        : LAG
##  SubModule   : NA
##  Component   : NA
##--------------------------------------------------------------------

##--------------------------------------------------------------------
### Global parameters and keywords
###-------------------------------------------------------------------
### TC_DESCRIPTION : Verify LACP Enable and Disable                  
### PLATFORM	   : E5 / ROLT
### MODEL	   : All
### RUN_TYPE	   : FULL
### TEST_STATE     : DEVELOPMENT
### SEQUENTIAL     : NO
###-------------------------------------------------------------------

*** Settings ***
Documentation     Verify LACP Enable and Disable configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao            @author=aprakash

Suite Setup       Basic_Test_Setup            
Suite Teardown    Basic_Test_Teardown     

## ---------------------------------------------------------------------------#
##                               START OF TCs                                 #
## ---------------------------------------------------------------------------#

*** Test Cases ***
# ------------------------------------------------------------------------------
# Function   : TC2
# Synopsis   : Link Protection/LAG/Configuration/LACP/LACP enable/disable
# Return     : Pass/Fail
# ------------------------------------------------------------------------------

Verify LACP Enable and Disable configuration get reflected in the settings

    [Documentation]        #    Action    Expected Result    Notes
    ...    1 Configure  LAG Interface
    ...    2 Verify LAG Interface created
    ...    3 Add     ethernet interface of  first  E5 device to the LAG group
    ...    4 Verify  ethernet interface of  first  E5 device added to the LAG group
    ...    5 Add     ethernet interface of  second E5 device to the LAG group
    ...    6 Verify  ethernet interface of  second E5 device added to the LAG group
    ...    7 Verify LACP Operation  Mode
    ...    8 Shut LAG Interface
    ...    9 Verify LACP Operation  Mode
    ...    10 Enable the LAG Interface
    ...    11 Verify LACP Operation  Mode

    [Tags]       @tcid=AXOS_E72_PARENT-TC-1113    @globalid=2316619    @smoke   @priority=P1

#***** Show Device Version *****
    Show Image Version      n1
    Show Image Version      n2


#***** 1. Configure  LAG Interface *****
    Create LAG Group with LACP mode      n1     ${lag_group}	${lacp_mode1}
    Create LAG Group with LACP mode      n2     ${lag_group}	${lacp_mode1}


#***** 2. Verify LAG Interface created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


#***** 3. Add two ethernet interface of first E3 device to the LAG group *****
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}	${slot}
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}	${slot}


#***** 4. Add two ethernet interface of second E3 device to the LAG group *****
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}	${slot}
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}	${slot}


#***** 5. Verify two ethernet interface of first E3 device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}

#***** 6. Verify  two ethernet interface of  second E5 device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}


#***** 7. Verify LACP Operation  Mode *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n1     ${DEVICES.n1.ports.p2.port}     ${lag_group}      ${oper_state1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n2     ${DEVICES.n2.ports.p2.port}     ${lag_group}      ${oper_state1}

#***** 8. Shut LAG Interface *****
    Interface_LAG_shut      n1     ${lag_group}
    Interface_LAG_shut      n2     ${lag_group}

#***** 9. Verify LACP Operation  Mode *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n1     ${DEVICES.n1.ports.p2.port}     ${lag_group}      ${oper_state2}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n2     ${DEVICES.n2.ports.p2.port}     ${lag_group}      ${oper_state2}


#***** 10. Enable the LAG Interface *****
    Interface_LAG_noshut      n1     ${lag_group}
    Interface_LAG_noshut      n2     ${lag_group}
    

#***** 11. Verify LACP Operation  Mode *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n1     ${DEVICES.n1.ports.p2.port}     ${lag_group}      ${oper_state1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n2     ${DEVICES.n2.ports.p2.port}     ${lag_group}      ${oper_state1}
             

#***** 12. Configure LACP Passive / Active  Mode *****
    Create LAG Group with LACP mode      n1     ${lag_group}	${lacp_mode2}
    Create LAG Group with LACP mode      n2     ${lag_group}	${lacp_mode1}

#***** 13. Verify LACP Operation Mode *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n1     ${DEVICES.n1.ports.p2.port}     ${lag_group}      ${oper_state1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n2     ${DEVICES.n2.ports.p2.port}     ${lag_group}      ${oper_state1}

#***** 14. Configure LACP Static Mode *****
    Create LAG Group with LACP mode      n1     ${lag_group}	${lacp_mode}
    Create LAG Group with LACP mode      n2     ${lag_group}	${lacp_mode}

#***** 15. Verify LACP Operation Mode *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n1     ${DEVICES.n1.ports.p2.port}     ${lag_group}      ${oper_state1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n2     ${DEVICES.n2.ports.p2.port}     ${lag_group}      ${oper_state1}


*** Keywords ***
# -----------------------------------------------------------------
# Function    : Basic_Test_Setup
# Description : Setup all devices connections and basic preparation
#               before running the test
# Return      : <none>
# -----------------------------------------------------------------

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ... 	1 Unconfigure LAG from all interfaces of the Device1 and Device2
     ... 	2 Unconfigure LAG interface and make the setup ready for execution

    [Arguments]

    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}	${slot}

    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}	${slot}

    Unconfigure LAG Group     n1      ${lag_group}
    Unconfigure LAG Group     n2      ${lag_group}


#---------------------------------------------------------------------
# Function    :  Basic_Test_Teardown
# Description :  Remove the configuration and logoff all devices
# Return      :  <none>
#---------------------------------------------------------------------

Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ... 	To unconfigure and ensure the device cleanup after testing

    [Arguments]      

    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}	${slot}

    Unconfigure LAG Group     n1      ${lag_group}
    Unconfigure LAG Group     n1      ${lag_group}

