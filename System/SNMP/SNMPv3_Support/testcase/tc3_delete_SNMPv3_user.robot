*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc3_delete_SNMPv3_user
    [Documentation]    Delete SNMPv3 user
    [Tags]    @author=Philar Guo    @globalid=2373810    @tcid=AXOS_E72_PARENT-TC-2720    @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup



    ${result}    cli    eutA    show run snmp v3
    should not contain    ${result}    v3 user    ${SNMPv3_user}
    should not contain    ${result}    v3 user    ${SNMPv3_user_auth_1}
    should not contain    ${result}    v3 user    ${SNMPv3_user_auth_2}
    should not contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_3}
    should not contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_4}
    should not contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_5}
    should not contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_6}




    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    delete_snmpv3_user    eutA    ${SNMPv3_user}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_1}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_2}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_3}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_4}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_5}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_6}


case teardown
    log    Enter case teardown
    prov_snmpv3_user    eutA    ${SNMPv3_user}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_1}   MD5   ${auth_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_2}   SHA   ${auth_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_3}   MD5   ${auth_key}   AES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_4}   MD5   ${auth_key}   DES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_5}   SHA   ${auth_key}   AES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_6}   SHA   ${auth_key}   DES   ${priv_key}