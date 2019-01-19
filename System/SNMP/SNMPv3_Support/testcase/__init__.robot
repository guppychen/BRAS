*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       SNMPv3_Support_suite_provision
Suite Teardown    SNMPv3_Support_suite_deprovision
Force Tags        @feature=SNMP    @subfeature=SNMPv3_Support     @eut=NGPON2-4    @author=PhilarGuo   @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
SNMPv3_Support_suite_provision
    [Documentation]    suite provision for SNMPv3_Support
    log    suite provision for SNMPv3_Support
    snmpv3_admin   eutA    enable
    prov_snmpv3_user    eutA    ${SNMPv3_user}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_1}   MD5   ${auth_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_2}   SHA   ${auth_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_3}   MD5   ${auth_key}   AES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_4}   MD5   ${auth_key}   DES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_5}   SHA   ${auth_key}   AES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_6}   SHA   ${auth_key}   DES   ${priv_key}

SNMPv3_Support_suite_deprovision
    [Documentation]    suite deprovision for SNMPv3_Support
    log    suite deprovision for SNMPv3_Support

    delete_snmpv3_user    eutA    ${SNMPv3_user}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_1}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_2}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_3}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_4}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_5}
    delete_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_6}
    snmpv3_admin   eutA    disable