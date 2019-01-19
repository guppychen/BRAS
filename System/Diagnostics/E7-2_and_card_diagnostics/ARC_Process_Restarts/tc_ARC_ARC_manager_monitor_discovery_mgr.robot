*** Settings ***
Documentation     ARC must monitor the following managers that are live upgradeable:
...    
...    arc-mgr
...    bcm-xgs
...    bcm-xgs-user
...    ccd
...    daemonlib
...    dcli
...    diag-mgr
...    dunsel-fpga
...    dyad-fgpa
...    dyad-rw
...    eaps
...    erpsv2
...    event-init
...    event-manager
...    event-mod
...    exa-scripts
...    example-daemon
...    ewi
...    flow-mgr
...    fta
...    hal-bcmxgsu
...    hal-dyaddev
...    hal-mgr-bcmxgsu
...    hal-mgr-dyad
...    hal-mgr-dyaddev
...    hal-mgr-robo
...    hal-mgr-vmac
...    hal-mgr-vwidget
...    hal-robo
...    hal-vmac
...    hal-vswitch
...    halvwidget
...    hostmgr
...    if-mgr
...    igmp
...    inithacks
...    hap
...    l2-mgr
...    l2hostmgr
...    l2mc-mgr
...    lacp
...    libcmd-parser1
...    libexa-lib1
...    libhallib1
...    libplm0
...    libsensors4
...    libssallib1
...    lldp
...    lmsensors-scripts
...    lmsensors-sensors
...    loam
...    local-manager
...    max16031
...    mdio-rw
...    ntid
...    ntp
...    ntp-tickadgj
...    nvpd
...    OM-8SFP-FPGA
...    plmgrd
...    pmconsumer
...    post-init
...    proc-fifo
...    qos
...    semtech-firmware
...    service-manager
...    soam
...    ssal
...    ssal-mgr
...    ssalio
...    Stugots-FPGA
...    openssh
...    tinyxml
...    tinyxpath
...    tmmgr
...    trace-mgr
...    u-boot-env
...    u-boot-scripts
...    ua-cli
...    upgrade-mgr
...    validate
...    validate-types
...    lan-mgr
...    wcat
...    xmlify
Force Tags        @feature=Diagnostics    @subFeature=E7-2 and card diagnostics    @author=cindy gao
Resource          ./base.robot


*** Variables ***
${manager}   dmd 
${shellscript}     discovery-mgr.sh


*** Test Cases ***
tc_ARC_ARC_manager_monitor_discovery_mgr
    [Documentation]    1	from linux issue the command: dcli arcmgrd dump summary	Summary should contain the list of managers listed in title
    [Tags]       @author=clakshma    @tcid=AXOS_E72_PARENT-TC-2094
    [Setup]      AXOS_E72_PARENT-TC-2094 setup
    log    STEP:1 from linux issue the command: dcli arcmgrd dump summary Summary should contain the list of managers listed in title

    Check ARC Registration    n1_session2    ${manager}

    # Get all ARC processes before dmd restart
    ${arcmgrs_before}    ${discmgr_before}    Get ARC process    n1_session2    Manager    ${manager}

    # Restart dmd
    Restart ARC process    n1_session2    ${manager}    ${shellscript}

    # Get all ARC processes after dmd restart
    ${arcmgrs_after}    ${discmgr_after}    Get ARC process    n1_session2    Manager    ${manager}

    # Validate all ARC processes except dmd if they are the same
    Validate ARC process    n1_session2    ${arcmgrs_before}    ${arcmgrs_after}    ${manager}

    # Validate if dmd process information has changed
    Validate ARC process restart    ${discmgr_before}     ${discmgr_after}

    # Validate if there is a restart event in event manager
    Validate ARC Restart event    n1_session1    ${manager}


*** Keywords ***
AXOS_E72_PARENT-TC-2094 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2094 setup
    cli    n1_session1    clear active event-log    \\#    30
