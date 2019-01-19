*** Settings ***
Documentation     The rollback on error capability is applicable to the error-option on the edit-config operation. The rollback on error will cause the device to roll back the changes to the state at the start of the edit config.
...
...               This may have impact on other sessions if locking is not employed.
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=ysnigdha
Resource          ./base.robot

*** Variables ***
${close_session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>
${lock_command}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="115"><lock><target><running/></target></lock></rpc>
${unlock_command}    <rpc message-id="110" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><unlock><target><running/></target></unlock></rpc>
${host_test}      ROLLBACK_TEST
${get_running}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get-config><source><running/></source></get-config></rpc>
${get_hostname}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="198"> <get-config> <source> <running/> </source> <filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/config/system/hostname"/> </get-config> </rpc>

*** Test Cases ***
tc_The_EXA_device_MUST_support_the_rollback_on_error_capability_per_RFC_6241_section_8_5
    [Tags]    @author=ysnigdha    @TCID= AXOS_E72_PARENT-TC-1764        @globalid=2322295
    [Documentation]    EXA device MUST support the rollback on error capability per RFC 6241 section 8.5

    #lock the data store
    Raw netconf configure    n1_session3    ${lock_command}    ok

    #Get Running Config before modifications
    ${run1}    Netconf Raw    n1_session3    xml=${get_running}
    log    ${run1}
    @{elem}    Raw netconf configure    n1_session3    ${get_hostname}    hostname
    ${host_run1}    set variable    ${elem[0].text}
    # [AT-666] edited by cindy gao as milan doesn't have interface 1/1/1
    ${edit}    set variable    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${host_test} </hostname><ntp><server><id>1</id></server><server><id>2</id></server></ntp><cli><telnet>enable</telnet></cli><environment-alarm><input><name>al1</name></input><input><name>al2</name></input><input><name>al3</name></input></environment-alarm><aaa><role><name>admin</name></role><role><name>networkadmin</name></role><role><name>oper</name></role></aaa></system></config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>1/1/x1</name><description/><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><link-up-down-trap-enable>disabled</link-up-down-trap-enable></interface><interface><name>1/1/x2</name><description/><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><link-up-down-trap-enable>disabled</link-up-down-trap-enable></interface><interface><name>1/1/x3</name><description/><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><link-up-down-trap-enable>disabled</link-up-down-trap-enable></interface><interface><name>1/1/x4</name><description/><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><link-up-down-trap-enable>disabled</link-up-down-trap-enable></interface><interface><name>1/1/xp4</name><description/><type xmlns:gpon-std="http://www.calix.com/ns/exa/gpon-interface-std">gpon-std:pon</type><enabled>false</enabled><link-up-down-trap-enable>disabled</link-up-down-trap-enable></interface><interface><name>craft1</name><description/><type xmlns:host-std="http://www.calix.com/ns/exa/host-management-std">host-std:craft</type><link-up-down-trap-enable>disabled</link-up-down-trap-enable><craft xmlns="http://www.calix.com/ns/exa/host-management-std"><ip><dhcp><server>enable</server></dhcp><address>10.2.35.133/24</address><gateway>10.2.35.1</gateway></ip></craft></interface><interface><name>wlan1</name><type xmlns:wifi-std="http://www.calix.com/ns/wifi-interface-std">wifi-std:wifi</type><link-up-down-trap-enable>disabled</link-up-down-trap-enable></interface></config>
    # [AT-666] edited by cindy gao as milan doesn't have interface 1/1/1
    #<interface><name>vlan720</name><type xmlns:vlan-std="http://www.calix.com/ns/vlan-interface-std">vlan-std:l3ipvlan</type><link-up-down-trap-enable>disabled</link-up-down-trap-enable><vlan xmlns="http://www.calix.com/ns/vlan-interface-std"><ip xmlns="http://www.calix.com/ns/exa/ip-management-vlan-std"><address><ip>192.91.20.1</ip><prefix-length>24</prefix-length></address></ip></vlan></interface></interfaces>
    #<vlan><vlan-id>700</vlan-id><security><egress xmlns="http://www.calix.com/ns/exa/access-security"><broadcast-flooding>ENABLED</broadcast-flooding><unknown-unicast-flooding>ENABLED</unknown-unicast-flooding></egress></security></vlan>
    #Edit running config with invalid configurations
    ${edit}    Edit netconf configure    n1_session3    ${edit}    error-tag
    should contain    ${edit[0].text}    operation-failed

    #Verify that the configs are not reflected in running-config
    ${verify}    Get attributes netconf    n1_session3    //system/hostname    hostname
    Should not contain    ${verify[0].text}    ${host_test}
    Should be Equal as Strings    ${verify[0].text}    ${host_run1}
    ${run2}    Netconf Raw    n1_session3    xml=${get_running}
    log    ${run2}

    #Verify if running config before and after the edit are same
    Should be equal as strings    ${run1}    ${run2}

    [Teardown]    AXOS_E72_PARENT-TC-1764 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1764 teardown
    [Documentation]       Teardown
    [Arguments]
    log     Enter AXOS_E72_PARENT-TC-1764 teardown

    # unlocking the data store running
    Raw netconf configure    n1_session3    ${unlock_command}    ok

    # close the netconf session
    Raw netconf configure    n1_session3    ${close_session}    ok
