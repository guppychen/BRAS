*** Settings ***
Documentation   Initialization file of PM test suites

Suite Setup       Basic_L2_Test_Setup
Suite Teardown    Basic_L2_Test_Teardown
Resource          ./base.robot
Resource          ./keyword/PM_keywords.robot
Force Tags        @require=2stc1eut1ont   @subfeature=NNI Ethernet Port PM
#Resource          ../Milan/keywords/keyword_common.robot

*** Variable ***
${historical_bin}    12 

*** Keywords ***

Basic_L2_Test_Setup

    [Documentation]    Configure Basic L2 Test Setup
    [Tags]             @author=llim
    
    Configure Vlan     n1     ${service_vlan_1}
    Configure Class Map     n1     ${Cmaptype_1}     ${Cmapname_1}    ${service_vlan_1}
    Verify Class Map     n1     ${Cmaptype_1}    ${Cmapname_1}
    Configure Policy Map     n1     ${Pmapname_1}     ${Cmaptype_1}     ${Cmapname_1}
    Verify Policy Map    n1     ${Pmapname_1}
    Configure Transport Service Profile     n1      ${service_vlan_1}
    Verify Transport Service     n1      ${service_vlan_1}
    Enable Ethernet Interface    n1    ${DEVICES.n1.ports.p1.port}
    Configure Ethernet Interface    n1    ${DEVICES.n1.ports.p1.port}
    wait until keyword succeeds   10s   60s   Verify Ethernet Interface    n1    ${DEVICES.n1.ports.p1.port}
    Enable Pon Interface      n1     ${devices.n1.ports.p2.port}
    Verify Pon Interface      n1     ${devices.n1.ports.p2.port}
    Run Keyword And Warn On Failure    Configure Ont    n1    ${ont_num}    ${ont_desc}    ${prof_id}    ${serial_num}
	Verify Configured Ont    n1    ${ont_num}    ${prof_id}    ${serial_num}
    Configure Ont Interface     n1     ${ont_num}    ${service_vlan_1}    ${Pmapname_1}    ${ont_port}
    Verify Ont Interface     n1     ${service_vlan_1}      ${Pmapname_1}    ${ont_num}    ${ont_port}

Basic_L2_Test_Teardown

    [Documentation]    Unconfigure Basic L2 Test Setup
    [Tags]             @author=llim
    
    run keyword and ignore error  Tg Clear Traffic Stats    tg1
    run keyword and ignore error  Tg Delete All Traffic     tg1
    Unconfigure Ont Interface     n1      ${ont_num}    ${ont_port}    ${service_vlan_1}    ${Pmapname_1}
    Disable Ont Interface    n1     ${ont_num}    ${ont_port}
    Unconfigure Ont      n1     ${ont_num}     ${ont_desc}     ${prof_id}      ${serial_num}
    run keyword and ignore error  Unconfigure Policy Map     n1     ${Pmapname_1}     ${Cmaptype_1}      ${Cmapname_1}
    run keyword and ignore error  Unconfigure Ethernet Interface     n1    ${devices.n1.ports.p1.port}
    Disable Ethernet Interface     n1    ${devices.n1.ports.p1.port}
    Disable Pon Interface     n1    ${devices.n1.ports.p2.port}
    run keyword and ignore error   Unconfigure Class Map      n1     ${Cmaptype_1}     ${Cmapname_1}
    run keyword and ignore error   Unconfigure Vlan From Transport Service Profile     n1      ${service_vlan_1}
    Unconfigure Vlan      n1      ${service_vlan_1}
    Application Restart Check   n1
    cli    n1    show running-config | nomore         timeout=30
