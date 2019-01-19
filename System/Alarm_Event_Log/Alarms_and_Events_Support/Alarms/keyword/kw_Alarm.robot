*** Settings ***
Documentation    Alarms keyword lib


*** Keywords ***
upgrade_cancel
    [Arguments]    ${session}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${session}    upgrade cancel    timeout_exception=0     prompt=#

SNMP_start_trap
    [Arguments]    ${device}      ${port}
    [Documentation]    SNMP start trap
    [Tags]    @author=Shesha Chandra
    Snmp Start Trap Host    ${device}   ${port}

SNMP_stop_trap
    [Arguments]    ${device}
    [Documentation]    SNMP stop trap
    [Tags]    @author=Shesha Chandra
    # Sleep for 30 seconds
    sleep    30s
    snmp stop trap host    ${device}

SNMP_v2_setup
    [Arguments]    ${device}
    [Documentation]    Configure the SNMP v2 profile
    [Tags]    @author=Shesha Chandra
    #${trap_host}    Run    ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    cli  n1_session1  configure
    cli  n1_session1  snmp
    #cli  n1_session1  v2 admin-state enable   timeout_exception=0    prompt=#
    cli  n1_session1  v2 admin-state enable
    sleep    30s
    cli  n1_session1  v2 community shesha ro
    cli  n1_session1  v2 trap-host ${serverIp.vm_addr} shesha
    cli  n1_session1  end

SNMP_v2_teardown
    [Arguments]    ${device}
    [Documentation]    Remove the SNMP v2 profile
    [Tags]    @author=Shesha Chandra
    cli  n1_session1  configure
    cli  n1_session1  snmp
    cli  n1_session1  v2 admin-state disable    timeout=10    prompt=#
    cli  n1_session1  no v2 trap-host ${serverIp.vm_addr} shesha
	cli  n1_session1  no v2 community shesha ro
    cli  n1_session1  end

Syslog logging-host-creation
    [Arguments]    ${device}    ${Addr}
    [Documentation]    Creating the logging-host
    [Tags]    @author=Shesha Chandra
    Cli    ${device}    logging host ${Addr}
    Cli    ${device}    exit

Generate_Alarm_General
    [Arguments]    ${DUT}
    [Documentation]    Generate the Alarms in GENERAL catregory.
	[Tags]    @author=Shesha Chandra
    command    ${DUT}    dcli evtmgrd evtpost application-fpga-failure CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost audit-trail-transmit-fail CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost auto-prov-alarm CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost diagnostic CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost ethernet-rmon-session-stopped CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost image_verification_failure CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost insufficient-physical-memory CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost lag-rmon-pmdata-cleared CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost lag-rmon-session-stopped CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost line-internal-hw-fault CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-asc25mhz CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-bits-out CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-core CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-fpga125mhz CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-osc25mhz CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-out-10mhz CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost om-fpga-failure CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost om-fpga-ver-mismatch CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost pkt-queue-work-overrun CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost poe-hardware-failure CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost receive-dropped CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost skb-ingress-pkt-queue-drops CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost standby-image-loaded CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost system-fpga-version-mismatch CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost system-monitor-failure CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost system-monitor-firmware-failure CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost system-monitor-ver-mismatch CRITICAL
    command    ${DUT}    dcli evtmgrd evtpost wifi-usb-device-timer-expired CRITICAL

Verify_Alarm_General
    [Arguments]    ${alarm_active}
    [Documentation]    Generate the Alarms.
	[Tags]    @author=Shesha Chandra
	should contain    ${alarm_active}    application-fpga-failure
#    should contain    ${alarm_active}    audit-trail-transmit-fail
    should contain    ${alarm_active}    auto-prov-alarm
    should contain    ${alarm_active}    diagnostic
    should contain    ${alarm_active}    ethernet-rmon-session-stopped
    should contain    ${alarm_active}    image_verification_failure
    should contain    ${alarm_active}    insufficient-physical-memory
    log    delete by EXA-16159
    #should contain    ${alarm_active}    lag-rmon-pmdata-cleared
    should contain    ${alarm_active}    lag-rmon-session-stopped
    should contain    ${alarm_active}    line-internal-hw-fault
    #should contain    ${alarm_active}    ntwkclk-fault-asc25mhz
    #should contain    ${alarm_active}    ntwkclk-fault-bits-out
    #should contain    ${alarm_active}    ntwkclk-fault-core
    #should contain    ${alarm_active}    ntwkclk-fault-fpga125mhz
    #should contain    ${alarm_active}    ntwkclk-fault-osc25mhz
    #should contain    ${alarm_active}    ntwkclk-fault-out-10mhz
    should contain    ${alarm_active}    om-fpga-failure
    should contain    ${alarm_active}    om-fpga-ver-mismatch
    should contain    ${alarm_active}    pkt-queue-work-overrun
    should contain    ${alarm_active}    poe-hardware-failure
    should contain    ${alarm_active}    receive-dropped
    should contain    ${alarm_active}    skb-ingress-pkt-queue-drops
    should contain    ${alarm_active}    standby-image-loaded
    should contain    ${alarm_active}    system-fpga-version-mismatch
    should contain    ${alarm_active}    system-monitor-failure
    should contain    ${alarm_active}    system-monitor-firmware-failure
    should contain    ${alarm_active}    system-monitor-ver-mismatch

Clear_Alarm_General
    [Arguments]    ${DUT}
    [Documentation]    Clear the Alarms.
	[Tags]    @author=Shesha Chandra
	command    ${DUT}    end
	command    ${DUT}    exit
    command    ${DUT}    dcli evtmgrd evtpost application-fpga-failure CLEAR
    command    ${DUT}    dcli evtmgrd evtpost audit-trail-transmit-fail CLEAR
    command    ${DUT}    dcli evtmgrd evtpost auto-prov-alarm CLEAR
    command    ${DUT}    dcli evtmgrd evtpost diagnostic CLEAR
    command    ${DUT}    dcli evtmgrd evtpost ethernet-rmon-session-stopped CLEAR
    command    ${DUT}    dcli evtmgrd evtpost image_verification_failure CLEAR
    command    ${DUT}    dcli evtmgrd evtpost insufficient-physical-memory CLEAR
    command    ${DUT}    dcli evtmgrd evtpost lag-rmon-pmdata-cleared CLEAR
    command    ${DUT}    dcli evtmgrd evtpost lag-rmon-session-stopped CLEAR
    command    ${DUT}    dcli evtmgrd evtpost line-internal-hw-fault CLEAR
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-asc25mhz CLEAR
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-bits-out CLEAR
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-core CLEAR
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-fpga125mhz CLEAR
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-osc25mhz CLEAR
    command    ${DUT}    dcli evtmgrd evtpost ntwkclk-fault-out-10mhz CLEAR
    command    ${DUT}    dcli evtmgrd evtpost om-fpga-failure CLEAR
    command    ${DUT}    dcli evtmgrd evtpost om-fpga-ver-mismatch CLEAR
    command    ${DUT}    dcli evtmgrd evtpost pkt-queue-work-overrun CLEAR
    command    ${DUT}    dcli evtmgrd evtpost poe-hardware-failure CLEAR
    command    ${DUT}    dcli evtmgrd evtpost receive-dropped CLEAR
    command    ${DUT}    dcli evtmgrd evtpost skb-ingress-pkt-queue-drops CLEAR
    command    ${DUT}    dcli evtmgrd evtpost standby-image-loaded CLEAR
    command    ${DUT}    dcli evtmgrd evtpost system-fpga-version-mismatch CLEAR
    command    ${DUT}    dcli evtmgrd evtpost system-monitor-failure CLEAR
    command    ${DUT}    dcli evtmgrd evtpost system-monitor-firmware-failure CLEAR
    command    ${DUT}    dcli evtmgrd evtpost system-monitor-ver-mismatch CLEAR
    command    ${DUT}    dcli evtmgrd evtpost wifi-usb-device-timer-expired CLEAR

check_update_statue
    [Arguments]    ${DUT}
    [Documentation]    check update statue
	[Tags]    @author=cachen
    ${upgrade}=    command    ${DUT}    show upgrade status
    #get the status of the image upgrade
    ${line}=    Get Lines Containing String    ${upgrade}    state
    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    should contain    ${string}   Reload required to finish activation

