*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc11_SNMP_VACM_MIB_check_SNMPv3
    [Documentation]    SNMP-VACM_MIB
    [Tags]    @author=Philar Guo    @globalid=2373818    @tcid=AXOS_E72_PARENT-TC-2728
      ...   @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1        @jira=EXA-20444
    [Setup]    case setup
    ${vacmContextName}=   snmp get   n_snmp_v3    vacmContextName
    log   ${vacmContextName}
    should not be equal    ${vacmContextName}   ${smmp get empty response}

    ${vacmContextName1}=   snmp get   n_snmp_v3_auth_1    vacmContextName
    log   ${vacmContextName1}
    should not be equal    ${vacmContextName}   ${smmp get empty response}

    ${vacmContextName2}=   snmp get   n_snmp_v3_auth_2    vacmContextName
    log   ${vacmContextName2}
    should not be equal    ${vacmContextName}   ${smmp get empty response}

    ${vacmContextName3}=   snmp get   n_snmp_v3_auth_priv_3    vacmContextName
    log   ${vacmContextName3}
    should not be equal    ${vacmContextName}   ${smmp get empty response}

    ${vacmContextName4}=   snmp get   n_snmp_v3_auth_priv_4    vacmContextName
    log   ${vacmContextName4}
    should not be equal    ${vacmContextName}   ${smmp get empty response}

    ${vacmContextName5}=   snmp get   n_snmp_v3_auth_priv_5    vacmContextName
    log   ${vacmContextName5}
    should not be equal    ${vacmContextName}   ${smmp get empty response}

    ${vacmContextName6}=   snmp get   n_snmp_v3_auth_priv_6    vacmContextName
    log   ${vacmContextName6}
    should not be equal    ${vacmContextName}   ${smmp get empty response}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown
