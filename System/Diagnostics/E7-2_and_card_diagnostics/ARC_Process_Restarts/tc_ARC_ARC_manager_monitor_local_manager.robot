*** Settings ***
Documentation     ARC must monitor the following managers that are live upgradable:
...    
...     
...    
...    Following processes should be restartable on E3-2 device:
...     
...    
...    8021x
...    bin-fpga-sat-nat
...    bin-fpga-vulcan
...    bin-fpga-warp
...    bin-fw-sck3001
...    dbgklishxml
...    gfast-mgr 
...    restartable.
...    hal-cdev-np
...    hal-mgr-avon
...    hal-mgr-np
...    hal-mgr-sckipio
...    hal-mgr-vswitch
...    hal-np
...    hal-sckipio
...    hal-vswitch
...    pmconsumer
...    pmpusher
...    t10xx-cpu
...    wddslib
...    aaa
...    arc-mgr
...    bcm-xgs-user
...    boot-init
...    confd  
...    confd-edp
...    confdl
...    cronie 
...    daemonlib
...    dcli
...    diag-mgr
...    iscovery-mgr
...    dyad-rw
...    eaps
...    erpsv2
...    event-manager
...    ewi
...    exa-scripts
...    flow-mgr
...    hal-mgr-dyad
...    hal-mgr-dyaddev
...    hal-mgr-robo
...    hal-mgr-vmac
...    busybox-hwclock
...    if-mgr
...    igmp
...    inithacks
...    init-ifupdown
...    l2-mgr
...    l2hostmgr
...    l2mc-mgr
...    lacp
...    libcmd-parser1
...    libexa-lib1
...    libhallib1
...    libmodulelib1
...    libnetsnmp30
...    libplmpostapi0
...    libsensors4
...    libssallib1
...    libtinyxml2
...    libtinyxpath1
...    lldp
...    loam
...    local-manager
...    log-mgr
...    net-snmp-client
...    net-snmp-mibs
...    net-snmp-server
...    net-snmp-server-snmpd
...    net-snmp-server-snmptrapd
...    ntid
...    ntp 
...    nvpd
...    openssh
...    openssh-keygen
...    openssh-scp
...    openssh-ssh
...    openssh-sshd
...    pam-radius
...    platform-mgr
...    post-init
...    ptcrd
...    qos
...    rstp
...    rsyslog
...    sat-mgr
...    soam
...    ssal-mgr
...    ssalio
...    tmmgr
...    trace-mgr
...    ua-mgr
...    udev
...    upgrade-scripts
...    upgrade-mgr
...    usr-shutdown
...    validate
...    vca
...    vlan-mgr
...    wcat
...    xm
...    xmlify
...    yang
...    dot1x-mgr
...    
...    ==================================================================================================
...    
...    The purpose of this test is to verify that process mentioned in the headline is restartable. This includes:
...    
...        PID changing post restart
...        Runcount should increment
...        Memory consumption should not change drastically
...        Minimal to no impact should be seen on the active traffic on the system
...        No anomalies are observed on the device. Changes should be limited to restart impact for the process being restarted. 
Force Tags        @feature=Diagnostics    @subFeature=E7-2 and card diagnostics    @author=cindy gao
Resource          ./base.robot


*** Variables ***
${manager}    lmd
${shellscript}    lmd.sh


*** Test Cases ***
tc_ARC_ARC_manager_monitor_local_manager
    [Documentation]    1	from linux issue the command: dcli arcmgrd dump summary	Summary should contain the list of managers listed in title
    [Tags]       @author=clakshma     @tcid=AXOS_E72_PARENT-TC-2081   dual_card_not_support
    [Setup]      AXOS_E72_PARENT-TC-2081 setup
    log    STEP:1 from linux issue the command: dcli arcmgrd dump summary Summary should contain the list of managers listed in title

    Check ARC Registration    n1_session2    ${manager}

    # Get all ARC processes before lmd restart
    ${arcmgrs_before}    ${local_mgr_before}    Get ARC process    n1_session2    Manager    ${manager}

    # Restart lmd
    Restart ARC process    n1_session2    ${manager}    ${shellscript}

    # Get all ARC processes after lmd restart
    ${arcmgrs_after}    ${local_mgr_after}    Get ARC process    n1_session2    Manager    ${manager}

    # Validate all ARC processes except lmd if they are the same
    Validate ARC process    n1_session2    ${arcmgrs_before}    ${arcmgrs_after}    ${manager}

    # Validate if lmd process information has changed
    Validate ARC process restart    ${local_mgr_before}     ${local_mgr_after}

    # Validate if there is a restart event in event manager
    Validate ARC Restart event    n1_session1    ${manager}


*** Keywords ***
AXOS_E72_PARENT-TC-2081 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2081 setup
    cli    n1_session1    clear active event-log    \\#    30
