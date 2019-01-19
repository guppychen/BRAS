*** Settings ***
Documentation     Verify LAG Static  mode configuration get reflected in the settings
Resource          base.robot
Force Tags        @feature=LAG    @subFeature=LAG - Active/Active Same Card    @author=cindy gao     @author=smuruges   @review=RA_278

Suite Setup       Basic_Test_Setup        

Suite Teardown    Basic_Test_Teardown    

*** Variables ***

${value1}          0
${session_number}  0
${bin_time}        5
${bin_duration}    five-minutes
${historicalbin}   12
${profile_name}    lag
${sessionname}     ethernet-10G

*** Test Cases ***

Verify Link Protection/LAG/PM Statistics

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
 
    [Tags]         @tcid=AXOS_E72_PARENT-TC-1086    @globalid=2316585    @functional    @priority=P3


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
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n1     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}        ${oper_state1}      ${lacp_stat${num}}

   :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG Group Member Status      n2     ${lag_group}     ${DEVICES.n2.ports.p${num}.port}        ${oper_state1}      ${lacp_stat${num}}


    #Log ***** Clear Lag interface Counters ****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n${num}     ${lag_group}


    #***** Check Lag Interface Tx and Rx Counters Without Traffic ****
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Tx Counters Without Traffic      n1     ${lag_group}
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Interface Rx Counters Without Traffic      n2     ${lag_group}
    

    #*****Verify LAG using traffic unicast *****
    Tg Create Single Tagged Stream On Port          tg1     up_1        p2          p1        vlan_id=${vlan_id}     vlan_user_priority=7            mac_src=${src_mac1}       mac_src_count=${src_count_mac}         mac_src_mode=increment          mac_dst=${dest_mac1}       rate_percent=${rate_percent_p1}    frame_size=512         length_mode=fixed

    #****Starting traffic ****
    Tg Start All Traffic    tg1
    

    #**** Check Traffic utilization
    #Traffic Will Flow from 1 interface only From Active link No Traffic From Active

    ##    comment    *****time to send traffic*****
    sleep   10

    #:For     ${num}     IN RANGE       1       3
    #     \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Verify Lag Interface Traffic TX RX Utilization Status    n1    n2     ${lag_group}     ${DEVICES.n1.ports.p${num}.port}      ${DEVICES.n2.ports.p${num}.port}   ${lacp_stat1}      ${value1}

    #****Stopping traffic ****    
    Tg Stop All Traffic    tg1

    #Compare Counters
    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check Lag Counters For Tx And Rx     n1     n2     ${lag_group}     ${packet_type1}
    
    #Log ***** Clear Lag interface Counters ****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n${num}     ${lag_group}

    #Log  ******************** Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful ********************
     Configure Grade Of Service Profile    n1    ${profilename}
     Verify GOS Profile configured    n1   ${profilename}

     #Log  ***************** Start the traffic********************
     Tg Start All Traffic    tg1

     Verify LAG Interface Traffic    n1    ${lag_group}

     #Log  ******************** Enable PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successul *******

     Disable PM Session In LAG Interface    n1    ${lag_group}
     Not Sync TOD    n1
     Enable PM Session In LAG Interface    n1    ${lag_group}
     Verify PM Session Is Created on LAG Interface   n1    ${lag_group}    ${session_number}

     #Log  ****** Verify common attributes and attributes specific to its monitored entity are present in current bin and historical bins ***********
     Verify Not Synced TOD Common Bin Attribites on LAG Interface    n1    ${lag_group}

     #Log  ********** Verify packet counetrs matches 3000 K for each attributes in the bins ***********
     Verify PM Session LAG Interface Counters Five Minutes    n1    ${lag_group}


*** Keyword ***

Basic_Test_Setup

    [Documentation]        #    Action    Expected Result    Notes
     ...        1. Configure LAG from all interfaces of the Device1 and Device2
     ...        2. Verify configured lag group status on Device's

    [Arguments]  

    :For     ${num}     IN RANGE       1       3
         \    Show Image Version   n${num}

    :For     ${num}     IN RANGE       1       3
         \    Create LAG Group      n${num}     ${lag_group}     ${lacp_mode1}

    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Check LAG group      n${num}     ${lag_group}

     :For     ${num}     IN RANGE       1       3
         \    Configure LAG Group Max Port     n${num}     ${lag_group}      ${max_port_id}

     :For     ${num}     IN RANGE       1       3
         \    Check LAG Group Max Port      n${num}     ${lag_group}      ${max_port_id}

Basic_Test_Teardown

    [Documentation]        #    Action    Expected Result    Notes
     ...        To unconfigure and ensure the device cleanup after testing

    [Arguments]     
     #Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable PM Session In LAG Interface    n1    ${lag_group}
     Unconfigure Grade Of Service Profile    n1

     #Log  ***************** stop the traffic********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1

    Disable PM Session In LAG Interface     n1    ${lag_group}
    Unconfigure Grade Of Service Profile    n1
    TG Clear Traffic Stats  tg1
    Run Keyword And Continue On Failure    tg delete traffic stream    tg1    up_1

    #Log ***** Clear Lag interface Counters ****
    :For     ${num}     IN RANGE       1       3
         \    Wait Until Keyword Succeeds    60 Seconds    5 Seconds    Clear Lag Interface Counters      n${num}     ${lag_group}

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

