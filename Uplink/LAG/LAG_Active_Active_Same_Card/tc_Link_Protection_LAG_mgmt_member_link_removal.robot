*** Settings ***
Documentation     Verify LAG Static  mode configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=smuruges   @review=RA_278

Suite Setup       Basic_Test_Setup        

Suite Teardown    Basic_Test_Teardown    

*** Test Cases ***

Verify Link Protection/LAG/Management/Member Link Removal

    [Documentation]    Action Expected Result Notes
    ...      1. Disable L3 Service from Vlan
    ...      2. L3 Service Disabled
    ...      3. create Transport Service Profile
    ...      4. Transport Service Profile Created
    ...      5. Add ethernet interface of device to the LAG group
    ...      6. Verify ethernet interface of device added to the LAG group
    ...      7. Add ethernet interface of  E5 device to the LAG group
    ...      8. Configure LAG Hash method as SRC_MAC for the LAG group*****dd Transport Service Profile To The Lag Group
    ...      9. Transport Service Profile Added To The Lag Group
    ...     10. Add Transport Service Profile To Ethernet Interface
    ...     11. Transport Service Profile Added To Ethernet Interface
    ...     12. Check Group Member Status
    ...     13. Clear Lag interface Counters
    ...     14. Check Lag Interface Tx and Rx Counters Without Traffic
    ...     15. Check Traffic utilization and Verify LAG Hash method as SRC_MAC using traffic
    ...     16. Starting traffic and Check traffic utilization.
 
    [Tags]         @tcid=AXOS_E72_PARENT-TC-1106    @globalid=2316612    @functional    @priority=P2


    #Log ***** Disable L3 Service from Vlan ****   
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Disable L3 Service From Vlan      n1     ${vlan_id}

    #Log ***** L3 Service Disabled *****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check L3 Service On Vlan      n1     ${vlan_id}

    #Log ***** create Transport Service Profile *****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Create Transport Service Profile      n${num}     ${tsp_profile}     ${vlan_id}

    #Log ***** Transport Service Profile Created *****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds   Check Transport Service Profile Created      n${num}     ${tsp_profile}

     #Log *** Add ethernet interface of device to the LAG group ***
    :For     ${num}     IN RANGE       1       3
         \    Add Device Interface To LAG      n1     ${DEVICES.n1.ports.p${num}.port}      ${lag_group}    ${slot}

    :For     ${num}     IN RANGE       1       3
         \    Add Device Interface To LAG      n2     ${DEVICES.n2.ports.p${num}.port}      ${lag_group}    ${slot}


     #Log *** Verify ethernet interface of device added to the LAG group ***
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n1     ${DEVICES.n1.ports.p${num}.port}      ${lag_group}

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Interface Added To LAG      n2     ${DEVICES.n2.ports.p${num}.port}      ${lag_group}


   # Log ***** Add ethernet interface of  E5 device to the LAG group *****
   # Add Device Interface To LAG With Priority        n2     ${DEVICES.n2.ports.p1.port}      ${lag_group}     1    ${slot}
   # Add Device Interface To LAG With Priority        n2     ${DEVICES.n2.ports.p2.port}      ${lag_group}     1    ${slot}

    #Log *****Configure LAG Hash method as SRC_MAC for the LAG group*****dd Transport Service Profile To The Lag Group ****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Lag Group      n${num}     ${lag_group}     ${tsp_profile}

    #Log ***** Transport Service Profile Added To The Lag Group ****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To LAG Interface      n${num}     ${lag_group}     ${tsp_profile}

    #Log ***** Add Transport Service Profile To Ethernet Interface ****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Add Transport Service Profile To Interface      n${num}    ${DEVICES.n${num}.ports.p3.port}     ${tsp_profile}    ${slot}


   #Log ***** Transport Service Profile Added To Ethernet Interface ****
   :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Transport Service Profile Added To Interface      n${num}   ${DEVICES.n${num}.ports.p3.port}     ${tsp_profile}    ${slot}


   #Log ***** Check Group Member Status ****
   :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}        ${oper_state1}      static

   :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p${num}.port}        ${oper_state1}      static


    #Log ***** Clear Lag interface Counters ****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n${num}     ${lag_group}

    #Log ***** Check Lag Interface Tx and Rx Counters Without Traffic ****
    :For     ${num}     IN RANGE       1       3
          \     Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n${num}     ${lag_group}

    #Log **** Check Traffic utilization ****
    :For     ${num}     IN RANGE       1       3
          \     Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}

    :For     ${num}     IN RANGE       1       3
          \     Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Traffic Utilization Without Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p${num}.port}


    #Log ***** Verify LAG Hash method as SRC_MAC using traffic*****
    Tg Create Single Tagged Stream On Port          tg1     up_1        p2          p1        vlan_id=${vlan_id}     vlan_user_priority=7            mac_src=${src_mac1}       mac_src_count=${src_count_mac}         mac_src_mode=increment          mac_dst=${dest_mac1}       rate_percent=${rate_percent_p1}     frame_size=${frame_size}         length_mode=fixed

    #Log **** Starting traffic ****
    Tg Start All Traffic    tg1

    comment    *****time to send traffic*****
    sleep   10

    #Log **** Check Traffic utilization ****
    :For     ${num}     IN RANGE       1       3
          \     Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization With Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}

     :For     ${num}     IN RANGE       1       3
          \     Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization With Traffic Static      n2     ${lag_group}     ${DEVICES.n2.ports.p${num}.port}

    #Log **** Stoping and clearing the traffic statistics****
    Tg Stop All Traffic     tg1

     #Compare Counters
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Counters For Tx And Rx     n1     n2     ${lag_group}     ${packet_type1}

 
    #Log   *** Shutdown the neighbour connected interface and verify alarm is generated on connected devices ***

    Interface_shut_calix            n2      ${DEVICES.n2.ports.p1.port}     ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Ethernet Status     n1    ${DEVICES.n1.ports.p1.port}       ${Alarm2}      ${Alarm_stat1}

    #Log   *** Verify the LAG member status static on E3 device***
    
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}      ${oper_state2}     static

    #Log **** Starting traffic ****
    Tg Start All Traffic    tg1

    comment    *****time to send traffic*****
    sleep   10

    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization Without Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p1.port}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Run Keyword And Continue On Failure    Check Lag Interface Traffic Utilization With Traffic Static      n1     ${lag_group}     ${DEVICES.n1.ports.p2.port}

     #Log **** Stoping and clearing the traffic statistics****
     Tg Stop All Traffic     tg1
 
     #Compare Counters
     Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Counters For Tx And Rx     n1     n2     ${lag_group}     ${packet_type1}


    #Log   *** Unshut the neighbour connected interface and verify alarm is generated on connected devices ***

    Interface_noshut_calix          n2      ${DEVICES.n2.ports.p1.port}     ${slot}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Alarm Ethernet Status    n1     ${DEVICES.n1.ports.p1.port}     ${Alarm2}      ${Alarm_stat2}
 

*** Keyword ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1. Configure LAG from all interfaces of the Device1 and Device2
     ...        2. Verify configured lag group status on Device's

    [Arguments]  

    #Log****Verify Device built under test****

    :For     ${num}     IN RANGE       1       3
         \    Show Image Version   n${num}

    #Log****Configure LAG from all interfaces of the Device's****

    :For     ${num}     IN RANGE       1       3
         \    Create LAG Group      n${num}     ${lag_group}     ${lacp_mode}

    #Log****Verify configured lag group status****

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n${num}     ${lag_group}


Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]     

    #Log**** Remove transport service profile from interface****

    :For     ${num}     IN RANGE       1       3
         \    Remove Transport Service Profile From Interface    n${num}     ${DEVICES.n${num}.ports.p3.port}    ${slot}

    #Log**** Remove transport service profile from lag****

    :For     ${num}     IN RANGE       1       3
         \    Remove Transport Service Profile From Lag Group    n${num}     ${lag_group}

    #Log**** Remove interface from lag ****

    :For     ${num}     IN RANGE       1       4
         \    Unconfigure LAG From Device Interface     n1     ${DEVICES.n1.ports.p${num}.port}      ${lag_group}    ${slot}

    :For     ${num}     IN RANGE       1       4
         \    Unconfigure LAG From Device Interface     n2     ${DEVICES.n2.ports.p${num}.port}      ${lag_group}    ${slot}

    #Log**** Remove transport service profile ****

    :For     ${num}     IN RANGE       1       3
         \    Remove Transport Service Profile    n${num}     ${tsp_profile}

    #Log**** Unconfigure LAG group configured ****

    :For     ${num}     IN RANGE       1       3
         \    Unconfigure LAG Group     n${num}      ${lag_group}

    TG Clear Traffic Stats  tg1
    Run Keyword And Continue On Failure    tg delete traffic stream    tg1    up_1

#-------------------------------------------------------------------
## Function    :  Verify no loss
## Description :  Check TX-RX statistics in TG after sending traffic.
## Parameters  :  <none>
## Return      :  PASS
###---------------------------------------------------------------------

Verify no loss

    [Documentation]   Verify for any traffic losses
    [Tags]    @author=HCL Team

    ${rate}   Evaluate   float(0.1)
    Run Keyword And Continue On Failure    TG Verify Traffic Loss For Stream Is Within    tg1    up_1      ${rate}
    ${Criteria}    Evaluate    int(100)
    Tg Verify Traffic Statistics Are Greater Than    tg1    total_pkts    ${Criteria}

