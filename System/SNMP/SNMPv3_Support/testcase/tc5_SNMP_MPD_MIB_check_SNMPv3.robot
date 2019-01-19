*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc5_SNMP_MPD_MIB_check_SNMPv3
    [Documentation]    SNMP-MPD-MIB
    [Tags]    @author=Philar Guo    @globalid=2373812   @tcid=AXOS_E72_PARENT-TC-2722   @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup

    ${snmpUnknownSecurityModels}=   snmp get   n_snmp_v3    snmpUnknownSecurityModels
    log   ${snmpUnknownSecurityModels}
    should not be empty   ${snmpUnknownSecurityModels}

    ${snmpUnknownSecurityModels1}=   snmp get   n_snmp_v3_auth_1    snmpUnknownSecurityModels
    log   ${snmpUnknownSecurityModels1}
    should not be empty   ${snmpUnknownSecurityModels1}

    ${snmpUnknownSecurityModels2}=   snmp get   n_snmp_v3_auth_2    snmpUnknownSecurityModels
    log   ${snmpUnknownSecurityModels2}
    should not be empty   ${snmpUnknownSecurityModels2}

    ${snmpUnknownSecurityModels3}=   snmp get   n_snmp_v3_auth_priv_3    snmpUnknownSecurityModels
    log   ${snmpUnknownSecurityModels3}
    should not be empty   ${snmpUnknownSecurityModels3}

    ${snmpUnknownSecurityModels4}=   snmp get   n_snmp_v3_auth_priv_4    snmpUnknownSecurityModels
    log   ${snmpUnknownSecurityModels4}
    should not be empty   ${snmpUnknownSecurityModels4}

    ${snmpUnknownSecurityModels5}=   snmp get   n_snmp_v3_auth_priv_5    snmpUnknownSecurityModels
    log   ${snmpUnknownSecurityModels5}
    should not be empty   ${snmpUnknownSecurityModels5}

    ${snmpUnknownSecurityModels6}=   snmp get   n_snmp_v3_auth_priv_6    snmpUnknownSecurityModels
    log   ${snmpUnknownSecurityModels6}
    should not be empty   ${snmpUnknownSecurityModels6}


    ${snmpInvalidMsgs}=   snmp get   n_snmp_v3    snmpInvalidMsgs
    log   ${snmpInvalidMsgs}
    should not be empty   ${snmpInvalidMsgs}

    ${snmpInvalidMsgs1}=   snmp get   n_snmp_v3_auth_1    snmpInvalidMsgs
    log   ${snmpInvalidMsgs1}
    should not be empty   ${snmpInvalidMsgs1}

    ${snmpInvalidMsgs2}=   snmp get   n_snmp_v3_auth_2    snmpInvalidMsgs
    log   ${snmpInvalidMsgs2}
    should not be empty   ${snmpInvalidMsgs2}

    ${snmpInvalidMsgs3}=   snmp get   n_snmp_v3_auth_priv_3    snmpInvalidMsgs
    log   ${snmpInvalidMsgs3}
    should not be empty   ${snmpInvalidMsgs3}

    ${snmpInvalidMsgs4}=   snmp get   n_snmp_v3_auth_priv_4    snmpInvalidMsgs
    log   ${snmpInvalidMsgs4}
    should not be empty   ${snmpInvalidMsgs4}

    ${snmpInvalidMsgs5}=   snmp get   n_snmp_v3_auth_priv_5    snmpInvalidMsgs
    log   ${snmpInvalidMsgs5}
    should not be empty   ${snmpInvalidMsgs5}

    ${snmpInvalidMsgs6}=   snmp get   n_snmp_v3_auth_priv_6    snmpInvalidMsgs
    log   ${snmpInvalidMsgs6}
    should not be empty   ${snmpInvalidMsgs6}



    ${snmpUnknownPDUHandlers}=   snmp get   n_snmp_v3    snmpUnknownPDUHandlers
    log   ${snmpUnknownPDUHandlers}
    should not be empty   ${snmpUnknownPDUHandlers}

    ${snmpUnknownPDUHandlers1}=   snmp get   n_snmp_v3_auth_1    snmpUnknownPDUHandlers
    log   ${snmpUnknownPDUHandlers1}
    should not be empty   ${snmpUnknownPDUHandlers1}

    ${snmpUnknownPDUHandlers2}=   snmp get   n_snmp_v3_auth_2    snmpUnknownPDUHandlers
    log   ${snmpUnknownPDUHandlers2}
    should not be empty   ${snmpUnknownPDUHandlers2}

    ${snmpUnknownPDUHandlers3}=   snmp get   n_snmp_v3_auth_priv_3    snmpUnknownPDUHandlers
    log   ${snmpUnknownPDUHandlers3}
    should not be empty   ${snmpUnknownPDUHandlers3}

    ${snmpUnknownPDUHandlers4}=   snmp get   n_snmp_v3_auth_priv_4    snmpUnknownPDUHandlers
    log   ${snmpUnknownPDUHandlers4}
    should not be empty   ${snmpUnknownPDUHandlers4}

    ${snmpUnknownPDUHandlers5}=   snmp get   n_snmp_v3_auth_priv_5    snmpUnknownPDUHandlers
    log   ${snmpUnknownPDUHandlers5}
    should not be empty   ${snmpUnknownPDUHandlers5}

    ${snmpUnknownPDUHandlers6}=   snmp get   n_snmp_v3_auth_priv_6    snmpUnknownPDUHandlers
    log   ${snmpUnknownPDUHandlers6}
    should not be empty   ${snmpUnknownPDUHandlers6}



    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup



case teardown
    log    Enter case teardown
