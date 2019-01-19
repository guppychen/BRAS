*** Settings ***
Documentation     The format for the sysDescr should be: <Vendor Name>. <h/w type>, <System Software Release>
...    Where:
...        Vendor Name = Calix, Inc.
...        H/W Type = externalized model name
...        System Software Release = the externalized s/w version name returned by “show software version"
...    For example: Calix, Inc. E5-308, V1.2.3.4
...    These must be human readable ASCII characters.
...    Per RFC 3418
...    sysDescr OBJECT-TYPE
...    SYNTAX DisplayString (SIZE (0..255))
...    MAX-ACCESS read-only
...    STATUS current
...    DESCRIPTION
...    "A textual description of the entity. This value should include the full name and version identification of
...    the system's hardware type, software operating-system, and networking software."
...    Note: The preference at Calix is to also maintain seperate objects for the s/w version (propriertary and host resource mib - hrSWInstalledTable). 
Force Tags    @author=nramalin      @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_SNMP_MIB_II_SystemGroup_sysDescr_object
    [Documentation]    1	Configure SNMP user.		
    ...    2	Connect to Agent with user information.		
    ...    3	Use a MIB browser to verify the information in the system group is correct for sysDesc.	SysDesc shows vendor, HW, and version correctly.	
    [Tags]       @author=nramalin     @TCID=AXOS_E72_PARENT-TC-1694
    [Setup]      AXOS_E72_PARENT-TC-1694 setup
    [Teardown]   AXOS_E72_PARENT-TC-1694 teardown

    log    STEP:2 Connect to Agent with user information.
    log    STEP:3 Use a MIB browser to verify the information in the system group is correct for sysDesc. SysDesc shows vendor, HW, and version correctly.

    # Retrieve sysDescr from cli
    ${res}     cli    n1_session1     show inventory baseboard model-name
    @{res}     should match regexp     ${res}     model-name ([\\S]+)
    ${res}     Remove String Using Regexp    @{res}[1]    "
    ${sys_info}     set variable     Calix, Inc ${res}

    # Verify SNMPv3 Connection
    ${result}=  snmp get  n_snmp_v3  sysDescr
    should contain  ${result}  ${sys_info}


*** Keywords ***
AXOS_E72_PARENT-TC-1694 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1694 setup

    log    STEP:1 Configure SNMP user.
    Configure SNMPv3   n1_session1    ${admin_state}   ${DEVICES.n_snmp_v3.username}   ${DEVICES.n_snmp_v3.authentication_protocol}
    ...   ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}


AXOS_E72_PARENT-TC-1694 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1694 teardown

    Remove SNMPv3   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
