*** Settings ***
Documentation     Verify LAG Supporting Attributes
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=nkumar   @review=RA_278

Suite Setup       Basic_Test_Setup        n1     n2   ${lag_group}    ${lacp_mode}

Suite Teardown    Basic_Test_Teardown     n1     n2   ${lag_group}


*** Test Cases ***
Verify Link Protection/LAG/Distribution Algorithms/Link distribution based on IP address with Ethertype not IP (0x800)

    [Documentation]    Action Expected Result Notes
	...	1. Disable L3 Service from Vlan
	...	2. L3 Service Disabled
	...	3. Basic Setup for LAG
	...	4. Clear Counters
	...	5. Check Lag Interface Tx and Rx Counters Without Traffic
	...	6. Check Traffic utilization
	...	7. Verify LAG Hash method as SRC_DST_IP using traffic
	...	8. Starting traffic
	...	9. Check Traffic utilization
	...	10. time to send traffic
	...	11. Stop and delete traffic
	...	12. Clear Lag interface Counters
	...	13. Check Lag Interface Tx and Rx Counters Without Traffic
	...	14. Check Traffic utilization
	...	15. Verify LAG Hash method as SRC_DST_IP using traffic
	...	16. Starting traffic 
	...	17. Check Traffic utilization
	...	18. Stop and delete traffic
 
    [Tags]         @tcid=AXOS_E72_PARENT-TC-1049    @globalid=2316538    @functional    @priority=P5


#***** 1 Disable L3 Service from Vlan ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Disable L3 Service From Vlan      n1     ${vlan_id}

#***** 2  L3 Service Disabled *****
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


#***** 17 Check Lag Interface Tx and Rx Counters Without Traffic ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}


#**** 18 Check Traffic utilization
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}

#*** Changing mode ***

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Hash Method      n1     ${lag_group}     src-dst-ip
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Configure LAG Group Hash Method      n2     ${lag_group}     src-dst-ip

#***** 19. Verify LAG Hash method as SRC_DST_IP using traffic*****

    Tg Create Single Tagged Stream On Port
    ...  tg1     up_1        p2          p1        vlan_id=500     vlan_user_priority=7
         ...  mac_src=00:00:01:00:00:01          mac_dst=00:00:02:00:00:01            l3_protocol=Arp
              ...   ip_src_addr=192.168.1.1       mac_src_count=100         mac_src_mode=increment
              ...  ip_dst_addr=192.168.1.11       rate_percent=${rate_percent_p1}    frame_size=1024         length_mode=fixed      ether_type=0806


#**** 20 Starting traffic ****
    Tg Start All Traffic    tg1

    TG save config into file    tg1    /tmp/LAG.xml


#**** 21 Check Traffic utilization

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization With Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization With Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization With Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization With Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p2.port}

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Member Traffic Distribution Tx Static      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}     ${DEVICES.n1.ports.p2.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Member Traffic Distribution Rx Static      n2     ${lag_group}     ${DEVICES.n2.ports.p1.port}     ${DEVICES.n2.ports.p2.port}

##    comment    *****time to send traffic*****

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Tx Counters With Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Rx Counters With Traffic      n2     ${lag_group}




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

    Tg Stop All Traffic    tg1

    TG Clear Traffic Stats  tg1
    Run Keyword And Continue On Failure    tg delete traffic stream    tg1    up_1

