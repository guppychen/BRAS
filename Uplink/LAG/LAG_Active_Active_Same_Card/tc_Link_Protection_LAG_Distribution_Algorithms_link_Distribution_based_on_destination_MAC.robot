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


Veopy E5 device running configuration data *****

    [Documentation]        #    Action    Expected Result    Notes
    ...    1  Disable L3 Service from Vlan.
    ...    2  L3 Service Disabled.
    ...    3 create Transport Service Profile.
    ...    4 Transport Service Profile Created.
    ...    5 Add      ethernet interface of  E3 device to the LAG group.
    ...    6 Verify   ethernet interface of  E3 device added to the LAG group.
    ...    7 Add     ethernet interface of  E5 device to the LAG group.
    ...    8 Verify   ethernet interface of  E5 device added to the LAG group.
    ...    9 Configure LAG Hash method as SRC_MAC for the LAG group*****dd Transport Service Profile To The Lag Group
    ...    10 Transport Service Profile Added To The Lag Group.
    ...    11 Add Transport Service Profile To Ethernet Interface.
    ...    12 Transport Service Profile Added To Ethernet Interface.
    ...    13 Configure LAG Hash method as DST_MAC for the LAG group.
    ...    14 Verify LAG Hash method as DST_MAC for the LAG group
    ...    15 Check Group Member Status.
    ...    16 Clear Lag interface Counters.
    ...    17 Check Lag Interface Tx and Rx Counters Without Traffic.
    ...    18 Check Traffic utilization.
    ...    19 Verify LAG Hash method as DST_MAC using traffic.
    ...    20 Starting traffic.
    ...    21 Check Traffic utilization.
    ...    22 Unconfigure hash-method.
    ...    23 Remove transport service profile from interface.
    ...    24 Remove transport service profile from lag.
    ...    25 Remove interface from lag.
    ...    26 Remove transport service profile.

    [Tags]       @tcid=AXOS_E72_PARENT-TC-1050    @globalid=2316539    @smoke   @priority=P1


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
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}

#***** 6. Verify   ethernet interface of  E3 device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}

#***** 7. Add     ethernet interface of  E5 device to the LAG group *****
    Add Device Interface To LAG       n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}
    Add Device Interface To LAG       n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}

#***** 8. Verify   ethernet interface of  E5 device added to the LAG group *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}



#***** 9. Configure LAG Hash method as SRC_MAC for the LAG group*****dd Transport Service Profile To The Lag Group ****
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

#***** 13. Configure LAG Hash method as DST_MAC for the LAG group *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Hash Method      n1     ${lag_group}     dst-mac
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Hash Method      n2     ${lag_group}     dst-mac

#***** 14. Verify LAG Hash method as DST_MAC for the LAG group*****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Hash Method      n1     ${lag_group}     dst-mac
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Hash Method      n1     ${lag_group}     dst-mac

#***** 15 Check Group Member Status ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}        ${oper_state1}      static
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}        ${oper_state1}      static

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}        ${oper_state1}      static
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}        ${oper_state1}      static


#STEP 1 Send traffic from single source mac and incremented destination mac (25-20)

#***** 16 Clear Lag interface Counters ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n2     ${lag_group}

#***** 17 Check Lag Interface Tx and Rx Counters Without Traffic ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}

#**** 18 Check Traffic utilization
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}

#***** 19. Verify LAG Hash method as DST_MAC using traffic*****
    Tg Create Single Tagged Stream On Port          tg1     up_2        p2          p1
    ...      vlan_id=500     vlan_user_priority=7            mac_src=00:00:01:00:00:01       mac_dst=00:00:02:00:00:01
    ...       mac_dst_count=100         mac_dst_mode=increment       rate_percent=${rate_percent_p1}    frame_size=1024         length_mode=fixed


#**** 20 Starting traffic ****
    Tg Start All Traffic    tg1

#**** 21 Check Traffic utilization
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}

    Wait Until Keyword Succeeds    120 Seconds    5 Seconds    Check Lag Member Traffic Distribution Tx Static      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}     ${DEVICES.n1.ports.p2.port}
    Wait Until Keyword Succeeds    120 Seconds    5 Seconds    Check Lag Member Traffic Distribution Rx Static      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}     ${DEVICES.n2.ports.p2.port}

##    comment    *****time to send traffic*****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters With Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters With Traffic      n2     ${lag_group}



*** Keywords ***
# -----------------------------------------------------------------
# Function    : Basic_Test_Setup
# Description : Setup all devices connections and basic preparation
#               before running the test
# Return      : <none>
# -----------------------------------------------------------------

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1 Configure LAG interface and make the setup ready for execution

    [Arguments]     ${device1}     ${device2}     ${lag_group}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode}

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
    Tg Stop All Traffic    tg1
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    tg delete traffic stream    tg1    up_2

#**** 22 Unconfigure hash-method
    Unconfigure LAG Group Hash Method    n1     ${lag_group}
    Unconfigure LAG Group Hash Method    n2     ${lag_group}

#**** 23 Remove transport service profile from interface
    Remove Transport Service Profile From Interface    n1     ${DEVICES.n1.ports.p3.port}    ${slot}
    Remove Transport Service Profile From Interface    n2     ${DEVICES.n2.ports.p3.port}    ${slot}

#**** 24  Remove transport service profile from lag.
    Remove Transport Service Profile From Lag Group    n1     ${lag_group}
    Remove Transport Service Profile From Lag Group    n2     ${lag_group}

#**** 25 Remove interface from lag
    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}

#**** 26 Remove transport service profile
    Remove Transport Service Profile    n1     ${tsp_profile}
    Remove Transport Service Profile    n2     ${tsp_profile}

    run keyword and ignore error     Tg Stop All Traffic    tg1
    run keyword and ignore error     tg delete traffic stream    tg1    up_2

    Unconfigure LAG Group     ${device1}      ${lag_group}
    Unconfigure LAG Group     ${device2}      ${lag_group}

