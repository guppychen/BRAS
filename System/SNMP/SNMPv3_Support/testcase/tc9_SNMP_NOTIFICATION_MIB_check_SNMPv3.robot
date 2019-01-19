*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc9_SNMP_NOTIFICATION_MIB_check_SNMPv3
    [Documentation]    SNMP-NOTIFICATION-MIB
    [Tags]    @author=Philar Guo    @globalid=2373816   @tcid=AXOS_E72_PARENT-TC-2726    @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    ${snmpNotifyTag}=   snmp get   n_snmp_v3    snmpNotifyTag.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyTag}
    should contain   ${snmpNotifyTag}   ${trap_host_1}

    ${snmpNotifyTag1}=   snmp get   n_snmp_v3_auth_1    snmpNotifyTag.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyTag1}
    should contain   ${snmpNotifyTag1}   ${trap_host_1}

    ${snmpNotifyTag2}=   snmp get   n_snmp_v3_auth_2    snmpNotifyTag.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyTag2}
    should contain   ${snmpNotifyTag2}   ${trap_host_1}

    ${snmpNotifyTag3}=   snmp get   n_snmp_v3_auth_priv_3    snmpNotifyTag.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyTag3}
    should contain   ${snmpNotifyTag3}   ${trap_host_1}

    ${snmpNotifyTag4}=   snmp get   n_snmp_v3_auth_priv_4    snmpNotifyTag.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyTag4}
    should contain   ${snmpNotifyTag4}   ${trap_host_1}

    ${snmpNotifyTag5}=   snmp get   n_snmp_v3_auth_priv_5    snmpNotifyTag.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyTag5}
    should contain   ${snmpNotifyTag5}   ${trap_host_1}

    ${snmpNotifyTag6}=   snmp get   n_snmp_v3_auth_priv_6    snmpNotifyTag.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyTag6}
    should contain   ${snmpNotifyTag6}   ${trap_host_1}


    ${snmpNotifyType}=   snmp get   n_snmp_v3    snmpNotifyType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyType}
    should contain   ${snmpNotifyType}   inform

    ${snmpNotifyType1}=   snmp get   n_snmp_v3_auth_1    snmpNotifyType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyType1}
    should contain   ${snmpNotifyType1}   inform

    ${snmpNotifyType2}=   snmp get   n_snmp_v3_auth_2    snmpNotifyType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyType2}
    should contain   ${snmpNotifyType2}   inform

    ${snmpNotifyType3}=   snmp get   n_snmp_v3_auth_priv_3    snmpNotifyType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyType3}
    should contain   ${snmpNotifyType3}   inform

    ${snmpNotifyType4}=   snmp get   n_snmp_v3_auth_priv_4    snmpNotifyType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyType4}
    should contain   ${snmpNotifyType4}   inform

    ${snmpNotifyType5}=   snmp get   n_snmp_v3_auth_priv_5    snmpNotifyType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyType5}
    should contain   ${snmpNotifyType5}   inform

    ${snmpNotifyType6}=   snmp get   n_snmp_v3_auth_priv_6    snmpNotifyType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyType6}
    should contain   ${snmpNotifyType6}   inform


    ${snmpNotifyStorageType}=   snmp get   n_snmp_v3    snmpNotifyStorageType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyStorageType}
    should contain   ${snmpNotifyStorageType}   nonVolatile

    ${snmpNotifyStorageType1}=   snmp get   n_snmp_v3_auth_1    snmpNotifyStorageType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyStorageType1}
    should contain   ${snmpNotifyStorageType1}   nonVolatile

    ${snmpNotifyStorageType2}=   snmp get   n_snmp_v3_auth_2    snmpNotifyStorageType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyStorageType2}
    should contain   ${snmpNotifyStorageType2}   nonVolatile

    ${snmpNotifyStorageType3}=   snmp get   n_snmp_v3_auth_priv_3    snmpNotifyStorageType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyStorageType3}
    should contain   ${snmpNotifyStorageType3}   nonVolatile

    ${snmpNotifyStorageType4}=   snmp get   n_snmp_v3_auth_priv_4    snmpNotifyStorageType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyStorageType4}
    should contain   ${snmpNotifyStorageType4}   nonVolatile

    ${snmpNotifyStorageType5}=   snmp get   n_snmp_v3_auth_priv_5    snmpNotifyStorageType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyStorageType5}
    should contain   ${snmpNotifyStorageType5}   nonVolatile

    ${snmpNotifyStorageType6}=   snmp get   n_snmp_v3_auth_priv_6    snmpNotifyStorageType.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyStorageType6}
    should contain   ${snmpNotifyStorageType6}   nonVolatile


    ${snmpNotifyRowStatus}=   snmp get   n_snmp_v3    snmpNotifyRowStatus.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyRowStatus}
    should contain   ${snmpNotifyRowStatus}   active

    ${snmpNotifyRowStatus1}=   snmp get   n_snmp_v3_auth_1    snmpNotifyRowStatus.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyRowStatus1}
    should contain   ${snmpNotifyRowStatus1}   active

    ${snmpNotifyRowStatus2}=   snmp get   n_snmp_v3_auth_2    snmpNotifyRowStatus.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyRowStatus2}
    should contain   ${snmpNotifyRowStatus2}   active

    ${snmpNotifyRowStatus3}=   snmp get   n_snmp_v3_auth_priv_3    snmpNotifyRowStatus.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyRowStatus3}
    should contain   ${snmpNotifyRowStatus3}   active

    ${snmpNotifyRowStatus4}=   snmp get   n_snmp_v3_auth_priv_4    snmpNotifyRowStatus.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyRowStatus4}
    should contain   ${snmpNotifyRowStatus4}   active

    ${snmpNotifyRowStatus5}=   snmp get   n_snmp_v3_auth_priv_5    snmpNotifyRowStatus.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyRowStatus5}
    should contain   ${snmpNotifyRowStatus5}   active

    ${snmpNotifyRowStatus6}=   snmp get   n_snmp_v3_auth_priv_6    snmpNotifyRowStatus.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyRowStatus6}
    should contain   ${snmpNotifyRowStatus6}   active


    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    prov_snmpv3_trap_host   eutA   ${trap_host_1}   ${SNMPv3_user_auth_priv_3}   authPriv   inform   3    300



case teardown
    log    Enter case teardown
    delete_snmpv3_trap_host   eutA   ${trap_host_1}   ${SNMPv3_user_auth_priv_3}
