*** Settings ***
Resource          ./base.robot

*** Variables ***
*** Test Cases ***
tc8_SNMP_Proxy_MIB_check_SNMPv3
    [Documentation]    SNMP-Proxy-MIB
    [Tags]    @author=Philar Guo    @globalid=2373815    @tcid=AXOS_E72_PARENT-TC-2725   @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    ${snmpProxyName}=   snmp get   n_snmp_v3    snmpProxyName
    log   ${snmpProxyName}
    should be equal    ${snmpProxyName}   ${smmp get empty response}

    ${snmpProxyName1}=   snmp get   n_snmp_v3_auth_1    snmpProxyName
    log   ${snmpProxyName1}
    should be equal    ${snmpProxyName}   ${smmp get empty response}

    ${snmpProxyName2}=   snmp get   n_snmp_v3_auth_2    snmpProxyName
    log   ${snmpProxyName2}
    should be equal    ${snmpProxyName}   ${smmp get empty response}

    ${snmpProxyName3}=   snmp get   n_snmp_v3_auth_priv_3    snmpProxyName
    log   ${snmpProxyName3}
    should be equal    ${snmpProxyName}   ${smmp get empty response}

    ${snmpProxyName4}=   snmp get   n_snmp_v3_auth_priv_4    snmpProxyName
    log   ${snmpProxyName4}
    should be equal    ${snmpProxyName}   ${smmp get empty response}

    ${snmpProxyName5}=   snmp get   n_snmp_v3_auth_priv_5    snmpProxyName
    log   ${snmpProxyName5}
    should be equal    ${snmpProxyName}   ${smmp get empty response}

    ${snmpProxyName6}=   snmp get   n_snmp_v3_auth_priv_6    snmpProxyName
    log   ${snmpProxyName6}
    should be equal    ${snmpProxyName}   ${smmp get empty response}

    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown
