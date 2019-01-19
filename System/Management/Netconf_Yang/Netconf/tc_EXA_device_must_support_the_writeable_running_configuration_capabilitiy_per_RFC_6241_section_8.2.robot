*** Settings ***
Documentation     EXA device must support the writeable running configuration capabilitiy per RFC 6241 section 8.2
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=asamband
Resource          base.robot
Test Setup        RLT_TC_757 setup
Test Teardown     RLT_TC_757 teardown

*** Variables ***
${hostname}       changed-hostname
${edit}           <config> \ \ \ \ \ \ <config xmlns="http://www.calix.com/ns/exa/base"> \ \ \ \ \ \ \ \ <system> \ \ \ \ \ \ \ \ \ \ <hostname>${hostname}</hostname> \ \ \ \ \ \ \ \ </system> \ \ \ \ \ \ </config> \ \ \ \ </config>
${edit_original_hostname}    <config> \ \ \ \ \ \ <config xmlns="http://www.calix.com/ns/exa/base"> \ \ \ \ \ \ \ \ <system> \ \ \ \ \ \ \ \ \ \ <hostname>${default_hostname}</hostname> \ \ \ \ \ \ \ \ </system> \ \ \ \ \ \ </config> \ \ \ \ </config>

*** Test Cases ***
EXA device must support the writeable running configuration capabilitiy per RFC 6241 section 8.2
    [Documentation]    The writeable running configuration capability indicates that the device supports direct writes to the configuration datastore.
    [Tags]    @priority=p1    @tcid=AXOS_E72_PARENT-TC-1761        @globalid=2322292
    Comment    ${edit-config}=    Convert To String    ${p_edit-config}
    Log    Store the default hostname in get-hostname
    ${get_hostname}    Get hostname    n1_session1    ${default_hostname}
    ${step1}=    wait until keyword succeeds   180s   2s   Netconf Get Config    n1_session3    source=running
    ${step2}=    Netconf Edit Config    n1_session3    ${edit}    target=running
    Should Contain    ${step2.xml}    ok
    ${step3}=    Netconf Get Config    n1_session3    source=running
    Should Contain    ${step3.xml}    ${hostname}

*** Keywords ***
RLT_TC_757 setup
    log    Enter RLT_TC_757

RLT_TC_757 teardown
    log    Enter RLT_TC_757
    log    Revert back the original hostname
    ${value}=    Netconf Edit Config    n1_session3    ${edit_original_hostname}    target=running
    Should Contain    ${value.xml}    ok
	Netconf Raw    n1_session3    xml=${netconf.close_session}

Get hostname
    [Arguments]    ${conn}    ${hostname}
    [Documentation]    To get the device hostname
    #...    Example:
    #...    Get hostname    n1_session1
    ${output}    cli    ${conn}    show running-config hostname
    @{hostname}    Run Keyword If    'No entries found' in '''${output}'''    Return From Keyword    ${hostname}
    ...    ELSE    should match regexp    ${output}    hostname ([0-9a-zA-Z\\s\-]+)
    [Return]    @{hostname}[1]
