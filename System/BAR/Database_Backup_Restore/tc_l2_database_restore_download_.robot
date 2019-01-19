*** Settings ***
Documentation     This test suite verifies L2 Database Restore "Download"
Resource          base.robot
Force Tags        @feature=Database_Backup_&_Restore    @author=llim     @subfeature=Database Backup and Restore

*** Variables ***


*** Test Cases ***
TC L2 Database Restore "Download"
 
     [Documentation]    This test suite verifies L2 Database Restore "Download"

     ...    1.  Clear all interface counters and enable Session Notifications
     ...    2.  Ensure L2 traffic is running before restore/download
     ...    3.  Copy, upload and verify config upload progress
     ...    4.  Reload system after deleting startup config
     ...    5.  Reconfigure craft port via serial console & wait for platform to fully reload
     ...    6.  Verify that platform is in default settings
     ...    7.  Restore/Download config file via scp 
     ...    8   Verify provisioned config is loaded onto platform
     ...    9.  Verify and reset Session Notifications
     ...    10. Verify tagged and untagged L2 traffic is running after config restore/download
     
   
     [Tags]    @globalid=2224502    @tcid=AXOS_E72_PARENT-TC-174    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4

     Clear Ethernet Interface Counters    n1    ${devices.n1.ports.p1.port}
	 Clear Pon Interface Counters    n1    ${devices.n1.ports.p2.port}
	 Clear Ont Ethernet Interface Counters    n1    ${ont_num}    ${ont_port}
	 Enable Session Notifications     n1
	 
     Tg Create Single Tagged Stream On Port     tg1     up_1    p2    p1    vlan_id=${service_vlan_1}    vlan_user_priority=${vlan_user_priority}    mac_src=${mac_src1}    mac_dst=${mac_dst1}    rate_bps=${rate_bps}     frame_size=${frame_size}    length_mode=${length_mode}  
     Tg Create Double Tagged Stream On Port     tg1     up_2    p2    p1    vlan_id=${service_vlan_2}    vlan_user_priority=${vlan_user_priority}    vlan_id_outer=${service_vlan_1}    vlan_outer_user_priority=${vlan_outer_user_priority}     mac_src=${mac_src2}     mac_dst=${mac_dst2}    rate_bps=${rate_bps}    frame_size=${frame_size}    length_mode=${length_mode}
     Tg Create Untagged Stream On Port    tg1    up_3    p1    p2    mac_src=${mac_dst1}    mac_dst=${mac_src1}    rate_bps=${rate_bps}    frame_size=${frame_size}    length_mode=${length_mode}
     Tg Create Single Tagged Stream On Port     tg1     up_4    p1    p2    vlan_id=${service_vlan_2}    vlan_user_priority=${vlan_user_priority}    mac_src=${mac_dst2}    mac_dst=${mac_src2}    rate_bps=${rate_bps}    frame_size=${frame_size}    length_mode=${length_mode}
     Tg Start All Traffic   tg1
     Sleep    ${traffic_time}
     Run Keyword And Continue On Failure     Verify 99% Traffic Passed Successfully    n1     ${devices.n1.ports.p2.port}
     Tg Stop All Traffic    tg1

	 Copy Running Config To Startup Config     n1
	 Upload Config File     n1      ${location_l2}     ${user_id}     ${scp_serverip}     ${user_password}
     Verify File Transfer Complete    n1
	    
     Delete Startup Config    n1
	 Reload Platform Without Saving Config    n1
	 sleep  3min    sleep for device back
	 Wait Until Keyword Succeeds    10min    20   Verify Cmd Working After Reload  n1_serial   show version

     Configure Craft Port     n1_serial     ${craft_port}    ${devices.n1_serial.ip2}     ${devices.n1_serial.cidr}     ${devices.n1_serial.gw}
     Disconnect    n1_serial
     
     Verify Startup Config Exist     n1
     Verify Running Config In Default Settings    n1
     
     Run Keyword And Continue On Failure    Verify Session No Error     n1
     Clear Session Notifications     n1    

     Download Config File    n1     ${location_l2}    ${user_id}    ${scp_serverip}    ${user_password}
     Verify File Transfer Complete    n1
	 Reload Platform Without Saving Config    n1
	 sleep  3min    sleep for device back
	 Wait Until Keyword Succeeds  5min    20   Verify Cmd Working After Reload  n1_serial   show version
     Verify Running Config Is Provisioned   n1
     
     Run Keyword And Continue On Failure    Verify Session No Error     n1
     Clear Session Notifications     n1
     
     Tg Start All Traffic   tg1
     Sleep    ${traffic_time}
     Run Keyword And Continue On Failure     Verify 99% Traffic Passed Successfully    n1     ${devices.n1.ports.p2.port}
     Tg Stop All Traffic    tg1
    
*** Keywords ***
