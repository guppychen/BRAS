*** Settings ***
Documentation   Initialization file of Database Backup/Restore test suites

Suite Setup       Basic_L2_Test_Setup
Suite Teardown    Basic_L2_Test_Teardown
Resource          ./base.robot
Resource          ./keyword/BAR_keywords.robot

*** Keywords ***
Basic_L2_Test_Setup

    [Documentation]    Configure Basic L2 Test Setup
    [Tags]             @author=llim
    set eut version
    Clear Event Log       n1    
    Configure Vlan     n1     ${service_vlan_1}
    Configure Vlan     n1     ${service_vlan_2}
    Configure Class Map     n1     ${Cmaptype_1}     ${Cmapname_1}    ${service_vlan_2}
    Verify Class Map     n1     ${Cmaptype_1}    ${Cmapname_1}
    Configure Policy Map     n1     ${Pmapname_1}     ${Cmaptype_1}     ${Cmapname_1}
    Verify Policy Map    n1     ${Pmapname_1}
    Configure Transport Service Profile     n1      ${service_vlan_1}
    Configure Transport Service Profile     n1      ${service_vlan_2}
    Verify Transport Service     n1      ${service_vlan_1}
    Verify Transport Service     n1      ${service_vlan_2}
    Enable Ethernet Interface    n1    ${devices.n1.ports.p1.port}
    Configure Ethernet Interface    n1    ${devices.n1.ports.p1.port}
    Verify Ethernet Interface    n1    ${devices.n1.ports.p1.port}
    Enable Pon Interface      n1     ${devices.n1.ports.p2.port}
    Verify Pon Interface      n1     ${devices.n1.ports.p2.port}
    Configure Ont Profile    n1    ${prof_id}    ${ont_port}
    Run Keyword And Warn On Failure    Configure Ont    n1    ${ont_num}    ${ont_desc}    ${prof_id}    ${serial_num}
	Verify Configured Ont    n1    ${ont_num}    ${prof_id}    ${serial_num}
    Configure Ont Interface     n1     ${ont_num}    ${service_vlan_1}    ${Pmapname_1}    ${ont_port}
    Verify Ont Interface     n1     ${service_vlan_1}      ${Pmapname_1}    ${ont_num}    ${ont_port}

Basic_L2_Test_Teardown

    [Documentation]    Unconfigure Basic L2 Test Setup
    [Tags]             @author=llim
    
    run keyword and ignore error   Tg Clear Traffic Stats    tg1
    run keyword and ignore error   Tg Delete All Traffic     tg1
    run keyword and ignore error   wait until keyword succeeds  1min  5s   Verify Session Notifications     n1
    run keyword and ignore error   Clear Session Notifications     n1
    run keyword and ignore error   Unconfigure Ont Interface     n1      ${ont_num}    ${ont_port}    ${service_vlan_1}       ${Pmapname_1}
    run keyword and ignore error   Disable Ont Interface    n1     ${ont_num}    ${ont_port}
    run keyword and ignore error   Unconfigure Ont      n1     ${ont_num}     ${ont_desc}     ${prof_id}      ${serial_num}
    #Run Keyword And Continue On Failure    Unconfigure Ont Profile    n1    ${prof_id} 
    run keyword and ignore error   Unconfigure Policy Map     n1     ${Pmapname_1}     ${Cmaptype_1}      ${Cmapname_1}
    run keyword and ignore error   Unconfigure Ethernet Interface     n1    ${devices.n1.ports.p1.port}
    run keyword and ignore error   Disable Ethernet Interface     n1    ${devices.n1.ports.p1.port}
    run keyword and ignore error   Disable Pon Interface     n1    ${devices.n1.ports.p2.port}
    run keyword and ignore error   Unconfigure Class Map      n1     ${Cmaptype_1}     ${Cmapname_1}
    run keyword and ignore error   Unconfigure Vlan From Transport Service Profile     n1      ${service_vlan_1}
    run keyword and ignore error   Unconfigure Vlan From Transport Service Profile     n1      ${service_vlan_2}
    run keyword and ignore error   Unconfigure Vlan      n1      ${service_vlan_1}
    run keyword and ignore error   Unconfigure Vlan      n1      ${service_vlan_2}
    run keyword and ignore error   Copy Running Config To Startup Config     n1
    run keyword and ignore error   Clear Event Log       n1
    Application Restart Check   n1