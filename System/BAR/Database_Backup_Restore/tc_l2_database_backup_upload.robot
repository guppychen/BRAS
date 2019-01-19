
*** Settings ***
Documentation     Test suite verifies L2 Database Backup "Upload"
Resource          base.robot
Force Tags        @feature=Database_Backup_&_Restore    @author=llim       

*** Test Cases ***
TC L2 Database Backup "Upload"
 
     [Documentation]       Test suite verifies L2 Database Backup "Upload"
     
     ...    1.  Clear all interface counters
     ...    2.  Enable Session Notifications
     ...    3.  Verify tagged and untagged L2 traffic is running before backup/upload config
     ...    4.  Copy, upload and verify config upload progress
     ...    5.  Verify and reset Session Notifications
     ...    6.  Verify L2 traffic is running after backup/upload config
     ...    7.  Verify and reset Session Notifications
     ...    8.  Change config, upload config and ensure traffic is running after backup/upload config
     ...    9.  Verify and reset Session Notifications
     ...    10. Verify L2 traffic is running
     ...    11. Verify and reset Session Notifications
     
     [Tags]    @globalid=2224501    @tcid=AXOS_E72_PARENT-TC-173    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4    @subfeature=Database Backup and Restore

    Clear Ethernet Interface Counters    n1    ${devices.n1.ports.p1.port}
    Clear Pon Interface Counters    n1    ${devices.n1.ports.p2.port}
    Clear Ont Ethernet Interface Counters    n1    ${ont_num}    ${ont_port}
    Enable Session Notifications     n1
    
    Tg Create Single Tagged Stream On Port     tg1     down_1    p2    p1    vlan_id=${service_vlan_1}    vlan_user_priority=${vlan_user_priority}
    ...    mac_src=${mac_src1}    mac_dst=${mac_dst1}    rate_bps=${rate_bps}     frame_size=${frame_size}
    ...   length_mode=${length_mode}
    Tg Create Double Tagged Stream On Port     tg1     down_2    p2    p1    vlan_id=${service_vlan_2}    vlan_user_priority=${vlan_user_priority}
     ...   vlan_id_outer=${service_vlan_1}    vlan_outer_user_priority=${vlan_outer_user_priority}     mac_src=${mac_src2}
        ...   mac_dst=${mac_dst2}    rate_bps=${rate_bps}    frame_size=${frame_size}    length_mode=${length_mode}
    Tg Create Untagged Stream On Port    tg1    up_1    p1    p2    mac_src=${mac_dst1}    mac_dst=${mac_src1}    rate_bps=${rate_bps}    frame_size=${frame_size}    length_mode=${length_mode}
    Tg Create Single Tagged Stream On Port     tg1     up_2    p1    p2    vlan_id=${service_vlan_2}    vlan_user_priority=${vlan_user_priority}    mac_src=${mac_dst2}    mac_dst=${mac_src2}    rate_bps=${rate_bps}    frame_size=${frame_size}    length_mode=${length_mode}
    Tg save config into file    tg1   /tmp/dbreset.xml
    Tg Start All Traffic   tg1
    Sleep     ${traffic_time}
    Run Keyword And Continue On Failure     Verify 99% Traffic Passed Successfully    n1     ${devices.n1.ports.p2.port}
    Tg Stop All Traffic    tg1
    
    Copy Running Config To Startup Config     n1
    Upload Config File     n1      ${location_l2}     ${user_id}     ${scp_serverip}     ${user_password}
    Verify File Transfer Complete    n1
    Verify Session No Error     n1
    Clear Session Notifications     n1
    
    Tg Start All Traffic   tg1
    Sleep     ${traffic_time}
    Run Keyword And Continue On Failure    Verify 99% Traffic Passed Successfully     n1     ${devices.n1.ports.p2.port}
    Tg Stop All Traffic    tg1
    
    Configure User-Defined Users     n1
    Verify User-Defined Users    n1
    Configure Grade Of Service Profile    n1    ${Cmaptype_1}    ${threshold} 
    Verify Grade Of Service Profile Configured    n1    ${Cmaptype_1}
    
    Copy Running Config To Startup Config     n1
    Upload Config File     n1      ${location_l2}     ${user_id}     ${scp_serverip}     ${user_password}
    Verify File Transfer Complete    n1
    Verify Session No Error     n1
    Clear Session Notifications     n1

    Tg Start All Traffic   tg1
    Sleep     ${traffic_time}
    Run Keyword And Continue On Failure    Verify 99% Traffic Passed Successfully     n1     ${devices.n1.ports.p2.port}
    Tg Stop All Traffic    tg1

*** Keywords ***
