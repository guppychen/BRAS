*** Settings ***
Documentation     we do support a single instance of a candidate data store. There is also the concept of checkpoint storage but that isn't accessible externally. It is also advertised in the capabilities with our hello message:
...    
...    urn:ietf:params:netconf:capability:candidate:1.0
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=gpalanis
Resource          ./base.robot

*** Variables ***
${candidate_db}    candidate.db

*** Test Cases ***
tc_EXA_Device_may_support_a_candidate_config_data_stores
    [Documentation]    Device may support a candidate config data stores
    [Tags]      @user=root   @TCID=AXOS_E72_PARENT-TC-1765   @globalid=2322296  @jira=EXA-25933

    # Verify whether candidate capabilities are under /netconf-state/capabilities
    ${output}    Netconf Get    n1_session3    filter_type=xpath    filter_criteria=/netconf-state/capabilities
    log    ${output.xml}
    Should match regexp    ${output.xml}    urn:ietf:params:netconf:capability:candidate:1.0

    # log    verify candidate data is store under /tmp/confd/candidate directory
    cli    n1_session2    cd /tmp/confd/candidate
    ${output}=    cli    n1_session2    ls -ltr
    should contain    ${output}    ${candidate_db}
