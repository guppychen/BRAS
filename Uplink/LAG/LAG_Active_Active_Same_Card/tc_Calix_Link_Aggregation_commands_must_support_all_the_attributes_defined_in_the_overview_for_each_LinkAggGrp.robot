*** Settings ***
Documentation     Verify LAG Supporting Attributes
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=nkumar   @review=RA_278

Suite Setup       Basic_Test_Setup        n1     n2   ${lag_group}    ${lacp_mode}

Suite Teardown    Basic_Test_Teardown     n1     n2   ${lag_group}


*** Test Cases ***
Verify Calix Link Aggregation commands must support all the attributes defined in the overview for each LinkAggGrp

    [Documentation]    Action Expected Result Notes
	...	1. Disable L3 Service from Vlan
	...	2. L3 Service Disabled
	...	3. Basic Setup for LAG
	...	4. Clear Counters
	...	5. Check Lag Interface Tx and Rx Counters Without Traffic
	...	6. Verify LAG Hash method as SRC_MAC using traffic
	...	7. Starting traffic
	...	8. Check Lag Interface Tx and Rx Counters Without Traffic
	...	9. Stop traffic
	...	10. Create LAG group with LACP mode
	...	11. Verify the LAG Status description
	...	12. Shutdown the interface and check the admin state and operation state and speed
	...	13. Clear Lag interface Counters
	...	14. Verify LAG Hash method as SRC_MAC using traffic
	...	15. Starting traffic
	...	16. Check Lag Interface Tx and Rx Counters Without Traffic
	...	17. Stop traffic
	...	18. Clear Counters
	...	19. Unshut the LAG and verify the max and operation speed
	...	20. create and verify the LACP priority
	...	21. Check the max number and valid characters of LAG System

    [Tags]         @tcid=AXOS_E72_PARENT-TC-1031    @globalid=2316517    @functional    @priority=P4

#   Log ***** Disable L3 Service from Vlan ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Disable L3 Service From Vlan      n1     ${vlan_id}


#   Log ***** L3 Service Disabled *****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check L3 Service On Vlan      n1     ${vlan_id}


#   Log *** Basic Setup for LAG ***

    : FOR    ${value}    IN RANGE    ${start}    ${stop}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Max Port      n${value}     ${lag_group}    2
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create Transport Service Profile      n${value}     ${tsp_profile}     ${vlan_id}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Created      n${value}     ${tsp_profile}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p${value}.port}      ${lag_group}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p${value}.port}      ${lag_group}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p${value}.port}      ${lag_group}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p${value}.port}      ${lag_group}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n${value}     ${lag_group}     ${tsp_profile}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n${value}     ${lag_group}     ${tsp_profile}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Interface      n${value}    ${DEVICES.n1.ports.p3.port}     ${tsp_profile}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To Interface      n${value}    ${DEVICES.n1.ports.p3.port}     ${tsp_profile}    ${slot}
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p${value}.port}        ${oper_state1}      static
    \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p${value}.port}        ${oper_state1}      static


#   Log **** Clear Counters ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n2     ${lag_group}

#   Log ***** Check Lag Interface Tx and Rx Counters Without Traffic ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}


#   Log ***** Verify LAG Hash method as SRC_MAC using traffic*****

    Tg Create Single Tagged Stream On Port          tg1     up_2        p2          p1        vlan_id=500     vlan_user_priority=7            mac_src=00:00:01:00:00:01       mac_src_count=100         mac_src_mode=increment
            ...     mac_dst=00:00:02:00:00:01       rate_percent=${rate_percent_p1}     frame_size=1024         length_mode=fixed

    tg save config into file    tg1    /tmp/lag.xml

#   Log **** Starting traffic ****

    Tg Start All Traffic    tg1


#   Log ***** Check Lag Interface Tx and Rx Counters Without Traffic ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Tx Counters With Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Rx Counters With Traffic      n2     ${lag_group}


#   Log **** Stop traffic ****

    Tg Stop All Traffic    tg1
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    tg delete traffic stream    tg1    up_2

#   Log   *** Create LAG group with LACP mode ***

    Create LAG Group      n1     ${lag_group}     ${lacp_mode1}
    Create LAG Group      n2     ${lag_group}     ${lacp_mode1}
    Check LAG group      n1     ${lag_group}
    Check LAG group      n2     ${lag_group}


#   Log   *** Verify the LAG Status description ***

    Check Status Description    n1


#   Log   *** Shutdown the interface and check the admin state and operation state and speed ***

    Interface_LAG_shut        n1    ${lag_group}
    Check LAG Group Status Operating State    n1     ${lag_group}    ${oper_state2}
    Check LAG Group Status Admin State    n1     ${lag_group}    ${admin_state2}


#   Log ***** Clear Lag interface Counters ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n2     ${lag_group}


#   Log ***** Verify LAG Hash method as SRC_MAC using traffic*****

    Tg Create Single Tagged Stream On Port          tg1     up_1        p2          p1        vlan_id=500     vlan_user_priority=7            mac_src=00:00:01:00:00:01       mac_src_count=100         mac_src_mode=increment          mac_dst=00:00:02:00:00:01
       ...   rate_percent=${rate_percent_p1}     frame_size=1024         length_mode=fixed


#   Log **** Starting traffic ****

    Tg Start All Traffic    tg1


#   Log ***** Check Lag Interface Tx and Rx Counters Without Traffic ****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}


#   Log **** Stop traffic ****

    Tg Stop All Traffic    tg1


#   Log **** Clear Counters ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n2     ${lag_group}


#   Log *** Unshut the LAG and verify the max and operation speed ***

    Interface_LAG_noshut        n1    ${lag_group}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Max Speed    n1     ${lag_group}    ${max_speed1}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Status Operation Speed    n2     ${lag_group}    ${oper_speed1}


#   Log *** create and verify the LACP priority ***

    Create System Priority For LAG    n1     ${system_prority}
    Check System Priority in LAG    n1    ${system_prority}


#   Log   *** Check the max number and valid characters of LAG System ***

    Check Valid Characters and Bound Status of LAG System    n1   ${invalid_lag_group}
    Check Valid Characters and Bound Status of LAG System    n1   ${max_Lag_value}


*** Keyword ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1 Unconfigure LAG from all interfaces of the Device1 and Device2
     ...        2 Unconfigure LAG interface and make the setup ready for execution

    [Arguments]     ${device1}     ${device2}     ${lag_group}   ${lacp_mode}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n1     ${lag_group}     ${lacp_mode}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Create LAG Group      n2     ${lag_group}     ${lacp_mode}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n2     ${lag_group}


Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]      ${device1}     ${device2}      ${lag_group}

#   Log **** To unconfigure and ensure the device cleanup after testing ****

    : FOR    ${value}    IN RANGE    ${start}    ${stop}
    \    Unconfigure LAG Group Hash Method    n${value}     ${lag_group}
    \    Remove Transport Service Profile From Interface    n${value}     ${DEVICES.n1.ports.p3.port}    ${slot}
    \    Remove Transport Service Profile From Lag Group    n${value}     ${lag_group}
    \    Remove Transport Service Profile    n${value}     ${tsp_profile}

    : FOR    ${value}    IN RANGE    ${start}    ${stop}
    \    Unconfigure LAG From Device Interface    n1     ${DEVICES.n1.ports.p${value}.port}      ${lag_group}    ${slot}
    \    Unconfigure LAG From Device Interface    n2     ${DEVICES.n2.ports.p${value}.port}      ${lag_group}    ${slot}

    Unconfigure Service Role   n2      ${lag_group}

    : FOR    ${value}    IN RANGE    ${start}    ${stop}
    \    Unconfigure LAG Group     n${value}      ${lag_group}

    TG Clear Traffic Stats  tg1
    Run Keyword And Continue On Failure   tg delete traffic stream    tg1    up_1

