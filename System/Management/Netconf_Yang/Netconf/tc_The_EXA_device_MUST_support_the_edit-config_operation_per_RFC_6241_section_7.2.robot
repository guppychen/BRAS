*** Settings ***
Documentation     The EXA device MUST support the edit-config operation per RFC 6241 section 7.2
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=asamband
Resource          base.robot
Test Setup        RLT_TC_747 setup
Test Teardown     RLT_TC_747 teardown

*** Variables ***
${newip1}         192.168.33.10
${newip2}         172.23.41.11

*** Test Cases ***
The EXA device MUST support the edit-config operation per RFC 6241 section 7.2
    [Documentation]    The default operation is to merge the specified configuration with the target configuration datastore. Other options that can be specified include: replace, create, delete, remove.
    [Tags]    @priority=p1    @tcid=AXOS_E72_PARENT-TC-1752        @globalid=2322283
    Log    *** Create name server entry***
    ${step1}=    Netconf Edit Config    n1_session3    ${netconf.nameserver10}    target=running
    Should Contain    ${step1.xml}    ok
    Log    *** Attempt to update the configuration with a new ip address using the merge to create another entry ***
    ${step2}=    Netconf Edit Config    n1_session3    ${netconf.nameserver11}    target=running
    Should Contain    ${step2.xml}    ok
    Log    *** Get the config and verify the merge was successful***
    ${step3}=    Netconf Get Config    n1_session3    filter_type=xpath \ \    filter_criteria=//craft
    Should Contain    ${step3.xml}    ${newip1}    ${newip2}
    Log    *** Delete the entry that was just created ***
    ${step4}=    Netconf Edit Config    n1_session3    ${netconf.delete11}    target=running
    Should Contain    ${step4.xml}    ok
    Log    *** Get the config and verify the delete was successful ***
    ${step5}=    Netconf Get Config    n1_session3    filter_type=xpath \ \    filter_criteria=//craft
    Should Not Contain    ${step5.xml}    ${newip2}
    Log    *** Attempt to delete the same entry again and should get error ***
    ${step6}=    Netconf Edit Config    n1_session3    ${netconf.delete11}    target=running
    Should Contain    ${step6.xml}    error
    Log    *** use the replace to modify an entry. \ Since there are two slots it creates an entry ***
    ${step7}=    Netconf Edit Config    n1_session3    ${netconf.replace11}    target=running
    Should Contain    ${step7.xml}    ok
    Log    *** Verify that both the entries are present ***
    ${step8}=    Netconf Get Config    n1_session3    filter_type=xpath \ \    filter_criteria=//craft
    Should Contain    ${step8.xml}    ${newip1}    ${newip2}
    Log    *** remove both entries ***
    ${step9}=    Netconf Edit Config    n1_session3    ${netconf.removeboth}    target=running
    Should Contain    ${step9.xml}    ok
    Log    *** Remove both the entries again ***
    ${step10}=    Netconf Edit Config    n1_session3    ${netconf.removeboth}    target=running
    Should Contain    ${step10.xml}    ok
    Log    *** Attempt to delete both and should get an error ***
    ${step11}=    Netconf Edit Config    n1_session3    ${netconf.deleteboth}    target=running
    Should Contain    ${step11.xml}    error
    Log    *** create the entry ***
    ${step12}=    Netconf Edit Config    n1_session3    ${netconf.nameserver10}    target=running
    Should Contain    ${step12.xml}    ok
    Log    *** create the same entry again, should get an error ***
    ${step13}=    Netconf Edit Config    n1_session3    ${netconf.create10}    target=running
    Should Contain    ${step13.xml}    error

*** Keywords ***
RLT_TC_747 setup   
	log    Enter RLT_TC_747
	
RLT_TC_747 teardown  
	log    Enter RLT_TC_747
	Netconf Raw    n1_session3    xml=${netconf.close_session}
