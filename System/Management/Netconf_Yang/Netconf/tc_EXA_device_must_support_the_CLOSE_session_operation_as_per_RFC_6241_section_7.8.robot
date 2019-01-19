*** Settings ***
Documentation     EXA device must support the CLOSE session operation as per RFC 6241 section 7.8
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=asamband
Resource          base.robot
Test Setup        RLT_TC_749 setup
Test Teardown     RLT_TC_749 teardown

*** Variables ***

*** Test Cases ***
EXA device must support the CLOSE session operation as per RFC 6241 section 7.8
    [Documentation]    The user initiating the session must have the permission to do the close operation. The close rpc will close the current session.
    [Tags]    @priority=p1    @tcid=AXOS_E72_PARENT-TC-1758        @globalid=2322289
    [Timeout]
    ${step1}=    Netconf Raw    n1_session3    xml=${netconf.close_session}
    Should Contain    ${step1.xml}    ok

*** Keywords ***
RLT_TC_749 setup   
	log    Enter RLT_TC_749
	
RLT_TC_749 teardown  
	log    Enter RLT_TC_749