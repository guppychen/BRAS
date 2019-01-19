*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc13_SNMP_Privacy_function_check
    [Documentation]    SNMPv3 Privacy function check
    [Tags]    @author=Philar Guo    @globalid=2373820    @tcid=AXOS_E72_PARENT-TC-2730    @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup

    ${usmUserSecurityName}=   snmp get   n_snmp_v3    usmUserSecurityName.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserSecurityName}
    should be equal   ${SNMPv3_user}   ${usmUserSecurityName}

    ${usmUserSecurityName1}=   snmp get   n_snmp_v3_auth_1    usmUserSecurityName.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserSecurityName1}
    should be equal   ${SNMPv3_user_auth_1}   ${usmUserSecurityName1}

    ${usmUserSecurityName2}=   snmp get   n_snmp_v3_auth_2    usmUserSecurityName.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserSecurityName2}
    should be equal   ${SNMPv3_user_auth_2}    ${usmUserSecurityName2}

    ${usmUserSecurityName3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserSecurityName.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserSecurityName3}
    should be equal   ${SNMPv3_user_auth_priv_3}   ${usmUserSecurityName3}

    ${usmUserSecurityName4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserSecurityName.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserSecurityName4}
    should be equal   ${SNMPv3_user_auth_priv_4}   ${usmUserSecurityName4}

    ${usmUserSecurityName5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserSecurityName.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserSecurityName5}
    should be equal   ${SNMPv3_user_auth_priv_5}   ${usmUserSecurityName5}

    ${usmUserSecurityName6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserSecurityName.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserSecurityName6}
    should be equal   ${SNMPv3_user_auth_priv_6}   ${usmUserSecurityName6}


    ${usmUserCloneFrom}=   snmp get   n_snmp_v3    usmUserCloneFrom.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserCloneFrom}
    should be equal   ${usmUserCloneFrom}    SNMPv2-SMI::zeroDotZero

    ${usmUserCloneFrom1}=   snmp get   n_snmp_v3_auth_1    usmUserCloneFrom.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserCloneFrom1}
    should be equal   ${usmUserCloneFrom1}   SNMPv2-SMI::zeroDotZero

    ${usmUserCloneFrom2}=   snmp get   n_snmp_v3_auth_2    usmUserCloneFrom.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserCloneFrom2}
    should be equal   ${usmUserCloneFrom2}   SNMPv2-SMI::zeroDotZero

    ${usmUserCloneFrom3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserCloneFrom.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserCloneFrom3}
    should be equal   ${usmUserCloneFrom3}    SNMPv2-SMI::zeroDotZero

    ${usmUserCloneFrom4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserCloneFrom.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserCloneFrom4}
    should be equal   ${usmUserCloneFrom4}    SNMPv2-SMI::zeroDotZero

    ${usmUserCloneFrom5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserCloneFrom.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserCloneFrom5}
    should be equal   ${usmUserCloneFrom5}    SNMPv2-SMI::zeroDotZero

    ${usmUserCloneFrom6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserCloneFrom.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserCloneFrom6}
    should be equal   ${usmUserCloneFrom6}    SNMPv2-SMI::zeroDotZero


    ${usmUserAuthProtocol}=   snmp get   n_snmp_v3    usmUserAuthProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserAuthProtocol}
    should be equal   ${usmUserAuthProtocol}   SNMP-USER-BASED-SM-MIB::usmNoAuthProtocol

    ${usmUserAuthProtocol1}=   snmp get   n_snmp_v3_auth_1    usmUserAuthProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserAuthProtocol1}
    should be equal   ${usmUserAuthProtocol1}   SNMP-USER-BASED-SM-MIB::usmHMACMD5AuthProtocol

    ${usmUserAuthProtocol2}=   snmp get   n_snmp_v3_auth_2    usmUserAuthProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserAuthProtocol2}
    should be equal   ${usmUserAuthProtocol2}   SNMP-USER-BASED-SM-MIB::usmHMACSHAAuthProtocol

    ${usmUserAuthProtocol3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserAuthProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserAuthProtocol3}
    should be equal   ${usmUserAuthProtocol3}   SNMP-USER-BASED-SM-MIB::usmHMACMD5AuthProtocol

    ${usmUserAuthProtocol4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserAuthProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserAuthProtocol4}
    should be equal   ${usmUserAuthProtocol4}   SNMP-USER-BASED-SM-MIB::usmHMACMD5AuthProtocol

    ${usmUserAuthProtocol5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserAuthProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserAuthProtocol5}
    should be equal   ${usmUserAuthProtocol5}   SNMP-USER-BASED-SM-MIB::usmHMACSHAAuthProtocol

    ${usmUserAuthProtocol6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserAuthProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserAuthProtocol6}
    should be equal   ${usmUserAuthProtocol6}   SNMP-USER-BASED-SM-MIB::usmHMACSHAAuthProtocol


    ${usmUserAuthKeyChange}=   snmp get   n_snmp_v3    usmUserAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserAuthKeyChange}
    should be empty   ${usmUserAuthKeyChange}

    ${usmUserAuthKeyChange1}=   snmp get   n_snmp_v3_auth_1    usmUserAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserAuthKeyChange1}
    should be empty   ${usmUserAuthKeyChange1}

    ${usmUserAuthKeyChange2}=   snmp get   n_snmp_v3_auth_2    usmUserAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserAuthKeyChange2}
    should be empty   ${usmUserAuthKeyChange2}

    ${usmUserAuthKeyChange3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserAuthKeyChange3}
    should be empty   ${usmUserAuthKeyChange3}

    ${usmUserAuthKeyChange4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserAuthKeyChange4}
    should be empty   ${usmUserAuthKeyChange4}

    ${usmUserAuthKeyChange5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserAuthKeyChange5}
    should be empty   ${usmUserAuthKeyChange5}

    ${usmUserAuthKeyChange6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserAuthKeyChange6}
    should be empty   ${usmUserAuthKeyChange6}


    ${usmUserOwnAuthKeyChange}=   snmp get   n_snmp_v3    usmUserOwnAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserOwnAuthKeyChange}
    should be empty   ${usmUserOwnAuthKeyChange}

    ${usmUserOwnAuthKeyChange1}=   snmp get   n_snmp_v3_auth_1    usmUserOwnAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserOwnAuthKeyChange1}
    should be empty   ${usmUserOwnAuthKeyChange1}

    ${usmUserOwnAuthKeyChange2}=   snmp get   n_snmp_v3_auth_2    usmUserOwnAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserOwnAuthKeyChange2}
    should be empty   ${usmUserOwnAuthKeyChange2}

    ${usmUserOwnAuthKeyChange3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserOwnAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserOwnAuthKeyChange3}
    should be empty   ${usmUserOwnAuthKeyChange3}

    ${usmUserOwnAuthKeyChange4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserOwnAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserOwnAuthKeyChange4}
    should be empty   ${usmUserOwnAuthKeyChange4}

    ${usmUserOwnAuthKeyChange5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserOwnAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserOwnAuthKeyChange5}
    should be empty   ${usmUserOwnAuthKeyChange5}

    ${usmUserOwnAuthKeyChange6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserOwnAuthKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserOwnAuthKeyChange6}
    should be empty   ${usmUserOwnAuthKeyChange6}


    ${usmUserPrivProtocol}=   snmp get   n_snmp_v3    usmUserPrivProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserPrivProtocol}
    should be equal   ${usmUserPrivProtocol}   SNMP-USER-BASED-SM-MIB::usmNoPrivProtocol

    ${usmUserPrivProtocol1}=   snmp get   n_snmp_v3_auth_1    usmUserPrivProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserPrivProtocol1}
    should be equal   ${usmUserPrivProtocol1}   SNMP-USER-BASED-SM-MIB::usmNoPrivProtocol

    ${usmUserPrivProtocol2}=   snmp get   n_snmp_v3_auth_2    usmUserPrivProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserPrivProtocol2}
    should be equal   ${usmUserPrivProtocol2}   SNMP-USER-BASED-SM-MIB::usmNoPrivProtocol

    ${usmUserPrivProtocol3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserPrivProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserPrivProtocol3}
    should be equal   ${usmUserPrivProtocol3}   SNMP-USM-AES-MIB::usmAesCfb128Protocol

    ${usmUserPrivProtocol4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserPrivProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserPrivProtocol4}
    should be equal   ${usmUserPrivProtocol4}   SNMP-USER-BASED-SM-MIB::usmDESPrivProtocol

    ${usmUserPrivProtocol5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserPrivProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserPrivProtocol5}
    should be equal   ${usmUserPrivProtocol5}   SNMP-USM-AES-MIB::usmAesCfb128Protocol

    ${usmUserPrivProtocol6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserPrivProtocol.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserPrivProtocol6}
    should be equal   ${usmUserPrivProtocol6}   SNMP-USER-BASED-SM-MIB::usmDESPrivProtocol


    ${usmUserPrivKeyChange}=   snmp get   n_snmp_v3    usmUserPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserPrivKeyChange}
    should be empty   ${usmUserPrivKeyChange}

    ${usmUserPrivKeyChange1}=   snmp get   n_snmp_v3_auth_1    usmUserPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserPrivKeyChange1}
    should be empty   ${usmUserPrivKeyChange1}

    ${usmUserPrivKeyChange2}=   snmp get   n_snmp_v3_auth_2    usmUserPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserPrivKeyChange2}
    should be empty   ${usmUserPrivKeyChange2}

    ${usmUserPrivKeyChange3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserPrivKeyChange3}
    should be empty   ${usmUserPrivKeyChange3}

    ${usmUserPrivKeyChange4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserPrivKeyChange4}
    should be empty   ${usmUserPrivKeyChange4}

    ${usmUserPrivKeyChange5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserPrivKeyChange5}
    should be empty   ${usmUserPrivKeyChange5}

    ${usmUserPrivKeyChange6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserPrivKeyChange6}
    should be empty   ${usmUserPrivKeyChange6}


    ${usmUserOwnPrivKeyChange}=   snmp get   n_snmp_v3    usmUserOwnPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserOwnPrivKeyChange}
    should be empty   ${usmUserOwnPrivKeyChange}

    ${usmUserOwnPrivKeyChange1}=   snmp get   n_snmp_v3_auth_1    usmUserOwnPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserOwnPrivKeyChange1}
    should be empty   ${usmUserOwnPrivKeyChange1}

    ${usmUserOwnPrivKeyChange2}=   snmp get   n_snmp_v3_auth_2    usmUserOwnPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserOwnPrivKeyChange2}
    should be empty   ${usmUserOwnPrivKeyChange2}

    ${usmUserOwnPrivKeyChange3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserOwnPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserOwnPrivKeyChange3}
    should be empty   ${usmUserOwnPrivKeyChange3}

    ${usmUserOwnPrivKeyChange4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserOwnPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserOwnPrivKeyChange4}
    should be empty   ${usmUserOwnPrivKeyChange4}

    ${usmUserOwnPrivKeyChange5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserOwnPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserOwnPrivKeyChange5}
    should be empty   ${usmUserOwnPrivKeyChange5}

    ${usmUserOwnPrivKeyChange6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserOwnPrivKeyChange.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserOwnPrivKeyChange6}
    should be empty   ${usmUserOwnPrivKeyChange6}


    ${usmUserPublic}=   snmp get   n_snmp_v3    usmUserPublic.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserPublic}
    should be empty   ${usmUserPublic}

    ${usmUserPublic1}=   snmp get   n_snmp_v3_auth_1    usmUserPublic.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserPublic1}
    should be empty   ${usmUserPublic1}

    ${usmUserPublic2}=   snmp get   n_snmp_v3_auth_2    usmUserPublic.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserPublic2}
    should be empty   ${usmUserPublic2}

    ${usmUserPublic3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserPublic.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserPublic3}
    should be empty   ${usmUserPublic3}

    ${usmUserPublic4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserPublic.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserPublic4}
    should be empty   ${usmUserPublic4}

    ${usmUserPublic5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserPublic.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserPublic5}
    should be empty   ${usmUserPublic5}

    ${usmUserPublic6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserPublic.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserPublic6}
    should be empty   ${usmUserPublic6}


    ${usmUserStorageType}=   snmp get   n_snmp_v3    usmUserStorageType.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserStorageType}
    should be equal   ${usmUserStorageType}   nonVolatile

    ${usmUserStorageType1}=   snmp get   n_snmp_v3_auth_1    usmUserStorageType.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserStorageType1}
    should be equal   ${usmUserStorageType1}   nonVolatile

    ${usmUserStorageType2}=   snmp get   n_snmp_v3_auth_2    usmUserStorageType.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserStorageType2}
    should be equal   ${usmUserStorageType2}   nonVolatile

    ${usmUserStorageType3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserStorageType.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserStorageType3}
    should be equal   ${usmUserStorageType3}   nonVolatile

    ${usmUserStorageType4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserStorageType.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserStorageType4}
    should be equal   ${usmUserStorageType4}   nonVolatile

    ${usmUserStorageType5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserStorageType.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserStorageType5}
    should be equal   ${usmUserStorageType5}   nonVolatile

    ${usmUserStorageType6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserStorageType.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserStorageType6}
    should be equal   ${usmUserStorageType6}   nonVolatile


    ${usmUserStatus}=   snmp get   n_snmp_v3    usmUserStatus.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.7.97.117.116.111.95.118.51
    log   ${usmUserStatus}
    should be equal   ${usmUserStatus}    active

    ${usmUserStatus1}=   snmp get   n_snmp_v3_auth_1    usmUserStatus.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.49
    log   ${usmUserStatus1}
    should be equal   ${usmUserStatus1}    active

    ${usmUserStatus2}=   snmp get   n_snmp_v3_auth_2    usmUserStatus.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.14.97.117.116.111.95.118.51.95.97.117.116.104.95.50
    log   ${usmUserStatus2}
    should be equal   ${usmUserStatus2}    active

    ${usmUserStatus3}=   snmp get   n_snmp_v3_auth_priv_3    usmUserStatus.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.51
    log   ${usmUserStatus3}
    should be equal   ${usmUserStatus3}    active

    ${usmUserStatus4}=   snmp get   n_snmp_v3_auth_priv_4    usmUserStatus.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.52
    log   ${usmUserStatus4}
    should be equal   ${usmUserStatus4}    active

    ${usmUserStatus5}=   snmp get   n_snmp_v3_auth_priv_5    usmUserStatus.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.53
    log   ${usmUserStatus5}
    should be equal   ${usmUserStatus5}    active

    ${usmUserStatus6}=   snmp get   n_snmp_v3_auth_priv_6    usmUserStatus.17.128.0.31.136.128.178.46.182.19.254.143.121.81.0.0.0.0.19.97.117.116.111.95.118.51.95.97.117.116.104.95.112.114.105.118.95.54
    log   ${usmUserStatus6}
    should be equal   ${usmUserStatus6}    active

    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup



case teardown
    log    Enter case teardown