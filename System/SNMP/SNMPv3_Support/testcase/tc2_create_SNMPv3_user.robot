*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc2_create_SNMPv3_user
    [Documentation]    Create SNMPv3 user
    [Tags]    @author=Philar Guo    @globalid=2373809   @tcid=AXOS_E72_PARENT-TC-2719  @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    prov_snmpv3_user    eutA    ${SNMPv3_user}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_1}   MD5   ${auth_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_2}   SHA   ${auth_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_3}   MD5   ${auth_key}   AES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_4}   MD5   ${auth_key}   DES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_5}   SHA   ${auth_key}   AES   ${priv_key}
    prov_snmpv3_user    eutA    ${SNMPv3_user_auth_priv_6}   SHA   ${auth_key}   DES   ${priv_key}

    ${result}    cli    eutA    show run snmp v3 user
    should contain    ${result}    v3 user    ${SNMPv3_user}
    should contain    ${result}    v3 user    ${SNMPv3_user_auth_1} MD5 ${auth_key}
    should contain    ${result}    v3 user    ${SNMPv3_user_auth_2} SHA ${auth_key}
    should contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_3} MD5 ${auth_key} AES ${priv_key}
    should contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_4} MD5 ${auth_key} DES ${priv_key}
    should contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_5} SHA ${auth_key} AES ${priv_key}
    should contain    ${result}    v3 user    ${SNMPv3_user_auth_priv_6} SHA ${auth_key} DES ${priv_key}

    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown