*** Settings ***
Documentation     The EXA device must support SNMPv2c as defined in:
...
...               RFC 1901. Introduction to Community-based SNMPv2
...
...               RFC 3416. Version 2 of SNMP Protocol Operations
...
...               RFC 3417. Transport Mappings
...
...               ==============================================
...
...               For co-existence with SNMPv2c, we also implement RFC3584 - SNMP-COMMUNITY-MIB which contains objects for mapping between community strings and SNMPv3
...
...               SnmpCommunityTable
...
...               SNMPCommuityName CommunityName SecurityName ContextEngine ContextName TransportTag StorageType RowStatus
...
...               community1 public bob group 1 nonVolatile(3) active(1)
...
...               community2 private tim group 2 nonVolatile(3) active(1)
...
...               SnmpTargetAddTable
...
...               TargetAddrName AddrTDomain AddrTAddress AddrTimeout AddrRetryCount TagList AddrParams StorageType RowStatus
...
...               addr1 .1.3.6.1.6.1.1 1500 3 group 1 params nonVolatile(3) active(1)
...
...               group 2
...
...               Purpose
...               ========
...
...               Verify the SNMPCommunity table information is correct.
Force Tags     @author=upandiri    @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot

*** Variables ***
${community_username1}    snmpv2user1
${community_username2}    snmpv2user2
${admin_state}    enable

*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPv2_SNMPMIB_SNMPCommunityMIB_SNMPCommunityTable
    [Documentation]    1 Configure multiple SNMP v2 users. Config is added in CLI. v2 community name ro    #    Action    Expected Result    Notes
    ...    2 Verify the SNMP community table shows all users from SNMP. SNMP shows all users. snmptable -Cb -Ci -v 2c -c name x.x.x.x snmpcommunitytable
    ...    3 Remove SNMP v2 user and verify it no longer shows the entry in the community table. Entry is no longer shown from CLI or SNMP.
    [Tags]    @author=upandiri    @TCID=AXOS_E72_PARENT-TC-1709

    log    STEP:1 Configure multiple SNMP v2 users. Config is added in CLI. v2 community name ro
    Configure SNMPv2    n1_session1    ${admin_state}    ${community_username1}
    Configure SNMPv2    n1_session1    ${admin_state}    ${community_username2}

    log    STEP:2 Verify the SNMP community table shows all users from SNMP. SNMP shows all users. snmptable -Cb -Ci -v 2c -c name x.x.x.x snmpcommunitytable
    ${conn}=    Session copy info    n_snmp_v2    community=${community_username1}
    Session build local    n1_localsession1    ${conn}

    @{result}    snmp walk    n1_localsession1    snmpCommunityName
    ${result1}    get from list  ${result}  0
    Should Contain  ${result1}  ${community_username1}
    ${result2}    get from list  ${result}  1
    Should Contain  ${result2}  ${community_username2}

    log    STEP:3 Remove SNMP v2 user and verify it no longer shows the entry in the community table. Entry is no longer shown from CLI or SNMP.
    Remove SNMPv2    n1_session1    ${admin_state}    ${community_username1}

    ${conn}=    Session copy info    n_snmp_v2    community=${community_username2}
    Session build local    n1_localsession2    ${conn}

    ${result1}    snmp walk    n1_localsession2    snmpCommunityName
    Result Should Not Contain    ${community_username1}

    [Teardown]    AXOS_E72_PARENT-TC-1709 teardown

*** Keywords ***

AXOS_E72_PARENT-TC-1709 teardown
    [Documentation]    Enter AXOS_E72_PARENT-TC-1709 teardown

    # Removing local session
    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2	

    # Remove SNMP users
    Remove SNMPv2    n1_session1    ${admin_state}    ${community_username1}
    Remove SNMPv2    n1_session1    ${admin_state}    ${community_username2}
    

