*** Settings ***
Documentation     With user based security model (USM) in SNMPv3, we can use the following combination of authentication and privacy to secure communications. These are known as security levels:
...        noAuthNoPriv – no security applied
...        authNoPriv – message is authenticated
...        authPriv – message is authenticated and encrypted
...    Depending on what is configured for a user, we need to configure the necessary authentication and privacy protocols.
...        an authentication protocol can be one of: none, HMAC-MD5-96 (MD5) or HMAC-SHA-96 (SHA). Authentication establishes data integrity and trust of originator. Both MD5 and SHA generate a message digest. The authentication protocol authenticates a user by checking this message digest. Both protocols use keys to perform authentication where the keys are generated locally using the Engine ID and the user password/passphrase.
...        a privacy protocol can be one of none, AES or DES. Privacy is equivalent to encryption. The AES or DES privacy protocol requires the authentication protocol to be configured as either MD5 or SHA. Again both protocols use keys to encrypt messages.
...    Purpose
...    =======
...    Verify connectivity to the agent using AuthNoPriv.
Force Tags     @author=sxavier     @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***
${auth_protocol}     MD5
${wrong_protocol}    AES


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPv3_USM_AuthNoPriv
    [Documentation]    1	Configure SNMPv3 user with security level AuthNoPriv using MD5.	Can successfully walk a MIB connected to agent with MD5.	
    ...    2	Configure SNMPv3 user with security level AuthNoPriv using SHA.	Can successfully walk a MIB connected to agent with SHA.	
    ...    3	Configure the wrong Auth protocol.	Can not connect to the agent or walk a mib.
    [Tags]       @author=sxavier     @tcid=AXOS_E72_PARENT-TC-2884
    [Setup]      RLT-TC-704 setup
    [Teardown]   RLT-TC-704 teardown


    # To retrieve the hostname
    ${hostname}    Get hostname    n1_session1    ${device_prompt}
    ${hostname}    Strip String    ${hostname}

    # To connect to a agent successfully and do snmp walk with SHA
    @{result}    snmp Walk    n_snmp_v3    .1.3.6.1.2.1.1.5
    ${result}    Get From List    ${result}    0
    should contain    ${result}    ${hostname}

    # Removing the configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    log    STEP:1 Configure SNMPv3 user with security level AuthNoPriv using MD5. Can successfully walk a MIB connected to agent with MD5.
    # Creating a local session with authentication protocol as MD5
    ${conn}=    Session copy info     n_snmp_v3    authentication_protocol=${auth_protocol}
    Session build local   n1_localsession1    ${conn}

    # Configuring SNMPv3 user with authentication as MD5
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}  ${auth_protocol}   ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}

    # To connect to a agent and check whether snmp Walk is successful with MD5
    @{result}    snmp Walk    n1_localsession1    .1.3.6.1.2.1.1.5
    ${result}    Get From List    ${result}    0
    should contain    ${result}    ${hostname}

    # Removing the configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    # To destroy the local session
    Session destroy local    n1_localsession1

    log    STEP:3 Configure the wrong Auth protocol. Can not connect to the agent or walk a mib.
    # Creating a local session with wrong authentication protocol
    ${conn}=    Session copy info     n_snmp_v3    authentication_protocol=${wrong_protocol}

    # To verify that the snmpv3 session cannot be build with wrong protocol
    Run keyword and expect error   SnmpError: Invalid authentication protocol '${wrong_protocol}'. Must be one of: None, 'SHA', 'MD5'   Session build local   n1_localsession1    ${conn}

    # To configure SNMPve user using wrong authentication protocol
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}  ${wrong_protocol}   ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}

     ${msg}    Run keyword and expect error    *    snmp Walk    n_snmp_v3    .1.3.6.1.2.1.1.5
     Should Contain    ${msg}    SNMP WALK failed:


*** Keywords ***
RLT-TC-704 setup
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-704 setup

    log    STEP:2 Configure SNMPv3 user with security level AuthNoPriv using SHA. Can successfully walk a MIB connected to agent with SHA.
    # To configure SNMPv3 using SHA
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}  ${DEVICES.n_snmp_v3.authentication_protocol}    ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}



RLT-TC-704 teardown
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-704 teardown

    # To destroy the local session
    Session destroy local    n1_localsession1

    # To remove the SNMPv3 configuration
    Remove SNMPv3   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
