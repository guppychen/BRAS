*** Settings ***
Documentation     Verify LAG with Traffic
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=nkumar

Suite Setup       Basic_Test_Setup        n1     n2   ${lag_group}    ${lacp_mode}

Suite Teardown    Basic_Test_Teardown     n1     n2   ${lag_group}

*** Test Cases ***
Verify LAG in Active mode and Traffic

    [Documentation]    Action Expected Result Notes
    ...      1. Disable L3 Service from Vlan
    ...      2. L3 Service Disabled
    ...      3. create Transport Service Profile
    ...      4. Transport Service Profile Created
    ...      5. Add ethernet interface of  E3 device to the LAG group
    ...      6. Verify ethernet interface of  E3 device added to the LAG group 
    ...      7. Add ethernet interface of  E5 device to the LAG group
    ...      8. Verify ethernet interface of  E5 device added to the LAG group
    ...      9. Configure LAG Hash method as SRC_MAC for the LAG group*****dd Transport Service Profile To The Lag Group
    ...     10. Transport Service Profile Added To The Lag Group
    ...     11. Add Transport Service Profile To Ethernet Interface
    ...     12. Transport Service Profile Added To Ethernet Interface
    ...     13. Check Group Member Status
    ...     14. Clear Lag interface Counters
    ...     15. Check Lag Interface Tx and Rx Counters Without Traffic
    ...     16. Check Traffic utilization
    ...     17. Verify LAG Hash method as SRC_MAC using traffic
    ...     18. Starting traffic
    ...     19. Check Traffic utilization
    ...     20. Shutdown the interface on one port
    ...     21. Stop traffic
    ...     22. Check Group Member Status
    ...     23. Verify LAG Hash method as SRC_MAC using traffic
    ...     24. Starting traffic
    ...     25. Check Traffic utilization after shutting down the port
    ...     26. Stop traffic
    ...     27. Remove transport service profile from interface
    ...     28. Remove transport service profile from lag
    ...     29. Remove interface from lag
    ...     30. Remove transport service profile

    [Tags]         @tcid=AXOS_E72_PARENT-TC-1033    @globalid=2316519    @functional    @priority=P1


#   Log ***** Disable L3 Service from Vlan ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Disable L3 Service From Vlan      n1     ${vlan_id}


#   Log ***** L3 Service Disabled *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check L3 Service On Vlan      n1     ${vlan_id}


#   Log **** creating max port values ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Max Port      n1     ${lag_group}    1
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Max Port      n2     ${lag_group}    1 

#   Log ***** create Transport Service Profile *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Create Transport Service Profile      n1     ${tsp_profile}     ${vlan_id}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Create Transport Service Profile      n2     ${tsp_profile}     ${vlan_id}


#   Log ***** Transport Service Profile Created *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Check Transport Service Profile Created      n1     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Check Transport Service Profile Created      n2     ${tsp_profile}


#   Log ***** Add ethernet interface of  E3 device to the LAG group *****

    Add Device Interface To LAG With Priority     n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}     1    ${slot}
    Add Device Interface To LAG With Priority     n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}     1    ${slot}


#   Log ***** Verify ethernet interface of  E3 device added to the LAG group *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}


#   Log ***** Add ethernet interface of  E5 device to the LAG group *****

    Add Device Interface To LAG With Priority        n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}     1    ${slot}
    Add Device Interface To LAG With Priority        n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}     1    ${slot}


#   Log ***** Verify ethernet interface of  E5 device added to the LAG group *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}


#   Log *****Configure LAG Hash method as SRC_MAC for the LAG group*****dd Transport Service Profile To The Lag Group ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n1     ${lag_group}     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n2     ${lag_group}     ${tsp_profile}


#   Log ***** Transport Service Profile Added To The Lag Group ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n1     ${lag_group}     ${tsp_profile}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n2     ${lag_group}     ${tsp_profile}


#   Log ***** Add Transport Service Profile To Ethernet Interface ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Interface      n1    ${DEVICES.n1.ports.p3.port}     ${tsp_profile}    ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Interface      n2    ${DEVICES.n2.ports.p3.port}     ${tsp_profile}    ${slot}


#   Log ***** Transport Service Profile Added To Ethernet Interface ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To Interface      n1    ${DEVICES.n1.ports.p3.port}     ${tsp_profile}    ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To Interface      n2    ${DEVICES.n2.ports.p3.port}     ${tsp_profile}    ${slot}


#   Log ***** Check Group Member Status ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}        ${oper_state1}      active
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}        ${oper_state1}      standby

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}        ${oper_state1}      active
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}        ${oper_state1}      standby


#   Log ***** Clear Lag interface Counters ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n2     ${lag_group}


#   Log ***** Check Lag Interface Tx and Rx Counters Without Traffic ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}


#   Log **** Check Traffic utilization ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Active      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Active      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}


#   Log ***** Verify LAG Hash method as SRC_MAC using traffic *****

    Tg Create Single Tagged Stream On Port          tg1     up_1        p2          p1        vlan_id=500     vlan_user_priority=7            mac_src=00:00:01:00:00:01       mac_src_count=100         mac_src_mode=increment          mac_dst=00:00:02:00:00:01       rate_percent=${rate_percent_p1}   frame_size=1024         length_mode=fixed


#   Log **** Starting traffic ****

    Tg Start All Traffic    tg1


#   Log **** Check Traffic utilization ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Active      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Active      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Standby      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}


#   Log **** Shutdown the interface on one port ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Interface_shut_calix        n1    ${DEVICES.n1.ports.p1.port}    ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Interface_shut_calix        n2    ${DEVICES.n2.ports.p1.port}    ${slot}

#   Log **** Stop traffic ****

    Tg Stop All Traffic    tg1
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    tg delete traffic stream    tg1    up_1

#   Log ***** Check Group Member Status ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}        ${oper_state2}      down
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}        ${oper_state1}      active

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}        ${oper_state2}      down
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}        ${oper_state1}      active


#   Log ***** Verify LAG Hash method as SRC_MAC using traffic*****

    Tg Create Single Tagged Stream On Port          tg1     up_1        p2          p1        vlan_id=500     vlan_user_priority=7            mac_src=00:00:01:00:00:01       mac_src_count=100         mac_src_mode=increment          mac_dst=00:00:02:00:00:01       rate_percent=${rate_percent_p1}    frame_size=1024         length_mode=fixed


#   Log **** Starting traffic ****

    Tg Start All Traffic    tg1


#   Log **** Check Traffic utilization after shutting down the port ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Down      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Active      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With And Without Traffic Down      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization With Traffic Active      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}




*** Keyword ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1 Unconfigure LAG from all interfaces of the Device1 and Device2
     ...        2 Unconfigure LAG interface and make the setup ready for execution

    [Arguments]     ${device1}     ${device2}     ${lag_group}   ${lacp_mode}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode1}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]      ${device1}     ${device2}      ${lag_group}
#   Log **** Stop traffic ****

    Tg Stop All Traffic    tg1
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    tg delete traffic stream    tg1    up_1

#   Log **** Remove transport service profile from interface ****

    Remove Transport Service Profile From Interface    n1     ${DEVICES.n1.ports.p3.port}    ${slot}
    Remove Transport Service Profile From Interface    n2     ${DEVICES.n2.ports.p3.port}    ${slot}


#   Log **** Remove transport service profile from lag ****

    Remove Transport Service Profile From Lag Group    n1     ${lag_group}
    Remove Transport Service Profile From Lag Group    n2     ${lag_group}


#   Log **** Remove interface from lag ****

    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p2.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}    ${slot}
    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}    ${slot}


#   Log **** Remove transport service profile ****

    Remove Transport Service Profile    n1     ${tsp_profile}
    Remove Transport Service Profile    n2     ${tsp_profile}

    Unconfigure LAG Group      n1      ${lag_group}
    Unconfigure LAG Group      n2      ${lag_group}
