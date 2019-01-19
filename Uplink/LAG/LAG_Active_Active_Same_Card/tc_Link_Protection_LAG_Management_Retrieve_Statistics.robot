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
### TC_DESCRIPTION : Verify LAG Active link Traffic
### PLATFORM       : E5
### MODEL          : All
### RUN_TYPE       : FULL
### TEST_STATE     : DEVELOPMENT
### SEQUENTIAL     : NO
###-------------------------------------------------------------------

*** Settings ***
Documentation     Verify LAG Active Link Traffic
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


Verify E5 device running configuration data *****

    [Documentation]        #    Action    Expected Result    Notes
    ...    1  Disable L3 Service from Vlan.
    ...    2  L3 Service Disabled.
    ...    3 create Transport Service Profile.
    ...    4 Transport Service Profile Created.
    ...    5 Add      ethernet interface of  E3 device to the LAG group.
    ...    6 Verify   ethernet interface of  E3 device added to the LAG group.
    ...    7 Add     ethernet interface of  E5 device to the LAG group.
    ...    8 Verify   ethernet interface of  E5 device added to the LAG group.
    ...    9 Add Transport Service Profile To The Lag Group.
    ...    10 Transport Service Profile Added To The Lag Group.
    ...    11 Add Transport Service Profile To Ethernet Interface
    ...    12 Transport Service Profile Added To Ethernet Interface.
    ...    13 Configure LAG group Max-port to 1.
    ...    14 Verify LAG group Max-port
    ...    15 Check Group Member Status.
    ...    16 Clear Lag interface Counters.
    ...    17 Check Lag Interface Tx and Rx Counters Without Traffic.
    ...    18 Check Traffic utilization.
    ...    19 Verify LAG using traffic.
    ...    20 Starting traffic.
    ...    21 Check Traffic utilization.
    ...    22 Clear Lag interface Counters.
    ...    23 Check Lag Interface Tx and Rx Counters Without Traffic.
    ...    24 Remove transport service profile from interface.
    ...    25 Remove transport service profile from lag.
    ...    26 Remove interface from lag.
    ...    27 Remove transport service profile.

    [Tags]       @tcid=AXOS_E72_PARENT-TC-1111    @globalid=2316617    @smoke   @priority=P1

#***** 1 Disable L3 Service from Vlan ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Disable L3 Service From Vlan      n1     ${vlan_id}

#***** 2  L3 Service Disabled *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check L3 Service On Vlan      n1     ${vlan_id}

#***** 3 create Transport Service Profile *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Create Transport Service Profile      n1     ${tsp_profile}     ${vlan_id}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Create Transport Service Profile      n2     ${tsp_profile}     ${vlan_id}

#***** 4 Transport Service Profile Created *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Check Transport Service Profile Created      n1     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Check Transport Service Profile Created      n2     ${tsp_profile}

#***** 5. Add      ethernet interface of  E3 device to the LAG group *****
    Add Device Interface To LAG With Priority      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    1    ${slot}
    Add Device Interface To LAG With Priority      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    1    ${slot}

#***** 6. Verify   ethernet interface of  E3 device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}

#***** 7. Add     ethernet interface of  E5 device to the LAG group *****
    Add Device Interface To LAG With Priority       n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    1    ${slot}
    Add Device Interface To LAG With Priority       n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    1    ${slot}

#***** 8. Verify   ethernet interface of  E5 device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}



#***** 9. Add Transport Service Profile To The Lag Group ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n1     ${lag_group}     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n2     ${lag_group}     ${tsp_profile}

#***** 10 Transport Service Profile Added To The Lag Group ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n1     ${lag_group}     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n2     ${lag_group}     ${tsp_profile}

#***** 11 Add Transport Service Profile To Ethernet Interface ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Interface      n1    ${DEVICES.n1.ports.p3.port}     ${tsp_profile}    ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Interface      n2    ${DEVICES.n2.ports.p3.port}     ${tsp_profile}    ${slot}

#***** 12 Transport Service Profile Added To Ethernet Interface ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To Interface      n1    ${DEVICES.n1.ports.p3.port}     ${tsp_profile}    ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To Interface      n2    ${DEVICES.n2.ports.p3.port}     ${tsp_profile}    ${slot}

#***** 13. Configure LAG group Max-port to 1 *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Max Port      n1     ${lag_group}    1
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Max Port      n2     ${lag_group}    1

#***** 14. Verify LAG group Max-port *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Max Port      n1     ${lag_group}    1
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Max Port      n2     ${lag_group}    1

#***** 15 Check Group Member Status ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}        ${oper_state1}      active
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}        ${oper_state1}      standby

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}        ${oper_state1}      active
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}        ${oper_state1}      standby

#***** 16 Clear Lag interface Counters ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n2     ${lag_group}

#***** 17 Check Lag Interface Tx and Rx Counters Without Traffic ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}

#**** 18 Check Traffic utilization
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Active      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby     n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Active      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby     n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}

#***** 19. Verify LAG using traffic*****
    Tg Create Single Tagged Stream On Port          tg1     up_1        p2          p1        vlan_id=500     vlan_user_priority=7            mac_src=00:00:01:00:00:01       mac_dst=00:00:02:00:00:01       rate_percent=100.00     frame_size=1024         length_mode=fixed

#**** 20 Starting traffic ****
    Tg Start All Traffic    tg1

#**** 21 Check Traffic utilization
#Traffic Will Flow from 1 interface only From Active link No Traffic From Standby
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Active      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby     n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Active      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby     n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

##    comment    *****time to send traffic*****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters With Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters With Traffic      n2     ${lag_group}
    Tg Stop All Traffic    tg1

#Compare Counters
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Counters For Tx And Rx     n1     n2     ${lag_group}     ${packet_type1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    tg delete traffic stream    tg1    up_1

#***** 22 Clear Lag interface Counters ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n2     ${lag_group}

#***** 23 Check Lag Interface Tx and Rx Counters Without Traffic ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}


*** Keywords ***
# -----------------------------------------------------------------
# Function    : Basic_Test_Setup
# Description : Setup all devices connections and basic preparation
#               before running the test
# Return      : <none>
# -----------------------------------------------------------------

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1 Configure LAG.

    [Arguments]     ${device1}     ${device2}     ${lag_group}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode1}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}

#---------------------------------------------------------------------
# Function    :  Basic_Test_Teardown
# Description :  Remove the configuration and logoff all devices
# Return      :  <none>
#---------------------------------------------------------------------

Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]      ${device1}     ${device2}      ${lag_group}

#**** 24 Remove transport service profile from interface
    Remove Transport Service Profile From Interface    n1     ${DEVICES.n1.ports.p3.port}    ${slot}
    Remove Transport Service Profile From Interface    n2     ${DEVICES.n2.ports.p3.port}    ${slot}

#**** 25  Remove transport service profile from lag.
    Remove Transport Service Profile From Lag Group    n1     ${lag_group}
    Remove Transport Service Profile From Lag Group    n2     ${lag_group}

#**** 26 Remove interface from lag
    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}

#**** 27 Remove transport service profile
    Remove Transport Service Profile    n1     ${tsp_profile}
    Remove Transport Service Profile    n2     ${tsp_profile}


    Unconfigure LAG Group     ${device1}      ${lag_group}
    Unconfigure LAG Group     ${device2}      ${lag_group}
