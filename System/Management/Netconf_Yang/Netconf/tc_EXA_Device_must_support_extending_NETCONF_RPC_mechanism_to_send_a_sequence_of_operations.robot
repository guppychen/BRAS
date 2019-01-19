*** Settings ***
Documentation     The device must support extending the NETCONF RFC operation encoding to allow for one or more operations to be sent at a time. The intent is to address the limitation of the standard netconf RPC which allows only a single synchronous request at a time. There is no intent require transactional support across the sequence of operations.
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=pmunisam
Resource          ./base.robot

*** Variables ***
${rpc1}           <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get-config><source><running/></source></get-config></rpc>
${rpc2}           <rpc message-id="102" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><show-alarm-definitions-address xmlns="http://www.calix.com/ns/exa/base"></show-alarm-definitions-address></rpc>
${rpc3}           <rpc message-id="103" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="xpath" select="/status/interface"/></get></rpc>
${rpc4}           <rpc message-id="104" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter xmlns="http://www.calix.com/ns/exa/base"><status><clock/></status></filter></get></rpc>
${rpc5}           <rpc message-id="105" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><delete-config-file xmlns="http://www.calix.com/ns/exa/base"><filename>bogus.xml</filename></delete-config-file></rpc>
@{getconfig_list}
@{interface_list}
${message}        message-id="105"

*** Test Cases ***
tc_EXA_Device_must_support_extending_NETCONF_RPC_mechanism_to_send_a_sequence_of_operations
    [Documentation]    1 Extend Netconf to allow multiple RPC commands
    ...    2 Send sequence of operations in rpc rpc is accepted
    ...    3 Verify operations were executed.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1750        @globalid=2322281

    # [AT-666] removed by cgao as milan not have this default config
    #Verifying the getconfig operations
    # @{getconfig}    Raw netconf configure    n1_session3    ${rpc1}    s-tag-pcp
    # Should contain    ${getconfig[0].text}    0
    # [AT-666] removed by cgao as milan not have this default config

    #Verifying the showalarm operations
    @{showalarm}    Raw netconf configure    n1_session3    ${rpc2}    total-count
    Element Text Should Match    @{showalarm}    0

    #Verifying the interface status operations
    @{getconfig}    Raw netconf configure    n1_session3    ${rpc3}    max-speed
    Should contain    ${getconfig[0].text}    ${speed}

    #Getting the time format
    @{t}    Get attributes netconf    n1_session3    //clock    time-status
    ${timestamp} =    Convert Date    ${t[0].text}    result_format=%Y-%m-%d %H:%M

    #Verifying the clockstatus operations
    @{clockstatus}    Raw netconf configure    n1_session3    ${rpc4}    time-status
    ${count}    Get Length    ${clockstatus}
    ${date} =    Convert Date    ${clockstatus[${count}-1].text}    result_format=%Y-%m-%d %H:%M
    Should Be Equal    ${date}    ${timestamp}

    #Verifying the deleteconfig operations
    ${deleteconfig}=    Netconf Raw    n1_session3    xml=${rpc5}
    Should Contain    ${deleteconfig.xml}    ${message}
    Log    ${deleteconfig}

