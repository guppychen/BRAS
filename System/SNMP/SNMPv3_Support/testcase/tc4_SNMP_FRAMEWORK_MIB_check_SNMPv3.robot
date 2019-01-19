*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc4_SNMP_FRAMEWORK_MIB_check_SNMPv3
    [Documentation]    SNMP-FRAMEWORK-MIB
    [Tags]    @author=Philar Guo    @globalid=2373811     @tcid=AXOS_E72_PARENT-TC-2721    @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup

    ${snmpEngineID}=   snmp get   n_snmp_v3    snmpEngineID
    log   ${snmpEngineID}
    should be equal   ${snmpEngineID}    0x80001f8880b22eb613fe8f795100000000

    ${snmpEngineID1}=   snmp get   n_snmp_v3_auth_1    snmpEngineID
    log   ${snmpEngineID1}
    should be equal   ${snmpEngineID1}    0x80001f8880b22eb613fe8f795100000000

    ${snmpEngineID2}=   snmp get   n_snmp_v3_auth_2    snmpEngineID
    log   ${snmpEngineID2}
    should be equal   ${snmpEngineID2}    0x80001f8880b22eb613fe8f795100000000

    ${snmpEngineID3}=   snmp get   n_snmp_v3_auth_priv_3    snmpEngineID
    log   ${snmpEngineID3}
    should be equal   ${snmpEngineID3}    0x80001f8880b22eb613fe8f795100000000

    ${snmpEngineID4}=   snmp get   n_snmp_v3_auth_priv_4    snmpEngineID
    log   ${snmpEngineID4}
    should be equal   ${snmpEngineID4}    0x80001f8880b22eb613fe8f795100000000

    ${snmpEngineID5}=   snmp get   n_snmp_v3_auth_priv_5    snmpEngineID
    log   ${snmpEngineID5}
    should be equal   ${snmpEngineID5}    0x80001f8880b22eb613fe8f795100000000

    ${snmpEngineID6}=   snmp get   n_snmp_v3_auth_priv_6    snmpEngineID
    log   ${snmpEngineID6}
    should be equal   ${snmpEngineID6}    0x80001f8880b22eb613fe8f795100000000



    ${snmpEngineBoots}=   snmp get   n_snmp_v3    snmpEngineBoots
    log   ${snmpEngineBoots}
    should be true   ${snmpEngineBoots}>=1

    ${snmpEngineBoots1}=   snmp get   n_snmp_v3_auth_1    snmpEngineBoots
    log   ${snmpEngineBoots1}
    should be true   ${snmpEngineBoots1}>=1

    ${snmpEngineBoots2}=   snmp get   n_snmp_v3_auth_2    snmpEngineBoots
    log   ${snmpEngineBoots2}
    should be true   ${snmpEngineBoots2}>=1

    ${snmpEngineBoots3}=   snmp get   n_snmp_v3_auth_priv_3    snmpEngineBoots
    log   ${snmpEngineBoots3}
    should be true   ${snmpEngineBoots3}>=1

    ${snmpEngineBoots4}=   snmp get   n_snmp_v3_auth_priv_4    snmpEngineBoots
    log   ${snmpEngineBoots4}
    should be true   ${snmpEngineBoots4}>=1

    ${snmpEngineBoots5}=   snmp get   n_snmp_v3_auth_priv_5    snmpEngineBoots
    log   ${snmpEngineBoots5}
    should be true   ${snmpEngineBoots5}>=1

    ${snmpEngineBoots6}=   snmp get   n_snmp_v3_auth_priv_6    snmpEngineBoots
    log   ${snmpEngineBoots6}
    should be true   ${snmpEngineBoots6}>=1



    ${snmpEngineTime}=   snmp get   n_snmp_v3    snmpEngineTime
    log   ${snmpEngineTime}
    should be true   ${snmpEngineTime}>=1

    ${snmpEngineTime1}=   snmp get   n_snmp_v3_auth_1    snmpEngineTime
    log   ${snmpEngineTime1}
    should be true   ${snmpEngineTime1}>=1

    ${snmpEngineTime2}=   snmp get   n_snmp_v3_auth_2    snmpEngineTime
    log   ${snmpEngineTime2}
    should be true   ${snmpEngineTime2}>=1

    ${snmpEngineTime3}=   snmp get   n_snmp_v3_auth_priv_3    snmpEngineTime
    log   ${snmpEngineTime3}
    should be true   ${snmpEngineTime3}>=1

    ${snmpEngineTime4}=   snmp get   n_snmp_v3_auth_priv_4    snmpEngineTime
    log   ${snmpEngineTime4}
    should be true   ${snmpEngineTime4}>=1

    ${snmpEngineTime5}=   snmp get   n_snmp_v3_auth_priv_5    snmpEngineTime
    log   ${snmpEngineTime5}
    should be true   ${snmpEngineTime5}>=1

    ${snmpEngineTime6}=   snmp get   n_snmp_v3_auth_priv_6    snmpEngineTime
    log   ${snmpEngineTime6}
    should be true   ${snmpEngineTime6}>=1



    ${snmpEngineMaxMessageSize}=   snmp get   n_snmp_v3    snmpEngineMaxMessageSize
    log   ${snmpEngineMaxMessageSize}
    should be equal   ${snmpEngineMaxMessageSize}    1500

    ${snmpEngineMaxMessageSize1}=   snmp get   n_snmp_v3_auth_1    snmpEngineMaxMessageSize
    log   ${snmpEngineMaxMessageSize1}
    should be equal   ${snmpEngineMaxMessageSize1}   1500

    ${snmpEngineMaxMessageSize2}=   snmp get   n_snmp_v3_auth_2    snmpEngineMaxMessageSize
    log   ${snmpEngineMaxMessageSize2}
    should be equal   ${snmpEngineMaxMessageSize2}   1500

    ${snmpEngineMaxMessageSize3}=   snmp get   n_snmp_v3_auth_priv_3    snmpEngineMaxMessageSize
    log   ${snmpEngineMaxMessageSize3}
    should be equal   ${snmpEngineMaxMessageSize3}   1500

    ${snmpEngineMaxMessageSize4}=   snmp get   n_snmp_v3_auth_priv_4    snmpEngineMaxMessageSize
    log   ${snmpEngineMaxMessageSize4}
    should be equal   ${snmpEngineMaxMessageSize4}   1500

    ${snmpEngineMaxMessageSize5}=   snmp get   n_snmp_v3_auth_priv_5    snmpEngineMaxMessageSize
    log   ${snmpEngineMaxMessageSize5}
    should be equal   ${snmpEngineMaxMessageSize5}   1500

    ${snmpEngineMaxMessageSize6}=   snmp get   n_snmp_v3_auth_priv_6    snmpEngineMaxMessageSize
    log   ${snmpEngineMaxMessageSize6}
    should be equal   ${snmpEngineMaxMessageSize6}   1500


    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown
