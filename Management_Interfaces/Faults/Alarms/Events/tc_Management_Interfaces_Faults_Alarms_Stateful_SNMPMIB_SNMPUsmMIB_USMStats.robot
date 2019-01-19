*** Settings ***
Documentation     The EXA device must support SNMPv2c as defined in:
...        RFC 1901. Introduction to Community-based SNMPv2
...        RFC 3416. Version 2 of SNMP Protocol Operations
...        RFC 3417. Transport Mappings
...    =============================
...    Per rfc 3414
...     usmStats OBJECT IDENTIFIER ::= { usmMIBObjects 1 }
...    usmStatsUnsupportedSecLevels OBJECT-TYPE  SYNTAX Counter32  MAX-ACCESS read-only  STATUS current  DESCRIPTION "The total number of packets received by the SNMP  engine which were dropped because they requested a  securityLevel that was unknown to the SNMP engine  or otherwise unavailable.
...     "
...     ::= { usmStats 1 }
...    
...    usmStatsNotInTimeWindows OBJECT-TYPE
...     SYNTAX Counter32
...     MAX-ACCESS read-only
...     STATUS current
...     DESCRIPTION "The total number of packets received by the SNMP  engine which were dropped because they appeared  outside of the authoritative SNMP engine's window.
...     "
...     ::= { usmStats 2 }
...    
...    usmStatsUnknownUserNames OBJECT-TYPE
...     SYNTAX Counter32
...     MAX-ACCESS read-only
...     STATUS current
...     DESCRIPTION "The total number of packets received by the SNMP  engine which were dropped because they referenced a  user that was not known to the SNMP engine.
...     "
...     ::= { usmStats 3 }
...    
...    usmStatsUnknownEngineIDs OBJECT-TYPE
...     SYNTAX Counter32
...     MAX-ACCESS read-only
...     STATUS current
...    
...     DESCRIPTION "The total number of packets received by the SNMP  engine which were dropped because they referenced an  snmpEngineID that was not known to the SNMP engine.
...     "
...     ::= { usmStats 4 }
...    usmStatsWrongDigests OBJECT-TYPE
...     SYNTAX Counter32
...     MAX-ACCESS read-only
...     STATUS current
...     DESCRIPTION "The total number of packets received by the SNMP  engine which were dropped because they didn't  contain the expected digest value.
...     "
...     ::= { usmStats 5 }
...    
...    usmStatsDecryptionErrors OBJECT-TYPE
...     SYNTAX Counter32
...     MAX-ACCESS read-only
...     STATUS current
...     DESCRIPTION "The total number of packets received by the SNMP  engine which were dropped because they could not be  decrypted.
...     "
...     ::= { usmStats 6 } ​"
...    
...    ===============================================
...    Purpose
...    ========
...    
...    Verify the USMStats are correct in the SNMPUSMMIB.
...     
Force Tags     @author=gpalanis   @feature=SNMP   @subfeature=SNMP Support
Resource       ./base.robot


*** Variables ***
${username1}    snmp_user 
${encryption_protocol}     AES
${auth_protocol}   MD5
${auth_key}      snmp_user123
${encryption_key}      snmp_user456
${trap_host_ip1}    1.1.1.1 

*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPMIB_SNMPUsmMIB_USMStats
    [Documentation]    Configure various snmp users and traphosts via the cli, and verify the information in the USMStats.
    [Tags]       @author=gpalanis    @TCID=AXOS_E72_PARENT-TC-1707
    [Teardown]   AXOS_E72_PARENT-TC-1707 teardown

    # Retrieve Machine IP as trap host IP
    ${ip_addr}    Run    ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    
    # Configure first SNMP user 
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${DEVICES.n_snmp_v3.authentication_protocol}   
    ...     ${DEVICES.n_snmp_v3.password}    ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}

    # Configuring trap host
    Configure V3 trap    n1_session1    ${ip_addr}    ${DEVICES.n_snmp_v3.username}
    ...    trap-type=${trap_type}    retries=${retries}    timeout=${timeout}    security-level=${security_level}

    # Configuring SNMPv3 user
    Configure SNMPv3    n1_session1    ${admin_state}    ${username1}   ${auth_protocol}   
    ...    ${auth_key}    ${encryption_protocol}    ${encryption_key}
	
    # Configuring trap host for username1
    Configure V3 trap    n1_session1    ${trap_host_ip1}    ${username1}
    ...    trap-type=${trap_type}    retries=${retries}    timeout=${timeout}    security-level=${security_level}
 
    cli     n1_session1    show running-config snmp v3 | tab   prompt=#   timeout=30

    # Check the values from table separately also
    ${result}    snmp get   n_snmp_v3   usmStatsNotInTimeWindows
    ${result}    snmp get   n_snmp_v3   usmStatsUnknownUserNames
    ${result}    snmp get   n_snmp_v3   usmStatsUnknownEngineIDs
    ${result}    snmp get   n_snmp_v3   usmStatsWrongDigests
    ${result}    snmp get   n_snmp_v3   usmStatsDecryptionErrors


*** Keywords ***
AXOS_E72_PARENT-TC-1707 teardown
    [Documentation]    Entering Teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1707 teardown

    # Retrieve Machine IP as trap host IP
    ${ip_addr}    Run    ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'

    # Removing trap host
    Remove V3 trap    n1_session1    ${ip_addr}    ${DEVICES.n_snmp_v3.username}
    Remove V3 trap    n1_session1    ${trap_host_ip1}    ${username1}
	
    # Removing SNMP user
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
    Remove SNMPv3    n1_session1    ${admin_state}    ${username1}
