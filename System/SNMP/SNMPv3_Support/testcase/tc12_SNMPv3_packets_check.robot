*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc12_SNMPv3_packets_check
    [Documentation]    SNMPv3 packets check
    [Tags]    @author=Philar Guo    @globalid=2373819   @tcid=AXOS_E72_PARENT-TC-2729   @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    disconnect   h1

    cli    h1   echo marino13 | sudo -S tcpdump udp port 161 -c 5 -w /tmp/snmpv3.pcap &
    # remove -i eth2 as the case need to on different VMs.

    ${snmpEngineBoots}=   snmp get   n_snmp_v3    snmpEngineBoots
    log   ${snmpEngineBoots}
    should be true   ${snmpEngineBoots}>=1

    ${snmpEngineBoots1}=   snmp get   n_snmp_v3_auth_1    snmpEngineBoots
    log   ${snmpEngineBoots1}
    should be true   ${snmpEngineBoots1}>=1

    ${snmpEngineBoots2}=   snmp get   n_snmp_v3_auth_2    snmpEngineBoots
    log   ${snmpEngineBoots2}
    should be true   ${snmpEngineBoots2}>=1

    ${snmpEngineBoots3}=   snmp get   n_snmp_v3_auth_priv_3    snmpEngineBoots
    log   ${snmpEngineBoots3}
    should be true   ${snmpEngineBoots3}>=1

    ${snmpEngineBoots4}=   snmp get   n_snmp_v3_auth_priv_4    snmpEngineBoots
    log   ${snmpEngineBoots4}
    should be true   ${snmpEngineBoots4}>=1

    ${snmpEngineBoots5}=   snmp get   n_snmp_v3_auth_priv_5    snmpEngineBoots
    log   ${snmpEngineBoots5}
    should be true   ${snmpEngineBoots5}>=1

    ${snmpEngineBoots6}=   snmp get   n_snmp_v3_auth_priv_6    snmpEngineBoots
    log   ${snmpEngineBoots6}
    should be true   ${snmpEngineBoots6}>=1
    sleep  15s
    cli  h1   ll /tmp/
    cli  h1  echo marino13 | sudo chmod 777 /tmp/snmpv3.pcap
    wsk Load File    /tmp/snmpv3.pcap    udp.srcport==161
    Wsk Verify Udp Src Port   ${161}

    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup


case teardown
    log    Enter case teardown
    cli    h1   rm -rf /tmp/snmpv3.pcap
    ${result}    cli    h1    cat /tmp/snmpv3.pcap
    should contain    ${result}    No such
