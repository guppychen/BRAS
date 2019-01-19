*** Settings ***
Documentation     This test suite verifies L2 Database Restore "Download" During Power Down/Up
Resource          base.robot
Force Tags        @feature=Database_Backup_&_Restore    @author=llim    @subfeature=Database Backup and Restore

*** Variables ***

#${url}            ${PowerOutlet.url}
#${browser}        ${PowerOutlet.browser}
#${uname}          ${PowerOutlet.uname}
#${pword}          ${PowerOutlet.pword}
#${port}           ${PowerOutlet.port}

*** Test Cases ***
TC L2 Database Restore "Download" During Down/Up
 
     [Documentation]      This test suite verifies L2 Database Restore "Download" During Power Down/Up

     ...    1.  Clear all interface counters and enable Session Notifications
     ...    2.  Ensure L2 traffic is running before restore/download
     ...    3.  Copy, upload and verify config upload progress
     ...    4.  Reload system after deleting startup config
     ...    5.  Reconfigure craft port via serial console & wait for platform to fully reload
     ...    6.  Verify that platform is in default settings
     ...    7.  Restore/Download config file to platform
     ...    5.  Power cycle platform chassis while downloading config
     ...    6.  Verify and reset Session Notifications after platform reload completely
     ...    7.  Verify L2 traffic is running ??
     ...    8.  Verify and reset Session Notifications
     ...    9.  Restore/Download config file to platform and verify download complete
     ...    10. Power cycle platform chassis 
     ...    11. Verify and reset Session Notifications after platform reload completely
     ...    12. Verify L2 traffic is running after restore/download config
     ...    13. Verify and reset Session Notifications
   
     [Tags]    @globalid=2224504    @tcid=AXOS_E72_PARENT-TC-176    @user_interface=CLI     @priority=P1    @functional   @eut=NGPON2-4

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

	 sleep   3min    sleep for device back
	 Wait Until Keyword Succeeds  5min    20   Verify Cmd Working After Reload  n1_serial   show version
     Configure Craft Port     n1_serial     ${craft_port}    ${devices.n1_serial.ip2}     ${devices.n1_serial.cidr}     ${devices.n1_serial.gw}
     Disconnect    n1_serial
     
     Verify Startup Config Exist     n1
     Verify Running Config In Default Settings    n1
     
     Verify Session No Error     n1
     Clear Session Notifications     n1    

     Download Config File    n1     ${location_l2}    ${user_id}    ${scp_serverip}    ${user_password}
     Verify File Transfer Complete    n1
     Verify file and expect value   n1   config  startup-config.xml   ${devices.n1.ip}
     sleep   30s
#     Power Cycle Platform Via -48v Power Web    ${browser}    ${url}    ${uname}    ${pword}    ${port}
     # modified by llin EXA-27987 2018.2.23
     Apc Power Cycle	  apc1     ${apc_line}       30
     # modified by llin EXA-27987 2018.2.23
     Wait For Platform To Return    n1    
     Run Keyword And Warn On Failure    Verify Running Config Is Provisioned    n1
     
     Verify Session No Error     n1
     Clear Session Notifications     n1
     
     Tg Start All Traffic   tg1
     Sleep    ${traffic_time}
     Run Keyword And Continue On Failure     Verify 99% Traffic Passed Successfully    n1     ${devices.n1.ports.p2.port}
     Tg Stop All Traffic    tg1
     Verify Session No Error     n1
     Clear Session Notifications     n1
     
     Download Config File    n1     ${location_l2}    ${user_id}    ${scp_serverip}    ${user_password}
     Verify File Transfer Complete    n1
#     Power Cycle Platform Via -48v Power Web    ${browser}    ${url}    ${uname}    ${pword}    ${port}
     # modified by llin EXA-27987 2018.2.23
     Apc Power Cycle	  apc1     ${apc_line}       30
     # modified by llin EXA-27987 2018.2.23

     Wait For Platform To Return    n1    
     Verify Running Config Is Provisioned   n1
     
     Verify Session No Error     n1
     Clear Session Notifications     n1

     Tg Start All Traffic   tg1
     Sleep    ${traffic_time}
     Run Keyword And Continue On Failure     Verify 99% Traffic Passed Successfully    n1     ${devices.n1.ports.p2.port}
     Tg Stop All Traffic    tg1
    
*** Keywords ***

