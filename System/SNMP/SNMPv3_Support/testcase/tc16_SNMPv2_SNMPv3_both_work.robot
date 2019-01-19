*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc16_SNMPv2_SNMPv3_both_work
    [Documentation]    SNMPv2 and SNMPv3 both work
    [Tags]    @author=Philar Guo    @globalid=2373823    @tcid=AXOS_E72_PARENT-TC-2733   @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    ${snmpTargetSpinLock_v2}=   snmp get   n_snmp_v2    snmpTargetSpinLock
    log   ${snmpTargetSpinLock_v2}
    should be equal   ${snmpTargetSpinLock_v2}   0

    ${snmpTargetSpinLock}=   snmp get   n_snmp_v3    snmpTargetSpinLock
    log   ${snmpTargetSpinLock}
    should be equal   ${snmpTargetSpinLock}   0

    ${snmpTargetSpinLock1}=   snmp get   n_snmp_v3_auth_1    snmpTargetSpinLock
    log   ${snmpTargetSpinLock1}
    should be equal   ${snmpTargetSpinLock1}   0

    ${snmpTargetSpinLock2}=   snmp get   n_snmp_v3_auth_2    snmpTargetSpinLock
    log   ${snmpTargetSpinLock2}
    should be equal   ${snmpTargetSpinLock2}   0

    ${snmpTargetSpinLock3}=   snmp get   n_snmp_v3_auth_priv_3    snmpTargetSpinLock
    log   ${snmpTargetSpinLock3}
    should be equal   ${snmpTargetSpinLock3}   0

    ${snmpTargetSpinLock4}=   snmp get   n_snmp_v3_auth_priv_4    snmpTargetSpinLock
    log   ${snmpTargetSpinLock4}
    should be equal   ${snmpTargetSpinLock4}   0

    ${snmpTargetSpinLock5}=   snmp get   n_snmp_v3_auth_priv_5    snmpTargetSpinLock
    log   ${snmpTargetSpinLock5}
    should be equal   ${snmpTargetSpinLock5}   0

    ${snmpTargetSpinLock6}=   snmp get   n_snmp_v3_auth_priv_6    snmpTargetSpinLock
    log   ${snmpTargetSpinLock6}
    should be equal   ${snmpTargetSpinLock6}   0


    ${snmpUnavailableContexts_v2}=   snmp get   n_snmp_v2    snmpUnavailableContexts
    log   ${snmpUnavailableContexts_v2}
    should be equal   ${snmpUnavailableContexts_v2}   0

    ${snmpUnavailableContexts}=   snmp get   n_snmp_v3    snmpUnavailableContexts
    log   ${snmpUnavailableContexts}
    should be equal   ${snmpUnavailableContexts}   0

    ${snmpUnavailableContexts1}=   snmp get   n_snmp_v3_auth_1    snmpUnavailableContexts
    log   ${snmpUnavailableContexts1}
    should be equal   ${snmpUnavailableContexts1}   0

    ${snmpUnavailableContexts2}=   snmp get   n_snmp_v3_auth_2    snmpUnavailableContexts
    log   ${snmpUnavailableContexts2}
    should be equal   ${snmpUnavailableContexts2}   0

    ${snmpUnavailableContexts3}=   snmp get   n_snmp_v3_auth_priv_3    snmpUnavailableContexts
    log   ${snmpUnavailableContexts3}
    should be equal   ${snmpUnavailableContexts3}   0

    ${snmpUnavailableContexts4}=   snmp get   n_snmp_v3_auth_priv_4    snmpUnavailableContexts
    log   ${snmpUnavailableContexts4}
    should be equal   ${snmpUnavailableContexts4}   0

    ${snmpUnavailableContexts5}=   snmp get   n_snmp_v3_auth_priv_5    snmpUnavailableContexts
    log   ${snmpUnavailableContexts5}
    should be equal   ${snmpUnavailableContexts5}   0

    ${snmpUnavailableContexts6}=   snmp get   n_snmp_v3_auth_priv_6    snmpUnavailableContexts
    log   ${snmpUnavailableContexts6}
    should be equal   ${snmpUnavailableContexts6}   0


    ${snmpUnknownContexts_v2}=   snmp get   n_snmp_v2    snmpUnknownContexts
    log   ${snmpUnknownContexts_v2}
    should be equal   ${snmpUnknownContexts_v2}   0

    ${snmpUnknownContexts}=   snmp get   n_snmp_v3    snmpUnknownContexts
    log   ${snmpUnknownContexts}
    should be equal   ${snmpUnknownContexts}   0

    ${snmpUnknownContexts1}=   snmp get   n_snmp_v3_auth_1    snmpUnknownContexts
    log   ${snmpUnknownContexts1}
    should be equal   ${snmpUnknownContexts1}   0

    ${snmpUnknownContexts2}=   snmp get   n_snmp_v3_auth_2    snmpUnknownContexts
    log   ${snmpUnknownContexts2}
    should be equal   ${snmpUnknownContexts2}   0

    ${snmpUnknownContexts3}=   snmp get   n_snmp_v3_auth_priv_3    snmpUnknownContexts
    log   ${snmpUnknownContexts3}
    should be equal   ${snmpUnknownContexts3}   0

    ${snmpUnknownContexts4}=   snmp get   n_snmp_v3_auth_priv_4    snmpUnknownContexts
    log   ${snmpUnknownContexts4}
    should be equal   ${snmpUnknownContexts4}   0

    ${snmpUnknownContexts5}=   snmp get   n_snmp_v3_auth_priv_5    snmpUnknownContexts
    log   ${snmpUnknownContexts5}
    should be equal   ${snmpUnknownContexts5}   0

    ${snmpUnknownContexts6}=   snmp get   n_snmp_v3_auth_priv_6    snmpUnknownContexts
    log   ${snmpUnknownContexts6}
    should be equal   ${snmpUnknownContexts6}   0
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    cli   eutA   config
    cli   eutA   snmp
    Axos Cli With Error Check   eutA   v2 admin-state enable
    Axos Cli With Error Check   eutA   v2 community public ro




case teardown
    log    Enter case teardown
    cli   eutA   config
    cli   eutA   snmp
    Axos Cli With Error Check   eutA   no v2 admin-state
    Axos Cli With Error Check   eutA   no v2 community public ro

