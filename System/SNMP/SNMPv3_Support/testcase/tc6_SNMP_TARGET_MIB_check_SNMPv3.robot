*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc6_SNMP_TARGET_MIB_check_SNMPv3
    [Documentation]    SNMP-TARGET-MIB
    [Tags]    @author=Philar Guo    @globalid=2373813   @tcid=AXOS_E72_PARENT-TC-2723    @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
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

case teardown
    log    Enter case teardown
