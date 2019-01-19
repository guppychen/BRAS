*** Settings ***
Documentation     With user based security model (USM) in SNMPv3, we can use the following combination of authentication and privacy to secure communications. These are known as security levels:
...    
...        noAuthNoPriv – no security applied
...        authNoPriv – message is authenticated
...        authPriv – message is authenticated and encrypted
...    
...    Depending on what is configured for a user, we need to configure the necessary authentication and privacy protocols.
...    
...        an authentication protocol can be one of: none, HMAC-MD5-96 (MD5) or HMAC-SHA-96 (SHA). Authentication establishes data integrity and trust of originator. Both MD5 and SHA generate a message digest. The authentication protocol authenticates a user by checking this message digest. Both protocols use keys to perform authentication where the keys are generated locally using the Engine ID and the user password/passphrase.
...        a privacy protocol can be one of none, AES or DES. Privacy is equivalent to encryption. The AES or DES privacy protocol requires the authentication protocol to be configured as either MD5 or SHA. Again both protocols use keys to encrypt messages.
Resource          ./base.robot
Force Tags     @author=dzala    @feature=SNMP   @subfeature=SNMP Support


*** Variables ***
${auth_protocol}    MD5
${encryption_protocol}    AES128
${wrong_protocol}    AES
${admin_state}    enable

*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPv3_USM_AuthPriv
    [Documentation]    1	Verify SNMPv3 user with security level AuthPriv using authentication MD5 and privacy AES.	Successfully walk any mib with AuthPriv security level.	
    ...    2	Verify SNMPv3 user with security level AuthPriv using authentication SHA and privacy AES.	Successfully walk any mib with AuthPriv security level.	
    ...    3	Verify SNMPv3 user with security level AuthPriv using authentication MD5 and privacy DES.	Successfully walk any mib with AuthPriv security level.	
    ...    4	Verify SNMPv3 user with security level AuthPriv using authentication SHA and privacy DES.	Successfully walk any mib with AuthPriv security level.	
    ...    5	Verify PDUs are encrypted when priv protocol is none. ​	PDU is encrypted.	
    ...    6	Verify the wrong priv protocol fails to connect to agent.	Can't connect to the agent with the wrong priv configured, or walk a mib.
    [Tags]       @author=dzala     @tcid=AXOS_E72_PARENT-TC-2885
    [Setup]      RLT-TC-705 setup
    [Teardown]   RLT-TC-705 teardown

    # Retrieve hostname of device
    ${hostname}    Get hostname    n1_session1    SJ-Auto-ROLT1
    ${hostname}    Strip String    ${hostname}

    # To connect to a agent successfully and do snmp walk with SHA
    ${result}    snmp get    n_snmp_v3    sysName
    should contain    ${result}    ${hostname}

    # Removing the configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    log    STEP:1 Verify SNMPv3 user with security level AuthPriv using authentication MD5 and privacy AES. Successfully walk any mib with AuthPriv security level.

    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    MD5    ${DEVICES.n_snmp_v3.password}    AES
    ...    ${DEVICES.n_snmp_v3.encryption_password}

    # Build Local session with MD5 and AES
    ${conn}    Session copy info    n_snmp_v3    authentication_protocol=MD5    encryption_protocol=AES128
    Session build local    n1_localsession1    ${conn}

    ${result}    snmp get    n1_localsession1    sysName
    should contain    ${result}    ${hostname}

    # Removing the configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    # To destroy the local session
    Session destroy local    n1_localsession1

    log    STEP:2 Verify SNMPv3 user with security level AuthPriv using authentication SHA and privacy AES. Successfully walk any mib with AuthPriv security level.

    # Configuring SNMPv3 user with encryption protocol as AES
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${DEVICES.n_snmp_v3.authentication_protocol}    ${DEVICES.n_snmp_v3.password}    AES
    ...    ${DEVICES.n_snmp_v3.encryption_password}

    # Creating a local session with encryption protocol as AES
    ${conn}    Session copy info    n_snmp_v3    encryption_protocol=AES128
    Session build local    n1_localsession1    ${conn}

    ${result}    snmp get    n1_localsession1    sysName
    should contain    ${result}    ${hostname}

    # Removing the configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    # To destroy the local session
    Session destroy local    n1_localsession1

    log    STEP:3 Verify SNMPv3 user with security level AuthPriv using authentication MD5 and privacy DES. Successfully walk any mib with AuthPriv security level.
    # Configuring SNMPv3 user with authentication as MD5
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${auth_protocol}    ${DEVICES.n_snmp_v3.password}    ${DEVICES.n_snmp_v3.encryption_protocol}
    ...    ${DEVICES.n_snmp_v3.encryption_password}

    # Creating a local session with authentication protocol as MD5
    ${conn}    Session copy info    n_snmp_v3    authentication_protocol=${auth_protocol}
    Session build local    n1_localsession1    ${conn}

    ${result}    snmp get    n1_localsession1    sysName
    should contain    ${result}    ${hostname}

    # Removing the configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    # To destroy the local session
    Session destroy local    n1_localsession1

    log    STEP:5 Verify PDUs are encrypted when priv protocol is none. ​ PDU is encrypted.

    log    STEP:6 Verify the wrong priv protocol fails to connect to agent. Can't connect to the agent with the wrong priv configured, or walk a mib.
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${DEVICES.n_snmp_v3.authentication_protocol}    ${DEVICES.n_snmp_v3.password}    AES
    ...    ${DEVICES.n_snmp_v3.encryption_password}

    # Creating a local session with wrong authentication protocol
    ${conn}    Session copy info    n_snmp_v3    encryption_protocol=AES
    Run keyword and expect error    SnmpError: Invalid authentication protocol 'AES'. Must be one of: None, '3DES', 'AES256', 'DES', 'AES128', 'AES192'    Session build local    n1_localsession1    ${conn}



*** Keywords ***
RLT-TC-705 setup
    [Documentation]    ROLT Setup
    [Arguments]
    log    Enter RLT-TC-705 setup

    # To remove the SNMPv3 configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    log    STEP:4 Verify SNMPv3 user with security level AuthPriv using authentication SHA and privacy DES. Successfully walk any mib with AuthPriv security level.

    # To configure SNMPv3 using SHA and DES
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}  ${DEVICES.n_snmp_v3.authentication_protocol}    ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}



RLT-TC-705 teardown
    [Documentation]    ROLT Teardown
    [Arguments]
    log    Enter RLT-TC-705 teardown

    # To destroy the local session
    Session destroy local    n1_localsession1

    # To remove the SNMPv3 configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
