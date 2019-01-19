#---------------------------------------------------------------------
##SCRIPT_PROPERTIES
##--------------------------------------------------------------------
##  Synopsis    : Verify LAG Funtionality Check
##  Test Type   : SMOKE
##  Product     : E5
##  TB topo name: NA
##  Area        : LAG
##  SubModule   : NA
##  Component   : NA
##--------------------------------------------------------------------

##--------------------------------------------------------------------
### Global parameters and keywords
###-------------------------------------------------------------------
### TC_DESCRIPTION : Verify LAG Link Distributions
### PLATFORM       : E5
### MODEL          : All
### RUN_TYPE       : FULL
### TEST_STATE     : DEVELOPMENT
### SEQUENTIAL     : NO
###-------------------------------------------------------------------

*** Settings ***
Documentation     Verify LAG Link Distribution
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=sgupta

Suite Setup       Basic_Test_Setup        n1     n2     ${lag_group}

Suite Teardown    Basic_Test_Teardown     n1     n2     ${lag_group}

## ---------------------------------------------------------------------------#
##                               START OF TC's                                #
## ---------------------------------------------------------------------------#

*** Test Cases ***
# ---------------------------------------------------------------------------------------------------------------
# Function   : TC1
# Synopsis   : Link Protection/LAG/Distribution Algorithms/Link Distribution based on Source and Destination MAC
# Return     : Pass/Fail
# ---------------------------------------------------------------------------------------------------------------


Verify LAG Link Distribution based on Source MAC and Destination MAC between E5 and E5 devices

    [Documentation]        #    Action    Expected Result    Notes
    ...    1  Configure  LAG Interface
    ...    2  Verify Dynamic LAG created
    ...    3  Disable L3 Service from Vlan
    ...    4  L3 Service Disabled
    ...    5  create Transport Service Profile
    ...    6  Transport Service Profile Created
    ...    7  Add Transport Service Profile To The Lag Group.
    ...    8  Transport Service Profile Added To The Lag Group.
    ...    9  Check Lag Group Status.
    ...    10 Configure MIn port.
    ...    11 Check MIn port.
    ...    12 Configure max-port with invalid value.
    ...    13 Remove Transport Service Profile From LAg.

    [Tags]       @tcid=AXOS_E72_PARENT-TC-1100    @globalid=2316602    @smoke   @priority=P1


#***** 1. Configure  LAG Interface *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode1}

#***** 2. Verify LAG Interface created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}

#***** 3 Disable L3 Service from Vlan ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Disable L3 Service From Vlan      n1     ${vlan_id}

#***** 4  L3 Service Disabled *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check L3 Service On Vlan      n1     ${vlan_id}

#***** 5 create Transport Service Profile *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Create Transport Service Profile      n1     ${tsp_profile}     ${vlan_id}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Create Transport Service Profile      n2     ${tsp_profile}     ${vlan_id}

#***** 6 Transport Service Profile Created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Check Transport Service Profile Created      n1     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Check Transport Service Profile Created      n2     ${tsp_profile}

#***** 7. Add Transport Service Profile To The Lag Group ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n1     ${lag_group}     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n2     ${lag_group}     ${tsp_profile}
#
#***** 8 Transport Service Profile Added To The Lag Group ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n1     ${lag_group}     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n2     ${lag_group}     ${tsp_profile}


#***** 9 Check Lag Group Status ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode      n1     ${lag_group}    ${lacp_mode1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Lacp Mode      n2     ${lag_group}    ${lacp_mode1}

#***** 10 Configure MIn port ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Min Port      n1     ${lag_group}    ${min_port_2}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Min Port      n2     ${lag_group}    ${min_port_2}

#***** 11 Check MIn port ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Min Port      n1     ${lag_group}    2
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Min Port      n2     ${lag_group}    2

#***** 12 Configure max-port with invalid value
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Max Port Invalid      n1     ${lag_group}    ${max_port_1}    ${str1}
#    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Max Port Invalid      n2     ${lag_group}    ${max_port_1}    ${str1}


*** Keywords ***
# -----------------------------------------------------------------
# Function    : Basic_Test_Setup
# Description : Setup all devices connections and basic preparation
#               before running the test
# Return      : <none>
# -----------------------------------------------------------------

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1 Create Lag Group At Device1 and Device2 

    [Arguments]     ${device1}     ${device2}     ${lag_group}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode}


#---------------------------------------------------------------------
# Function    :  Basic_Test_Teardown
# Description :  Remove the configuration and logoff all devices
# Return      :  <none>
#---------------------------------------------------------------------

Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]      ${device1}     ${device2}      ${lag_group}
#***** 13 Remove Transport Service Profile From LAg

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Remove Transport Service Profile From Lag Group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Remove Transport Service Profile From Lag Group      n2     ${lag_group}

    Unconfigure LAG Group     ${device1}      ${lag_group}
    Unconfigure LAG Group     ${device2}      ${lag_group}


