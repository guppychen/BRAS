*** Settings ***
Documentation     The sysObjectId must uniquely and unambigiously identify the vendor and product model
...               of the EXA device. The sysObjectIdmust be reserved under the Calix enterprise OID in
...               such away that there are is no possibility of OID collisions
...               Per RFC 3418
...               sysObjectID OBJECT-TYPE
...               SYNTAX OBJECT IDENTIFIER
...               MAX-ACCESS read-only
...               STATUS current
...               DESCRIPTION
...               "The vendor's authoritative identification of the
...               network management subsystem contained in the entity.
...               This value is allocated within the SMI enterprises
...               subtree (1.3.6.1.4.1) and provides an easy and
...               unambiguous means for determining `what kind of box' is
...               being managed. For example, if vendor `Flintstones,
...               Inc.' was assigned the subtree 1.3.6.1.4.1.424242,
...               it could assign the identifier 1.3.6.1.4.1.424242.1.1
...               to its `Fred Router'."
...               ::= { system 2 }
...               Purpose
...               =======
...               Verify the information for the sysObjectId is correct.
Force Tags        @author=nphilip    @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Management_Interfaces_SNMP_MIB_II_SystemGroup_sysObjectId
    [Documentation]    1 Configure SNMP user.
    ...    2 Connect to Agent with user information.
    ...    3 Use a MIB browser to verify the information in the system group is correct for sysObjectId. sysObjectId shows correctly.
    [Tags]    @author=nphilip    @TCID=AXOS_E72_PARENT-TC-1696
    [Setup]    AXOS_E72_PARENT-TC-1696 setup
    log    STEP:3 Use a MIB browser to verify the information in the system group is correct for sysObjectId. sysObjectId shows correctly.
    ${result}=    snmp get    n_snmp_v3    sysObjectID
    Should Match Regexp    ${result}    (\\w+-)+\\w+::\\w+
    [Teardown]    AXOS_E72_PARENT-TC-1696 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1696 setup
    log    Enter AXOS_E72_PARENT-TC-1696 setup
    log    STEP:1 Configure SNMP user.
    log    STEP:2 Connect to Agent with user information.
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${DEVICES.n_snmp_v3.authentication_protocol}    ${DEVICES.n_snmp_v3.password}    ${DEVICES.n_snmp_v3.encryption_protocol}
    ...    ${DEVICES.n_snmp_v3.encryption_password}

AXOS_E72_PARENT-TC-1696 teardown
    log    Enter AXOS_E72_PARENT-TC-1696 teardown
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
