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
...    
...     
...    
...    Purpose
...    =======
...    Verify connectivity to the agent using NoAuthNoPriv security level.
...    
...     
...    
...     v3 user calixnoauth
...      authentication protocol NONE
...     !
...    
...     v3 trap-host 10.0.3.23 calixauth
...      security-level noauthnoPriv
Force Tags     @author=sxavier     @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***
${test_user}    test1234


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPv3_USM_NoAuthNoPriv
    [Documentation]    1	Configure SNMPv3 user with security level NoAuthNoPriv and authentication of "none".	Connect to agent successfully.	v3 user calixnoauth authentication protocol NONE ! v3 trap-host 10.0.3.23 calixauth security-level noauthnoPriv
    ...    2	Walk any MIB.	Walk is successful. 
    [Tags]       @author=sxavier     @tcid=AXOS_E72_PARENT-TC-2883
    [Setup]      RLT-TC-703 setup
    [Teardown]   RLT-TC-703 teardown
    log    STEP:1 Configure SNMPv3 user with security level NoAuthNoPriv and authentication of "none". Connect to agent successfully. v3 user calixnoauth authentication protocol NONE ! v3 trap-host 10.0.3.23 calixauth security-level noauthnoPriv

    log    STEP:2 Walk any MIB. Walk is successful.

    # To retrieve the hostname
    ${hostname}    Get hostname    n1_session1    ${device_prompt}
    ${hostname}    Strip String    ${hostname}

    # To connect to a agent successfully and do snmp walk with SHA
    ${result}=  snmp get  n_snmp_v3  sysName
    should contain    ${result}    ${hostname}

    # Creating a local session with authentication protocol as None
    ${conn}    Session create info     ip=${DEVICES.n_snmp_v3.ip}    port=${DEVICES.n_snmp_v3.port}
    ...    protocol=${DEVICES.n_snmp_v3.protocol}    version=${DEVICES.n_snmp_v3.version}    username=${test_user}
    ...    authentication_protocol=${None}
    Session build local    n1_localsession1    ${conn}

    # To connect to a agent and check whether snmp Walk is successful
    ${result}=  snmp get  n1_localsession1    sysName
    should contain    ${result}    ${hostname}


*** Keywords ***
RLT-TC-703 setup
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-703 setup

    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}  ${DEVICES.n_snmp_v3.authentication_protocol}
    ...    ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}

    Configure SNMPv3    n1_session1    ${admin_state}    ${test_user}    NONE


RLT-TC-703 teardown
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-703 teardown

    # To destroy the local session
    Session destroy local    n1_localsession1

    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
    Remove SNMPv3    n1_session1    ${admin_state}    ${test_user}
