*** Settings ***
Documentation     The configuration to access a RADIUS server includes:
...        host  - IPAddress of fully qualified domain name
...        mode - accounting or authorization (informative as ports are mode specific)
...        port  - default to 1812, or 1645 for authorization and 1813, or 1646 for accounting
...        shared secret - 16-128 characters including spaces
...        timeout - seconds to wait before timing out a request to the RADIUS server [1..30 secs default 3]
...        retries -  number of consecutive retries to attempt. If all time out, then the RADIUS server is marked as unreachable [1..10 default 3]
...    =====================================================================================================
...    The purpose of this test is to verify RADIUS Provisioning. Parameters specified above should be provisioned without error and and error message should be seen upon trying to configure values out of range.
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=pmunisam
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_The_EXA_device_MUST_support_configuration_of_how_to_use_a_RADIUS_server_that_includes_host_port_shared_secret_timeout_retries_shared_secret
    [Documentation]    1	configure the EXA device as client to access the Radius server with server IP; shared secret; server timeout and retries (if this is not one time authentication, would also need Quiet period, and Re authentication period). (port should be already provisioned in Entering server(s))		
    ...    2	show configuration 	entered parameters are displayed correctly	
    ...    3	verify the IP address, Shared Secret, Port via Wireshark monitor the traffic coming to the server	traffic should reach the Radius server with the correct provisioned values, and user authenticated.	Timeout and Retries are in other TCs.
    [Tags]       @author=pmunisam     @TCID=AXOS_E72_PARENT-TC-1328
    [Setup]      AXOS_E72_PARENT-TC-1328 setup
    [Teardown]   AXOS_E72_PARENT-TC-1328 teardown
    log    STEP:1 configure the EXA device as client to access the Radius server with server IP; shared secret; server timeout and retries (if this is not one time authentication, would also need Quiet period, and Re authentication period). (port should be already provisioned in Entering server(s))
    log    STEP:2 show configuration entered parameters are displayed correctly

    cli    n1_session1    conf
    cli    n1_session1    aaa radius server ${radius_server2} priority ${invalid_range_priority}
    Result Match Regexp    syntax error:.*is out of range
    cli    n1_session1    aaa radius server ${radius_server2} priority ${invalid_priority}
    Result Match Regexp    syntax error:.*is not a valid value
    cli    n1_session1    aaa radius server ${radius_server2} timeout ${invalid_range_timeout}
    Result Match Regexp    syntax error:.*is out of range
    cli    n1_session1    aaa radius server ${radius_server2} timeout ${invalid_timeout}
    Result Match Regexp    syntax error:.*is not a valid value
    cli    n1_session1    aaa radius server ${radius_server2} port ${invalid_range_port}
    Result Match Regexp    syntax error:.*is not a valid value
    cli    n1_session1     end

    Configure radius server    n1_session1    ${radius_server2}    secret=${secret}    port=${default_port}     priority=1    timeout=5

    Configure aaa authentication-order    n1_session1    ${authentication}

    log    STEP:3 verify the IP address, Shared Secret, Port via Wireshark monitor the traffic coming to the server traffic should reach the Radius server with the correct provisioned values, and user authenticated. Timeout and Retries are in other TCs.
    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session2    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}

    # tcpdump for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    Get packet capture    n1_session2    n1_localsession    ${interface}    ${radius_server2}   ${RadiusFileName}

    #Verify packet capture for access-request and accesss-accept
    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server2}    1=Access-Request
    Verify packet capture    n1_session2    ${RadiusFileName}    ${radius_server2}    ${DEVICES.n1_session1.ip}     2=Access-Accept


*** Keywords ***
AXOS_E72_PARENT-TC-1328 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1328 setup
    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

    # Remove Radius user
    Remove aaa user    n1_session1    ${radius_admin_user}


AXOS_E72_PARENT-TC-1328 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1328 teardown

    # Destroy the local session
    Session destroy local    n1_localsession

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

    # Ctrl+C to break the tcpdump packet capture
    cli    n1_session2    \x03     \\~#

    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
