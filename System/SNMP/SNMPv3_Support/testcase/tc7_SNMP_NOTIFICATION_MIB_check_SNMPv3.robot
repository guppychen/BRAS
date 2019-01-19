*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc6_SNMP_NOTIFICATION_MIB_check_SNMPv3
    [Documentation]    SNMP-NOTIFICATION-MIB
    [Tags]    @author=Philar Guo    @globalid=2373814   @tcid=AXOS_E72_PARENT-TC-2724
      ...   @jira=EXA-21015      @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    ${snmpNotifyName}=   snmp get   n_snmp_v3    snmpNotifyName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyName}
    should not be empty   ${snmpNotifyName}   

    ${snmpNotifyName1}=   snmp get   n_snmp_v3_auth_1    snmpNotifyName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyName1}
    should not be empty   ${snmpNotifyName1}   

    ${snmpNotifyName2}=   snmp get   n_snmp_v3_auth_2    snmpNotifyName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyName2}
    should not be empty   ${snmpNotifyName2}   

    ${snmpNotifyName3}=   snmp get   n_snmp_v3_auth_priv_3    snmpNotifyName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyName3}
    should not be empty   ${snmpNotifyName3}   

    ${snmpNotifyName4}=   snmp get   n_snmp_v3_auth_priv_4    snmpNotifyName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyName4}
    should not be empty   ${snmpNotifyName4}   

    ${snmpNotifyName5}=   snmp get   n_snmp_v3_auth_priv_5    snmpNotifyName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyName5}
    should not be empty   ${snmpNotifyName5}   

    ${snmpNotifyName6}=   snmp get   n_snmp_v3_auth_priv_6    snmpNotifyName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyName6}
    should not be empty   ${snmpNotifyName6}   


    ${snmpNotifyFilterSubtree}=   snmp get   n_snmp_v3    snmpNotifyFilterSubtree.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterSubtree}
    should not be empty   ${snmpNotifyFilterSubtree}  

    ${snmpNotifyFilterSubtree1}=   snmp get   n_snmp_v3_auth_1    snmpNotifyFilterSubtree.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterSubtree1}
    should not be empty   ${snmpNotifyFilterSubtree1}  

    ${snmpNotifyFilterSubtree2}=   snmp get   n_snmp_v3_auth_2    snmpNotifyFilterSubtree.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterSubtree2}
    should not be empty   ${snmpNotifyFilterSubtree2}  

    ${snmpNotifyFilterSubtree3}=   snmp get   n_snmp_v3_auth_priv_3    snmpNotifyFilterSubtree.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterSubtree3}
    should not be empty   ${snmpNotifyFilterSubtree3}  

    ${snmpNotifyFilterSubtree4}=   snmp get   n_snmp_v3_auth_priv_4    snmpNotifyFilterSubtree.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterSubtree4}
    should not be empty   ${snmpNotifyFilterSubtree4}  

    ${snmpNotifyFilterSubtree5}=   snmp get   n_snmp_v3_auth_priv_5    snmpNotifyFilterSubtree.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterSubtree5}
    should not be empty   ${snmpNotifyFilterSubtree5}  

    ${snmpNotifyFilterSubtree6}=   snmp get   n_snmp_v3_auth_priv_6    snmpNotifyFilterSubtree.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterSubtree6}
    should not be empty   ${snmpNotifyFilterSubtree6}  


    ${snmpNotifyFilterProfileName}=   snmp get   n_snmp_v3    snmpNotifyFilterProfileName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterProfileName}
    should not be empty   ${snmpNotifyFilterProfileName}   

    ${snmpNotifyFilterProfileName1}=   snmp get   n_snmp_v3_auth_1    snmpNotifyFilterProfileName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterProfileName1}
    should not be empty   ${snmpNotifyFilterProfileName1}   

    ${snmpNotifyFilterProfileName2}=   snmp get   n_snmp_v3_auth_2    snmpNotifyFilterProfileName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterProfileName2}
    should not be empty   ${snmpNotifyFilterProfileName2}   

    ${snmpNotifyFilterProfileName3}=   snmp get   n_snmp_v3_auth_priv_3    snmpNotifyFilterProfileName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterProfileName3}
    should not be empty   ${snmpNotifyFilterProfileName3}   

    ${snmpNotifyFilterProfileName4}=   snmp get   n_snmp_v3_auth_priv_4    snmpNotifyFilterProfileName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterProfileName4}
    should not be empty   ${snmpNotifyFilterProfileName4}   

    ${snmpNotifyFilterProfileName5}=   snmp get   n_snmp_v3_auth_priv_5    snmpNotifyFilterProfileName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterProfileName5}
    should not be empty   ${snmpNotifyFilterProfileName5}   

    ${snmpNotifyFilterProfileName6}=   snmp get   n_snmp_v3_auth_priv_6    snmpNotifyFilterProfileName.49.51.46.49.48.46.50.52.53.46.51.49.46.49.54.54
    log   ${snmpNotifyFilterProfileName6}
    should not be empty   ${snmpNotifyFilterProfileName6}

    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    prov_snmpv3_trap_host   eutA   ${trap_host_1}   ${SNMPv3_user_auth_priv_3}   authPriv   inform   3    300



case teardown
    log    Enter case teardown
    delete_snmpv3_trap_host   eutA   ${trap_host_1}    ${SNMPv3_user_auth_priv_3}
