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
### TC_DESCRIPTION : Verify LACP Active and Passive mode                  
### PLATFORM	   : E5 / ROLT
### MODEL	   : All
### RUN_TYPE	   : FULL
### TEST_STATE     : DEVELOPMENT
### SEQUENTIAL     : NO
###-------------------------------------------------------------------

*** Settings ***
Documentation     Verify LACP Active and Passive mode configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao            @author=aprakash

Suite Setup       Basic_Test_Setup            
Suite Teardown    Basic_Test_Teardown     

## ---------------------------------------------------------------------------#
##                               START OF TCs                                 #
## ---------------------------------------------------------------------------#

*** Test Cases ***
# ------------------------------------------------------------------------------
# Function   : TC3
# Synopsis   : Link Protection/LAG/Configuration/LACP/ LACP active and passive mode
# Return     : Pass/Fail
# ------------------------------------------------------------------------------

Verify LACP Active and Passive mode configuration get reflected in the settings

    [Documentation]        #    Action    Expected Result    Notes
    ...    1 Configure  LAG Interface
    ...    2 Verify LAG Interface created
    ...    3 Add     two ethernet interface of  first  E5 device to the LAG group
    ...    4 Verify  two ethernet interface of  first  E5 device added to the LAG group
    ...    5 Add     two ethernet interface of  second E5 device to the LAG group
    ...    6 Verify  two ethernet interface of  second E5 device added to the LAG group
    ...    7 Verify Active and Passive LACP got reflected in settings

    [Tags]       @tcid=AXOS_E72_PARENT-TC-1042    @globalid=2316528    @smoke   @priority=P1

#***** Show Device Version *****
    Show Image Version      n1
    Show Image Version      n2

#***** 1. Configure  LAG Interface *****
    Create LAG Group with LACP mode     n1     ${lag_group}		${lacp_mode1}
    Create LAG Group with LACP mode     n2     ${lag_group}		${lacp_mode2}

#***** 2. Verify LAG Interface created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}

#***** 3. Add two ethernet interface of  first E5/ROLT device to the LAG group *****
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}	${slot}
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}	${slot}

#***** 4. Verify two ethernet interface of first E5/ROLT device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}

#***** 5. Add  two ethernet interface of second E5/ROLT device to the LAG group *****
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}	${slot}
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}	${slot}

#***** 6. Verify  two ethernet interface of  second E5 device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}

#***** 7. Verify LACP  Mode *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LACP Mode      n1     ${lag_group}      ${lacp_mode1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LACP Mode      n2     ${lag_group}      ${lacp_mode2}

#***** 8. Verify interface status *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n1     ${DEVICES.n1.ports.p1.port}         ${lag_group}     ${oper_state1} 
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n1     ${DEVICES.n1.ports.p2.port}         ${lag_group}      ${oper_state1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n2     ${DEVICES.n2.ports.p1.port}         ${lag_group}      ${oper_state1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Interface State      n2     ${DEVICES.n2.ports.p2.port}         ${lag_group}      ${oper_state1}

#***** 9. Verify interface LACP status *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LACP Status      n1     ${DEVICES.n1.ports.p1.port}     ${lag_group}      ${lacp_status1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LACP Status      n1     ${DEVICES.n1.ports.p2.port}     ${lag_group}      ${lacp_status1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LACP Status      n2     ${DEVICES.n2.ports.p1.port}     ${lag_group}      ${lacp_status1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LACP Status      n2     ${DEVICES.n2.ports.p2.port}     ${lag_group}      ${lacp_status1}


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
    Unconfigure LAG Group     n2      ${lag_group}

                                                                                
