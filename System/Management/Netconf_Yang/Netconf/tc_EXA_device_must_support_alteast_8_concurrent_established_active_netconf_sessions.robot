*** Settings ***
Documentation     EXA device must support the 8 concurrent session established/active NETCONF sessions.
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=asamband
Resource          base.robot    
Test Setup        RLT_TC_736 setup
Test Teardown     RLT_TC_736 teardown

*** Variables ***

*** Test Cases ***
EXA device must support alteast 8 concurrent established/active netconf sessions.
    [Documentation]    Open netconf session: ssh <user> @ <ip> -p 830 -s netconf.
    ...    Repeat until all 8 sessions are open concurrently.
    [Tags]    @priority=p1      @user=root   @tcid=AXOS_E72_PARENT-TC-1787   @jira=EXA-25933    @globalid=2322318
    ${conn}=    Session copy info    n1_session3    user=sysadmin    password=sysadmin
    Session build local    n1_localsession1    ${conn}
    Session build local    n1_localsession2    ${conn}
    Session build local    n1_localsession3    ${conn}
    Session build local    n1_localsession4    ${conn}
    Session build local    n1_localsession5    ${conn}
    Session build local    n1_localsession6    ${conn}
    Session build local    n1_localsession7    ${conn}
    Session build local    n1_localsession8    ${conn}
    
    # [AT-666] added by cgao for other seesion not closed
    # close the netconf session
    cli    n1_session2    netstat -apn | grep 830
    Raw netconf configure    n1_session3    ${netconf.close_session}    ok
    cli    n1_session2    netstat -apn | grep 830   
    # [AT-666] added by cgao for other seesion not closed
    
    
    ${session1}=    Netconf Raw    n1_localsession1    xml=${netconf.copycmd}
    Should Contain    ${session1.xml}    ok
    ${session2}=    Netconf Raw    n1_localsession2    xml=${netconf.copycmd}
    Should Contain    ${session2.xml}    ok
    ${session3}=    Netconf Raw    n1_localsession3    xml=${netconf.copycmd}
    Should Contain    ${session3.xml}    ok
    ${session4}=    Netconf Raw    n1_localsession4    xml=${netconf.copycmd}
    Should Contain    ${session4.xml}    ok
    ${session5}=    Netconf Raw    n1_localsession5    xml=${netconf.copycmd}
    Should Contain    ${session5.xml}    ok
    ${session6}=    Netconf Raw    n1_localsession6    xml=${netconf.copycmd}
    Should Contain    ${session6.xml}    ok
    ${session7}=    Netconf Raw    n1_localsession7    xml=${netconf.copycmd}
    Should Contain    ${session7.xml}    ok
    ${session8}=    Netconf Raw    n1_localsession8    xml=${netconf.copycmd}
    Should Contain    ${session8.xml}    ok
    Cli    n1_session2    cli
    ${user}=    command    n1_session2    show user-sessions
    ${sessions}=    Get Lines Containing String    ${user}    session-id
    ${total_users}=    Get Line Count    ${sessions}
    Run Keyword If    ${total_users}<8    Fail

*** Keywords ***
RLT_TC_736 setup
    [Documentation]    Establish 8 concurrent Netconf session
	log    Enter RLT_TC_736
	
RLT_TC_736 teardown
    [Documentation]    
	log    Enter RLT_TC_736
	session destroy local    n1_localsession1
    session destroy local    n1_localsession2
	session destroy local    n1_localsession3
    session destroy local    n1_localsession4
	session destroy local    n1_localsession5
    session destroy local    n1_localsession6
	session destroy local    n1_localsession7
    session destroy local    n1_localsession8
	Disconnect    n1_session2
