*** Settings ***
Documentation     This requirement is from an agent perspective. It must support an ipv4 address on which it responds to SNMP requests.
Resource          ./base.robot
Force Tags        @author=sxavier    @feature=SNMP   @subfeature=SNMP Support


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_INNI_ENNI_UNI_Interface_IPv4_support
    [Documentation]    1	Create and enable SNMP v3 user.	Veriffy by show running snmp	
    ...    2	Connect PC running Silvercreek SNMP tool to V3 configured device.	Agent can connect.	
    ...    3	Perform a walk on any MIB.	MIB walk is successful.
    [Tags]       @author=sxavier     @TCID=AXOS_E72_PARENT-TC-1722
    [Setup]      AXOS_E72_PARENT-TC-1722 setup
    [Teardown]   AXOS_E72_PARENT-TC-1722 teardown

    log    STEP:2 Connect PC running Silvercreek SNMP tool to V3 configured device. Agent can connect.

    log    STEP:3 Perform a walk on any MIB. MIB walk is successful.

    ${hostname}    Get hostname    n1_session1    ${device_prompt}
    ${hostname}    Strip String    ${hostname}

    # Performing SNMPv3 get for hostname
    ${result}=  snmp get    n_snmp_v3     sysName
    should contain    ${result}    ${hostname}


*** Keywords ***
AXOS_E72_PARENT-TC-1722 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1722 setup
    log    STEP:1 Create and enable SNMP v3 user. Veriffy by show running snmp

    Configure SNMPv3   n1_session1    ${admin_state}   ${DEVICES.n_snmp_v3.username}   ${DEVICES.n_snmp_v3.authentication_protocol}
    ...   ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}


AXOS_E72_PARENT-TC-1722 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1722 teardown

    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
