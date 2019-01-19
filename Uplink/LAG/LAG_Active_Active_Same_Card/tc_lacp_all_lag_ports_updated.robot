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
### TC_DESCRIPTION : Verify LAG supported device just contain sufficient lag group interfaces
### PLATFORM       : E5 / ROLT
### MODEL          : All
### RUN_TYPE       : FULL
### TEST_STATE     : DEVELOPMENT
### SEQUENTIAL     : NO
###-------------------------------------------------------------------

*** Settings ***
Documentation     Verify LAG supported device just contain sufficient lag group interfaces
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao            @author=aprakash

Suite Setup       Basic_Test_Setup        
Suite Teardown    Basic_Test_Teardown     

## ---------------------------------------------------------------------------#
##                               START OF TCs                                 #
## ---------------------------------------------------------------------------#

*** Test Cases ***
# ------------------------------------------------------------------------------
# Function   : TC7
# Synopsis   : Verify LAG supported device just contain sufficient lag group interfaces
# Return     : Pass/Fail
# ------------------------------------------------------------------------------

Verify Link Aggregation must support LACP on all LinkAgg group interfaces

    [Documentation]        #    Action    Expected Result    Notes
    ...    1 Configure  LAG group 1 Interface
    ...    2 Configure  LAG group 2 Interface
    ...    3 Configure  LAG group 3 Interface
    ...    4 Configure  LAG group 4 Interface


    [Tags]       @tcid=AXOS_E72_PARENT-TC-1032    @globalid=2316518    @smoke   @priority=P1

#***** Show Device Version *****
    Show Image Version      n1
    Show Image Version      n2


#***** 1. Configure  LAG group 1 Interface *****
    Create LAG Group with LACP mode      n1     ${lag_group}	${lacp_mode1}
    Create LAG Group with LACP mode      n2     ${lag_group}	${lacp_mode1}

#***** Verify LAG Interface created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}

    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}	${slot}
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}	${slot}

#***** Verify ethernet interfaces of the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}

    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}	${slot}


#***** 2. Configure  LAG group 2 Interface *****
    Create LAG Group with LACP mode      n1     ${lag_group2}		${lacp_mode1}
    Create LAG Group with LACP mode      n2     ${lag_group2}		${lacp_mode1}

#***** Verify LAG Interface created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group2}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group2}

#***** Add ethernet interfaces to the 2nd LAG group *****
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group2}	${slot}
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group2}	${slot}

#***** Verify ethernet interfaces of the 2nd LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group2}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group2}

    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group2}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group2}	${slot}


#***** 3. Configure  LAG group 3 Interface *****
    Create LAG Group with LACP mode     n1     ${lag_group3}		${lacp_mode1}
    Create LAG Group with LACP mode     n2     ${lag_group3}		${lacp_mode2}

#***** Verify LAG Interface created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group3}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group3}


#***** Add ethernet interfaces to the 3rd LAG group *****
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group3}	${slot}
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group3}	${slot}

#***** Verify ethernet interfaces of the 3rd LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group3}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group3}

    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group3}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group3}	${slot}


#***** 4. Configure  LAG group 4 Interface *****
    Create LAG Group with LACP mode      n1     ${lag_group4}		${lacp_mode2}
    Create LAG Group with LACP mode      n2     ${lag_group4}		${lacp_mode1}

#***** Verify LAG Interface created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group4}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group4}


#***** Add ethernet interfaces to the 4th LAG group *****
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group4}	${slot}
    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group4}	${slot}

#***** Verify ethernet interfaces of the 4th LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group4}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group4}


*** Keywords ***
# -----------------------------------------------------------------
# Function    : Basic_Test_Setup
# Description : Setup all devices connections and basic preparation
#               before running the test
# Return      : <none>
# -----------------------------------------------------------------

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1 Unconfigure LAG from all interfaces of the Device1 and Device2
     ...        2 Unconfigure LAG interface and make the setup ready for execution

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
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]
    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group4}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group4}	${slot}


    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}	${slot}
    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}	${slot}

    Unconfigure LAG Group     n1      ${lag_group}
    Unconfigure LAG Group     n1      ${lag_group2}
    Unconfigure LAG Group     n1      ${lag_group3}
    Unconfigure LAG Group     n1      ${lag_group4}
    Unconfigure LAG Group     n2      ${lag_group}
    Unconfigure LAG Group     n2      ${lag_group2}
    Unconfigure LAG Group     n2      ${lag_group3}
    Unconfigure LAG Group     n2      ${lag_group4}


