*** Settings ***
Documentation     The EXA device must support SNMPv2c as defined in:
...        RFC 1901. Introduction to Community-based SNMPv2
...        RFC 3416. Version 2 of SNMP Protocol Operations
...        RFC 3417. Transport Mappings
...    Purpose
...    ========
...    Verify the information in the SNMPMPDStats are correct as well as these scalars.
...       snmpMPDStats           OBJECT IDENTIFIER ::= { snmpMPDMIBObjects 1 }
...       snmpUnknownSecurityModels OBJECT-TYPE
...           SYNTAX       Counter32
...           MAX-ACCESS   read-only
...           STATUS       current
...           DESCRIPTION "The total number of packets received by the SNMP
...                        engine which were dropped because they referenced a
...                        securityModel that was not known to or supported by
...                        the SNMP engine.
...                       "
...           ::= { snmpMPDStats 1 }
...       snmpInvalidMsgs OBJECT-TYPE
...           SYNTAX       Counter32
...           MAX-ACCESS   read-only
...           STATUS       current
...           DESCRIPTION "The total number of packets received by the SNMP
...                        engine which were dropped because there were invalid
...                        or inconsistent components in the SNMP message.
...                       "
...           ::= { snmpMPDStats 2 }
...       snmpUnknownPDUHandlers OBJECT-TYPE
...           SYNTAX       Counter32
...           MAX-ACCESS   read-only
...           STATUS       current
...           DESCRIPTION "The total number of packets received by the SNMP
...                        engine which were dropped because the PDU contained
...                        in the packet could not be passed to an application
...                        responsible for handling the pduType, e.g. no SNMP
...                        application had registered for the proper
...                        combination of the contextEngineID and the pduType.
...                       "
...           ::= { snmpMPDStats 3 }
Force Tags     @author=gpalanis   @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***
${community_public}   public
${length_max32char}   maximumlengthshouldbe32character
${length_20char}      teststringfor20chars
${length_10char}      tencharstr
@{community_string}    ${length_max32char}    ${length_20char}    ${length_10char}
${count}    2


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_snmpv3_Stateful_SNMPMIB_SNMPMPDMIB_SNMPMPDStats
    [Documentation]    1 	Check SNMP configuration on the node 	show running snmp 	 
    ...    2 	Try connect EXA agent to snmpmanager using default snmp v2 public key 	Make sure it timeds out 	 
    ...    3 	Configure multiple snmp community-ro <> v2c strings from CLI with different lengths (upto 128 characters) 	With special characters. 	Can connect to agent with each community string.
    ...    4 	Verify the information in the SNMPMPDStats and scalars above are correct. 	Information for table and scalars are correct.
    [Tags]       @author=gpalanis     @TCID=AXOS_E72_PARENT-TC-1703
    [Setup]      AXOS_E72_PARENT-TC-1703 setup
    [Teardown]   AXOS_E72_PARENT-TC-1703 teardown

    # Getting the hostname
    ${hostname}    Get hostname    n1_session1    ${device_prompt}
    ${hostname}    Strip String    ${hostname}

    # Connect EXA agent to snmpmanager using default snmp private key
    ${result}    snmp get    n_snmp_v2    sysName
    should contain    ${result}    ${hostname}

    # Check the snmp v2 configurations
    cli   n1_session1   show running-config snmp v2
    Result should contain    v2 admin-state enable

    # Configure snmp v2 with public_key
    Configure SNMPv2    n1_session1    ${admin_state}  ${community_public}

    # Creating a local session1 with  a community string as public
    ${conn}=    Session copy info     n_snmp_v2   community=${community_public}
    Session build local   n1_localsession1    ${conn}

    # Connect EXA agent to snmpmanager using default snmp v2 public key
    ${result}   snmp get    n1_localsession1    sysName
    should contain    ${result}    ${hostname}

    # Configure multiple snmp community-ro <> v2c strings from CLI with different lengths
    :FOR    ${var}    IN    @{community_string}
    \    Configure SNMPv2    n1_session1    ${admin_state}   ${var}
    \    cli   n1_session1   show running-config snmp v2
    \    Result Should Contain    ${var}
    \    ${conn}=    Session copy info     n_snmp_v2   community=${var}
    \    Session build local   n1_localsession${count}    ${conn}
    \    ${result}    snmp get    n_snmp_v2    sysName
    \    should contain    ${result}    ${hostname}
    \    ${count}    Evaluate   ${count} + 1

    # Check the values from SNMPMPDStats table
    ${result}    snmp get   n_snmp_v2   snmpUnknownSecurityModels
    ${result}    snmp get   n_snmp_v2   snmpInvalidMsgs
    ${result}    snmp get   n_snmp_v2   snmpUnknownPDUHandlers


*** Keywords ***
AXOS_E72_PARENT-TC-1703 setup
    [Documentation]    Entering Setup section
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1703 setup
    run keyword and ignore error      Session destroy local    n1_localsession1
    # Configure SNMPv2
    Configure SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}


AXOS_E72_PARENT-TC-1703 teardown
    [Documentation]    Entering teardown session
    [Arguments]

    # Remove snmp community
    :FOR    ${var}    IN    @{community_string}
    \    Remove SNMPv2       n1_session1    ${admin_state}    ${var}
    \    Result Should Not Contain    ${var}
    Remove SNMPv2       n1_session1    ${admin_state}   ${community_public}
    Remove SNMPv2       n1_session1    ${admin_state}   ${DEVICES.n_snmp_v2.community}

    # Removing local session
    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2
    Session destroy local    n1_localsession3
    Session destroy local    n1_localsession4

  
