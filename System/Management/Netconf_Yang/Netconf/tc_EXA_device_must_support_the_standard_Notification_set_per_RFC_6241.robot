*** Settings ***
Documentation     EXA device must support the standard Notification set per RFC 6241 \
Test Setup        RLT_TC_759 setup
Test Teardown     RLT_TC_759 teardown
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=asamband
Resource          base.robot

*** Variables ***
${hostname}       ${new_hostname}
@{list}           <session-login>sysadmin</session-login>    <category>DBCHANGE</category>    <new-value>${hostname}</new-value>    <description>User logout from CLI/Netconf/EWI</description>

*** Test Cases ***
EXA device must support the standard Notification set per RFC 6241
    [Documentation]    Create a two netconf session, In the first netconf session to capture all the notification.
    ...    In second session, isssue all the commands. This shows a db change from candidate, from running, a login , logout and a confirmed-commit.
    [Tags]    @priority=p1     @user=root   @tcid=AXOS_E72_PARENT-TC-1815        @globalid=2322346
    ${step1}=    Netconf raw    n1_session3    xml=${netconf.notification}
    Cli    n1_session2    cli
    command    n1_session2    conf
    command    n1_session2    hostname ${hostname}
    command    n1_session2    exit
    command    n1_session2    exit
    ${step2}=    command    n1_session2    hostname
    Should Contain    ${step2}    ${hostname}
    Disconnect    n1_session2
    ${step3}=    Netconf Raw    n1_session3    xml=${netconf.capture_notification}
    : FOR    ${value}    IN    @{list}
    \    Should Contain    ${step3.xml}    ${value}
    Netconf Raw    n1_session3    ${netconf.close_session}

*** Keywords ***
RLT_TC_759 setup
    log    Enter RLT_TC_759

RLT_TC_759 teardown
    log    Enter RLT_TC_759
    # [AT-666] added by cgao, should change hostname to default value
    Cli    n1_session2    cli
    command    n1_session2    conf
    command    n1_session2    hostname ${default_hostname}
    command    n1_session2    exit
    command    n1_session2    exit
    ${step2}=    command    n1_session2    hostname
    Should Contain    ${step2}    ${default_hostname}
    # [AT-666] added by cgao, should change hostname to default value
