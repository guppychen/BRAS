*** Settings ***
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=bswamina
Resource          base.robot

*** Variables ***
#${interface}     <?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter type="xpath" select="/*/interface[name='${i}']" /></get></rpc>

*** Test Cases ***
tc_EXA_Device_must_display_all_E3_2_interfaces_of_YANG_table
    [Documentation]    The following interfaces MUST be visible:
    ...    4 10G Ethernet interfaces
    ...    PON ports - each PON port in the database MUST be visible. These depend on the modules that are inserted in the module slots
    ...    ONT interfaces - any ONT, real or pre-provisioned, has a set of interfaces that depend on the ont-profile. These MUST all be visible on the interfaces list
    ...    USB interfaces - these are dependent on whether or not a USB dongle is inserted
    ...    craft interface
    ...    LAG - any configured Link Aggregation group
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1806    @globalid=2322337

    [Setup]    DPU_R1_0-TC-3619 setup
    #First approach
    log    STEP:1 Get all interface from box except craft
    ${ethernet_int}    cli    n1_session1    show running-config interface | include interface | exclude craft | exclude vlan | exclude channel | exclude ffp | exclude ip-host    prompt=#    timeout=30    newline=\n
    ...    timeout_exception=1

    @{ethernet_int_list}    create list
    ${lc_count}    get line count    ${ethernet_int}
    ${new_lc_count}    evaluate    ${lc_count}-1
    ${split_eth_int}    split string    ${ethernet_int}    \n
    : FOR    ${i}    IN RANGE    1    ${new_lc_count}
    \    ${item}    get from list    ${split_eth_int}    ${i}
    \    ${item}    split string    ${item}
    \    ${port}    get from list    ${item}    2
    \    ${port}    strip string    ${port}
    \    append to list    ${ethernet_int_list}    ${port}
    log    ${ethernet_int_list}

    log    STEP:2 Verify interface are avaialble via NETCONF
    : FOR    ${i}    IN    @{ethernet_int_list}
    \    ${interface}    set variable    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter type="xpath" select="/*/interface[name='${i}']" /></get></rpc>
    \    ${elem}    Raw netconf configure    n1_session3    ${interface}    name
    \    ${port}    set variable    ${elem[0].text}
    \    ${port}    strip string    ${port}
    \    Should Be Equal As Strings    ${port}    ${i}    msg=NETCONF returns interface displayed in CLI as expected

    log    STEP:3 Get craft interface from box
    ${ethernet_int}    cli    n1_session1    show running-config interface | include craft    prompt=#
    @{ethernet_int_list}    create list
    ${lc_count}    get line count    ${ethernet_int}
    ${new_lc_count}    evaluate    ${lc_count}-1
    ${split_eth_int}    split string    ${ethernet_int}    \n
    : FOR    ${i}    IN RANGE    1    ${new_lc_count}
    \    ${item}    get from list    ${split_eth_int}    ${i}
    \    ${item}    split string    ${item}
    \    ${craft}    get from list    ${item}    1
    \    ${craft}    strip string    ${craft}
    \    ${port}    get from list    ${item}    2
    \    ${port}    strip string    ${port}
    \    ${craft}    catenate    SEPARATOR=    ${craft}    ${port}
    \    append to list    ${ethernet_int_list}    ${craft}
    log    ${ethernet_int_list}

    # Verify interface are avaialble via NETCONF
    : FOR    ${i}    IN    @{ethernet_int_list}
    \    ${interface}    set variable    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter type="xpath" select="/*/interface[name='${i}']" /></get></rpc>
    \    ${elem}    Raw netconf configure    n1_session3    ${interface}    name
    \    ${port}    set variable    ${elem[0].text}
    \    ${port}    strip string    ${port}
    \    Should Be Equal As Strings    ${port}    ${i}    msg=NETCONF returns interface displayed in CLI as expected
    [Teardown]    DPU_R1_0-TC-3619 teardown

*** Keywords ***
DPU_R1_0-TC-3619 setup
    [Documentation]    DPU_R1_0-TC-3619 setup
    [Arguments]
    log    Enter DPU_R1_0-TC-3619 setup
    cli    n1_session1    configure
    cli    n1_session1    interface lag la1
    cli    n1_session1    no shutdown
    cli    n1_session1    end

DPU_R1_0-TC-3619 teardown
    [Documentation]    DPU_R1_0-TC-3619 teardown
    [Arguments]
    log    Enter DPU_R1_0-TC-3619 teardown
    cli    n1_session1    configure
    cli    n1_session1    interface lag la1
    cli    n1_session1    shutdown
    cli    n1_session1    end
