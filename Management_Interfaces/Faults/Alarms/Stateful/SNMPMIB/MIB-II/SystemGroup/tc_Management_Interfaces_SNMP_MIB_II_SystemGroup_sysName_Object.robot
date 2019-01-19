*** Settings ***
Documentation     The sysName is the FQDN of the device as set by the provider during initial turn up. By default the sysName is not set (empty).
...    Per RFC 3418
...    sysName OBJECT-TYPE
...                  SYNTAX  DisplayString (SIZE (0..255))
...                  ACCESS  read-write
...                  STATUS  mandatory
...                  DESCRIPTION
...                          "An administratively-assigned name for this
...                          managed node.  By convention, this is the node's
...                          fully-qualified domain name. If the name is unknown,
...                          the value is the zero-length string."
...                  ::= { system 5 }
...    Note: It is expected that the sysName will be set during the device turnup to a unique FQDN relative to the provider.
...    ============================================================================
...    Valid ASCii character set?
...    DisplayString ::= TEXTUAL-CONVENTION
...        DISPLAY-HINT "255a"
...        STATUS       current
...        DESCRIPTION
...                "Represents textual information taken from the NVT ASCII
...    McCloghrie, et al.          Standards Track                     [Page 3]________________________________________
...      <https://tools.ietf.org/html/rfc2579#page-4>RFC 2579
...    <https://tools.ietf.org/html/rfc2579>             Textual Conventions for SMIv2            April 1999
...                character set, as defined in pages 4, 10-11 of RFC 854 <https://tools.ietf.org/html/rfc854>.
...                To summarize RFC 854 <https://tools.ietf.org/html/rfc854>, the NVT ASCII repertoire specifies:
...                  - the use of character codes 0-127 (decimal)
...                  - the graphics characters (32-126) are interpreted as
...                    US ASCII
...                  - NUL, LF, CR, BEL, BS, HT, VT and FF have the special
...                    meanings specified in RFC 854 <https://tools.ietf.org/html/rfc854>
...                  - the other 25 codes have no standard interpretation
...                  - the sequence 'CR LF' means newline
...                  - the sequence 'CR NUL' means carriage-return
...                  - an 'LF' not preceded by a 'CR' means moving to the
...                    same column on the next line.
...                  - the sequence 'CR x' for any x other than LF or NUL is
...                    illegal.  (Note that this also means that a string may
...                    end with either 'CR LF' or 'CR NUL', but not with CR.)
...                Any object defined using this syntax may not exceed 255
...                characters in length."
...        SYNTAX       OCTET STRING (SIZE (0..255))
...    Purpose
...    =======
...    Verify the information for the sysName Object is correct.
Force Tags    @author=lpaul    @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot

*** Variables ***
${sys_name1}   sysName1
${sys_name2}   lets_see_how_long_we_can_make_the_hostname_for_testing_on_the_d


*** Test Cases ***
tc_Management_Interfaces_SNMP_MIB_II_SystemGroup_sysName_Object
    [Documentation]    1	Configure SNMP user.		
    ...    2	Connect to Agent with user information.		
    ...    3	Use a MIB browser to verify the information in the system group is correct for sysName.	SysName shows correctly.	
    ...    4	Change the devices hostname.	Verify the sysName is updated.	
    ...    5	Use a hostname with the maximum number of characters supported by the device.	Max length of sysName is shown.	
    ...    6	Verify all characters supported by the hostname are supported in the sysName.	Letters, numbers, and special characters are shown in sysName.
    [Tags]       @author=lpaul     @TCID=AXOS_E72_PARENT-TC-1695
    [Setup]      AXOS_E72_PARENT-TC-1695 setup
    [Teardown]   AXOS_E72_PARENT-TC-1695 teardown    ${sysname}

    # Getting the hostname
    ${hostname}    Get hostname    n1_session1    ${device_prompt}
    ${hostname}    Strip String    ${hostname}

    # To reset later back to device hostname
    ${sysname}     set variable    ${hostname}

    log    STEP:2 Connect to Agent with user information.
    log    STEP:3 Use a MIB browser to verify the information in the system group is correct for sysName. SysName shows correctly.
    ${result}    snmp get    n_snmp_v3    sysName
    should contain    ${result}    ${hostname}

    # SNMP set fails as it is not supported on AXOS
    log    STEP:4 Change the devices hostname. Verify the sysName is updated.
    Run Keyword And Expect Error    SNMP SET failed: notWritable    Snmp Set    n_snmp_v3   sysName   ${sys_name1}

    log    STEP:5 Use a hostname with the maximum number of characters supported by the device. Max length of sysName is shown.
    log    STEP:6 Verify all characters supported by the hostname are supported in the sysName. Letters, numbers, and special characters are shown in sysName.

    # CLI set hostname
    cli    n1_session1    conf
    cli    n1_session1    hostname ${sys_name1}
    cli    n1_session1    end

    # SNMP get to retrieve modified hostname
    ${result}    snmp get    n_snmp_v3    sysName
    should contain    ${result}    ${sys_name1}

    # CLI set hostname
    cli    n1_session1    conf
    cli    n1_session1    hostname ${sys_name2}
    cli    n1_session1    end

    # SNMP get to retrieve modified hostname
    ${result}    snmp get    n_snmp_v3    sysName
    should contain    ${result}    ${sys_name2}


*** Keywords ***
AXOS_E72_PARENT-TC-1695 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1695 setup

    log    STEP:1 Configure SNMP user.
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${DEVICES.n_snmp_v3.authentication_protocol}
    ...   ${DEVICES.n_snmp_v3.password}   ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}

AXOS_E72_PARENT-TC-1695 teardown
    [Documentation]
    [Arguments]    ${hostname}
    log    Enter AXOS_E72_PARENT-TC-1695 teardown

    # Remove SNMPv3 configuration
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    # CLI set hostname that earlier existed
    cli    n1_session1    conf
    cli    n1_session1    hostname ${hostname}
    cli    n1_session1    end