*** Settings ***
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=bswamina
Resource          base.robot

*** Variables ***
${ftp}            ftp://${upgrade_usr}:${upgrade_pwd}@${upgrade_server}/tftpboot/Netconf/TC-744
${copy_ftp}       <?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="6"><copy-config><target><url>${ftp}</url></target><source><running/></source></copy-config></rpc>
${candidate}      <?xml version="1.0" encoding="UTF-8"?><rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><copy-config><target><url>file:///checkpoint.conf</url></target><source><running/></source></copy-config></rpc>
${delete_candidate}    <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><delete-config><target><url>file:///checkpoint.conf</url></target></delete-config></rpc>
${new_hostname}    configB
${type_and_select}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="198"> <get-config> <source> <running/> </source> <filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/config/system/hostname"/> </get-config> </rpc> 
${configB}        <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${new_hostname}</hostname></system></config></config>
${delete_ftp}     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><delete-config><target><url>${ftp}</url></target></delete-config></rpc>
${val}    0

*** Test Cases ***
tc_EXA_device_MUST_support_the_delete_config_operation_run_config_start_config_test_config
    [Documentation]    1. Create a config and save the udpated config to FTP and verify FTP operation was successfull
    ...    2. Perfrom delete operation of FTP file and verify it returns error
    ...    3. Create an alternate config file based off of the running config and call it checkpoint.conf using the command and verify alternate config created
    ...    4. Issue the command to remove the checkpoint.conf configuration and verify its's indeed removed
    [Tags]    @author=bswamina      @user=root   @TCID=AXOS_E72_PARENT-TC-1754        @globalid=2322285

    # Retrieve hostname before modifying
    ${hostname}    Get hostname    n1_session1    find_hostname
    ${device_name}    strip string    ${hostname}

    log    STEP:1. Create a config and save the udpated config to FTP and verify FTP operation was successfull
    #Create new config - hostname change
    Edit netconf configure    n1_session3    ${configB}    ok

    #Verify hostname changed bu retireving hostname via NETCONF
    ${elem}    Raw netconf configure    n1_session3    ${type_and_select}    hostname
    ${res}    XML.Get Element Text    @{elem}
    ${res}    strip string    ${res}
    run keyword if    '${res}' == '${new_hostname}'    log    Hostname of device retrieved by NETCONF matches configuration
    ...    ELSE    fail    msg=Hostname retrieved by NETCONF is diff from configuration

    #Copy running to FTP
    Raw netconf configure    n1_session3    ${copy_ftp}    ok

    #Verify file created in FTP
    # creating the locatl session
    ${conn}=    Session copy info    h1    ip=${upgrade_server}
    Session build local    h1_localsession_server1    ${conn}

    cli    h1_localsession_server1    ftp ${upgrade_server}    prompt=:    timeout=10    newline=\n    timeout_exception=1
    result should contain    vsFTPd

    cli    h1_localsession_server1   ${upgrade_usr}     prompt=:    timeout=10    newline=\n    timeout_exception=1
    result should contain    Please specify the password

    cli    h1_localsession_server1    ${upgrade_pwd}    prompt=>    timeout=10    newline=\n    timeout_exception=1
    result should contain    Login successful

    cli    h1_localsession_server1    cd /tftpboot/Netconf    prompt=>    timeout=10    newline=\n    timeout_exception=1
    result should contain    Directory successfully changed

    cli    h1_localsession_server1    ls    prompt=>    timeout=10    newline=\n    timeout_exception=1
    result should contain    Here comes the directory listing
    result should contain    TC-744

    cli    h1_localsession_server1    delete TC-744    prompt=>    timeout=10    newline=\n    timeout_exception=1
    result should contain    Delete operation successful

    cli    h1_localsession_server1    ls    prompt=>    timeout=10    newline=\n    timeout_exception=1
    result should contain    Here comes the directory listing
    result should not contain    TC-744

    cli    h1_localsession_server1    exit    prompt=$    timeout=10    newline=\n    timeout_exception=1
    result should contain    Goodbye

    log    STEP:2. Perfrom delete operation of FTP file and verify it returns error
    #Try delete file from FTP and verify it errors
    ${elem}    Raw netconf configure    n1_session3    ${delete_ftp}    error-tag
    Element Text Should Match    @{elem}    operation-not-supported

    log    STEP:3. Create an alternate config file based off of the running config and call it checkpoint.conf using the command and verify alternate config created
    #Alternate config creation - checkpoint.conf
    Raw netconf configure    n1_session3    ${candidate}    ok

    #Verification of alternate config creation
    ${var}    cli    n1_session2    ls /tmp/confd/state | grep conf
    ${list}    split string    ${var}    \n
    ${lc_count}    get line count    ${var}
    : FOR    ${i}    IN RANGE    0    ${lc_count}
    \    ${mgr}    get from list    ${list}    ${i}
    \    ${mgr}    strip string    ${mgr}
    \    ${val}    run keyword if    '${mgr}' != 'checkpoint.conf'   Continue For Loop
    \    ...    ELSE    Set Variable    1 
    \    log    Alternate config based off running config SUCCESSFULLY created via NETCONF
    \    Exit For Loop
   
    Run Keyword If   "${val}" != "1"    Fail    Alternate config based off running config Not created via NETCONF


    log    STEP:4. Issue the command to remove the checkpoint.conf configuration and verify its's indeed removed
    #Deletion of alternate config created
    Raw netconf configure    n1_session3    ${delete_candidate}    ok

    #Verification of deletion of alternate config
    cli    n1_session2    ls /tmp/confd/state | grep conf
    Result Should Not Contain    checkpoint.conf
    log    Alternate config based off running config SUCCESSFULLY removed via NETCONF

    [Teardown]    AXOS_E72_PARENT-TC-1754 teardown    ${device_name}

*** Keywords ***
AXOS_E72_PARENT-TC-1754 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1754 teardown
    [Arguments]    ${device_name}
    log    Enter AXOS_E72_PARENT-TC-1754 teardown
    cli    n1_session1    configure
    cli    n1_session1    hostname ${device_name}
    cli    n1_session1    end

    # Delete the local session created
    Session destroy local    h1_localsession_server1
