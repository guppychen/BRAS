*** Settings ***
Documentation     Suite description
Resource          ../base.robot

*** Keywords ***
check_ntp_status
    [Arguments]    ${device}    ${ntp_staus}
    ${result}    cli    ${device}    show ntp
    ${res1}    Get Lines Containing String    ${result}    ntpd-status
    Should contain    ${res1}    ${ntp_staus}

check_ntp_server
    [Arguments]    ${device}    ${server_ip}    ${connection_status}    ${synchronize_status}    ${source_status}
    ${result}    cli    ${device}    show ntp server ${server_ip}
    ${res1}    Get Lines Containing String    ${result}    remote-reference-id
    ${res2}    Get Lines Containing String    ${result}    connection-status
    ${res3}    Get Lines Containing String    ${result}    synchronize-status
    ${res4}    Get Lines Containing String    ${result}    source-status
    should Match Regexp    ${res1}    (\\d*\.\\d*\.\\d*\.\\d)
    Should contain    ${res2}    ${connection_status}
    Should contain    ${res3}    ${synchronize_status}
    Should contain    ${res4}    ${source_status}

get_device_clock
    [Arguments]    ${device}
    ${result}    cli    ${device}    show clock
    ${time}    Get Regexp Matches    ${result}    (\\d\\d\\d\\d-\\d\\d-\\d\\d\\s+\\d\\d:\\d\\d:\\d\\d)
    [Return]    ${time}[0]

vlan_configure
    [Arguments]    ${device}    ${vlan_id}    ${conf_cmd}
    [Documentation]    vlan_confirure
    [Tags]    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    vlan ${vlan_id}
    cli    ${device}    ${conf_cmd}
    [Teardown]    cli    ${device}    end

interface_configure
    [Arguments]    ${device}    ${port_type}    ${port-id}    ${conf_cmd}
    [Documentation]    interface_confirure
    [Tags]    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    interfaces ${port_type} ${port-id}
    cli    ${device}    ${conf_cmd}
    [Teardown]    cli    ${device}    end

check_mac_able
    [Documentation]    check_mac_table
    [Tags]    @author=Anneli

check_run_configure
    [Documentation]    check_mac_table
    [Tags]    @author=Anneli

check_discovered_ont

check_ont_linkage

check_ont_status

class_map_ethernet_configure
    [Arguments]    ${device}
    [Documentation]    class_map_ethernet_configure
    [Tags]    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    class-map ethernet ${class_map_name}
    cli    ${device}    flow ${flow_id}
    cli    ${device}    ${rule_conf_cmd}
    [Teardown]    cli    ${device}    end

policy_map_configure
    [Documentation]    policy_map_configure
    [Tags]    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    policy-map ${policy_map_name}
    cli    ${device}    flow ${flow_id}
    cli    ${device}    ${action_cmd}
    [Teardown]    cli    ${device}    end

ont_ethernet_port_l2_provision
    [Documentation]    ont_ethernet_port_l2_provision
    [Tags]    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    interfaces ${port_type} ${port-id}
    cli    ${device}    ${conf_cmd}    #configure_on_vlan    #    [Arguments]    ${device}
    ...    # ${vlan_id}    ${dhcp_profile}=none    ${igmp_profile}=none    ${igmp_profile}=none    # ${igmp_profile}=none    ${igmp_profile}=none
    ...    # ${igmp_profile}=none    #    [Documentation]    configure on vlan    #    [Tags]
    ...    # @author=Anneli    #    &{vlan_configure}    create dictionary    dhcp_profile=none    igmp_profile=none
    ...    # pppoe_profile=none    mac_learn=none    # mode=none    #    ...    ipsv=none
    ...    # mff=none    access_group=none    egress_broadcast_flood=none    egress_unknown_multicast_flood=none    # egress_unknown_unicast_flood=none
    #    ...    l3_service=none
    #    ${vlan_configure.dhcp_profile}    set variable    ${dhcp_profile}
    #    ${vlan_configure.igmp_profile}    set variable    ${igmp_profile}
    #    ${vlan_configure.pppoe_profile}    set variable    ${pppoe_profile}
    #    ${vlan_configure.mac_learn}    set variable    ${mac_learn}
    #    ${vlan_configure.mode}    set variable    ${mode}
    #    ${vlan_configure.ipsv}    set variable    ${ipsv}
    #    ${vlan_configure.mff}    set variable    ${mff}
    #    ${vlan_configure.access_group}    set variable    ${access_group}
    #    ${vlan_configure.egress_broadcast_flood}    set variable    ${egress_broadcast_flood}
    #    ${vlan_configure.egress_unknown_multicast_flood}    set variable    ${egress_unknown_multicast_flood}
    #    ${vlan_configure.egress_unknown_unicast_flood}    set variable    ${egress_unknown_unicast_flood}
    #    cli    ${device}    configure
    #    cli    ${device}    vlan ${vlanid}
    #    run keyword if    "${vlan_configure.dhcp_profile}"!="none" and "${vlan_configure.dhcp_profile}"!="no"    cli    ${device}    l2-dhcp-profile ${vlan_configure.dhcp_profile}
    #    run keyword if    "${vlan_configure.dhcp_profile}"!="none" and "${vlan_configure.dhcp_profile}"=="no"    cli    ${device}    no l2-dhcp-profile
    #    run keyword if    "${vlan_configure.igmp_profile}"!="none" and "${vlan_configure.igmp_profile}"!="no"    cli    ${device}    igmp-profile ${vlan_configure.igmp_profile}
    #    run keyword if    "${vlan_configure.igmp_profile}"!="none" and "${vlan_configure.igmp_profile}"=="no"    cli    ${device}    no igmp-profile
    #    run keyword if    "${vlan_configure.pppoe_profile}"!="none" and "${vlan_configure.pppoe_profile}"!="no"    cli    ${device}    pppoe-ia-id-profile ${vlan_configure.pppoe_profile}
    #    run keyword if    "${vlan_configure.pppoe_profile}"!="none" and "${vlan_configure.pppoe_profile}"=="no"    cli    ${device}    no pppoe-ia-id-profile
    #    run keyword if    "${vlan_configure.mac_learn}"!="none" and "${vlan_configure.mac_learn}"!="no"    cli    ${device}    mac-learning ${vlan_configure.mac_learn}
    #    run keyword if    "${vlan_configure.mac_learn}"!="none" and "${vlan_configure.mac_learn}"=="no"    cli    ${device}    no mac-learning
    #    run keyword if    "${vlan_configure.mode}"!="none" and "${vlan_configure.mode}"!="no"    cli    ${device}    mode ${vlan_configure.mode}
    #    run keyword if    "${vlan_configure.mode}"!="none" and "${vlan_configure.mode}"=="no"    cli    ${device}    no mode
    #    run keyword if    "${vlan_configure.ipsv}"!="none" and "${vlan_configure.ipsv}"!="no"    cli    ${device}    security source-verify ${vlan_configure.ipsv}
    #    run keyword if    "${vlan_configure.ipsv}"!="none" and "${vlan_configure.ipsv}"=="no"    cli    ${device}    no security source-verify
    #    run keyword if    "${vlan_configure.mff}"!="none" and "${vlan_configure.mff}"!="no"    cli    ${device}    security mff ${vlan_configure.mff}
    #    run keyword if    "${vlan_configure.mff}"!="none" and "${vlan_configure.mff}"=="no"    cli    ${device}    no security mff
    #    [Teardown]    cli    ${device}    end
    [Teardown]    cli    ${device}    end

prov_vlan
    [Arguments]    ${device}    ${vlan}    ${l2-dhcp-profile}=${EMPTY}    ${igmp-profile}=${EMPTY}    ${pppoe-ia-id-profile}=${EMPTY}    ${mac-learning}=${EMPTY}
    ...    ${mode}=${EMPTY}    ${source-verify}=${EMPTY}    ${mff}=${EMPTY}    ${option}=${EMPTY}
    [Documentation]    Description: provision vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |device | device name setting in your yaml |
    ...    |vlan | vlan id |
    ...    |l2-dhcp-profile| l2-dhcp-profile name|
    ...    |igmp-profile |igmp-profile name |
    ...    |pppoe-ia-id-profile |pppoe-ia-id-profile name |
    ...    |mac-learning| enable/disable |
    ...    |mode |mode of vlan |
    ...    |source-verify | enable/disable |
    ...    |mff | enable /disable|
    ...    |option | more option|
    ...
    ...    Example:
    ...    | prov_vlan | n1 | 100|l2-dhcp-profile=pro1|mac-learning=enable|
    [Tags]    @author=Anneli
    ${cmd_str}    set variable    vlan ${vlan}
    ${cmd_str}    Set Variable If    '${l2-dhcp-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} l2-dhcp-profile ${l2-dhcp-profile}
    ${cmd_str}    Set Variable If    '${igmp-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} igmp-profile ${igmp-profile}
    ${cmd_str}    Set Variable If    '${pppoe-ia-id-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} pppoe-ia-id-profile ${pppoe-ia-id-profile}
    ${cmd_str}    Set Variable If    '${mac-learning}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mac-learning ${mac-learning}
    ${cmd_str}    Set Variable If    '${mode}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mode ${mode}
    ${cmd_str}    Set Variable If    '${source-verify }'=='${EMPTY}' or '${mff}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} security
    ${cmd_str}    Set Variable If    '${source-verify }'=='${EMPTY}'    ${cmd_str}    ${cmd_str} source-verify ${source-verify }
    ${cmd_str}    Set Variable If    '${mff}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mff ${mff}
    ${cmd_str}    Set Variable If    '${option}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${option}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}
    #prov_vlan
    #    [Arguments]    ${device}    ${vlan_id}    &{option}
    #
    #    ${key}    get_dict_key    == l2-dhcp-profile
    #    if    key == l2-dhcp-profile    ${cmd_str}    dchp-profile dict[l2-dhcp-profile]
    #
    #    ${cmd_str}    run kwd if    '${option}'!='${EMPTY}'    dic_to_string    ${option}
    #    Axos Cli With Error Check    ${device}    vlan ${vlanid} ${cmd_str}
    #
    #prov_vlan    n1    100    l2-dhcp-profile=test    igmp-profile=igmp    security=source-verify ENABLED mff ENABLED
    #dprov_vlan
    #    [Arguments]    ${device}    ${vlan_id}    ${l2-dhcp-profile}=${EMPTY}    ${igmp-profile}=${EMPTY}    ${pppoe-ia-id-profile}=${EMPTY}
    ...    # ${mac_learn}=${EMPTY}
    #    ...    ${mode}=${EMPTY}    ${ipsv}=${EMPTY}    ${mff}=${EMPTY}    ${option}=${EMPTY}
    #    [Documentation]    deprovision vlan
    #    [Tags]    @author=Anneli    @author=Anneli
    #    cli    ${device}    configure
    #    cli    ${device}    vlan ${vlanid}
    #    run keyword if    "${dhcp_profile}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    no l2-dhcp-profile
    #    run keyword if    "${igmp_profile}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    no igmp-profile
    #    run keyword if    "${pppoe_profile}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    no pppoe-ia-id-profile
    #    run keyword if    "${mac_learn}"!="${EMPTY}"    Axos Cli With Error Check    ${
    #
    #    device}    no mac-learning
    #    run keyword if    "${mode}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    no mode
    #    run keyword if    "${ipsv}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    no security source-verify
    #    run keyword if    "${mff}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    no security mff
    #    run keyword if    "${option}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    no ${option}
    #    cli    ${device}    exit
    #    run keyword if    "${dhcp_profile}"=="${EMPTY}" and "${igmp_profile}"=="${EMPTY}" and "${pppoe_profile}"=="${EMPTY}" and "${mac_learn}"=="${EMPTY}" and "${mode}"=="${EMPTY}" and "${ipsv}"=="${EMPTY}" and "${mff}"=="${EMPTY}" and "${option}"=="${EMPTY}"    Axos Cli With Error Check    ${device}    no vlan ${vlanid}
    #    [Teardown]    cli    ${device}    end
    [Teardown]    cli    ${device}    end

prov_ont
    [Arguments]    ${device}    ${ont_id}    ${profile_id}=none    ${serial_number}=none    ${vendor_id}=none
    [Documentation]    provision ont
    [Tags]    @author=Anneli    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    ont ${ont_id}
    run keyword if    "${profile_id}"!="none"    Axos Cli With Error Check    ${device}    profile-id ${profile_id}
    run keyword if    "${serial_number}"!="none"    Axos Cli With Error Check    ${device}    serial-number ${serial_number}
    run keyword if    "${vendor_id}"!="none"    Axos Cli With Error Check    ${device}    vendor-id ${vendor_id}
    [Teardown]    cli    ${device}    end

dprov_ont
    [Arguments]    ${device}    ${ont_id}    ${profile_id}=none    ${serial_number}=none    ${vendor_id}=none
    [Documentation]    deprovision ont
    [Tags]    @author=Anneli    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    ont ${ont_id}
    run keyword if    "${profile_id}"!="none" and "${profile_id}"=="no"    Axos Cli With Error Check    ${device}    no profile-id
    run keyword if    "${serial_number}"!="none" and "${serial_number}"=="no"    Axos Cli With Error Check    ${device}    no serial-number
    run keyword if    "${vendor_id}"!="none" and"${vendor_id}"=="no"    Axos Cli With Error Check    ${device}    no vendor-id
    cli    ${device}    exit
    run keyword if    "${profile_id}"=="none" and "${serial_number}"=="none" and "${vendor_id}"=="none"    Axos Cli With Error Check    ${device}    no ont ${ont_id}
    [Teardown]    cli    ${device}    end

prov_class_map
    [Arguments]    ${device}    ${class-map}    ${l2-dhcp-profile}=${EMPTY}    ${igmp-profile}=${EMPTY}    ${pppoe-ia-id-profile}=${EMPTY}    ${mac-learning}=${EMPTY}
    ...    ${mode}=${EMPTY}    ${source-verify }=${EMPTY}    ${mff}=${EMPTY}    ${option}=${EMPTY}
    [Documentation]    Description: provision vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |device | device name setting in your yaml |
    ...    |vlan | vlan id |
    ...    |l2-dhcp-profile| l2-dhcp-profile name|
    ...    |igmp-profile |igmp-profile name |
    ...    |pppoe-ia-id-profile |pppoe-ia-id-profile name |
    ...    |mac-learning| enable/disable |
    ...    |mode |mode of vlan |
    ...    |source-verify | enable/disable |
    ...    |mff | enable /disable|
    ...    |option | more option|
    ...
    ...    Example:
    ...    | prov_vlan | n1 | 100|l2-dhcp-profile=pro1|mac-learning=enable|
    [Tags]    @author=Anneli
    ${cmd_str}    set variable    vlan ${vlan}
    ${cmd_str}    Set Variable If    '${l2-dhcp-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} l2-dhcp-profile ${l2-dhcp-profile}
    ${cmd_str}    Set Variable If    '${igmp-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} igmp-profile ${igmp-profile}
    ${cmd_str}    Set Variable If    '${pppoe-ia-id-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} pppoe-ia-id-profile ${pppoe-ia-id-profile}
    ${cmd_str}    Set Variable If    '${mac-learning}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mac-learning ${mac-learning}
    ${cmd_str}    Set Variable If    '${mode}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mode ${mode}
    ${cmd_str}    Set Variable If    '${source-verify }'=='${EMPTY}' or '${mff}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} security
    ${cmd_str}    Set Variable If    '${source-verify }'=='${EMPTY}'    ${cmd_str}    ${cmd_str} source-verify ${source-verify }
    ${cmd_str}    Set Variable If    '${mff}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mff ${mff}
    ${cmd_str}    Set Variable If    '${option}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${option}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}

prov_interface_ont_ethernet
    [Arguments]    ${device}    ${ont-ethport}    ${role}    ${disable-when-on-battery}    ${dscp-map}    ${duplex}
    ...    ${mac-limit}    ${mac-limit}
    [Tags]    @author=Anneli
    ${rmon-session}    ${alarm-suppression}    ${bandwidth egress maximum}    ${subscriber-id}    ${description}
    ${cmd_str}    set variable    interface ont-ethernet ${ont-ethport}
    ${cmd_str}    Set Variable If    '${role}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} role ${role}
    ${cmd_str}    Set Variable If    '${disable-when-on-battery}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} disable-when-on-battery ${disable-when-on-battery}
    ${cmd_str}    Set Variable If    '${dscp-map}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} dscp-map ${dscp-map}
    ${cmd_str}    Set Variable If    '${duplex}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} duplex ${duplex}
    ${cmd_str}    Set Variable If    '${mac-limit}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mac-limit ${mac-limit}
    ${cmd_str}    Set Variable If    '${rmon-session}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} rmon-session    ${rmon-session }
    ${cmd_str}    Set Variable If    '${alarm-suppression}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} alarm-suppression ${alarm-suppression}
    ${cmd_str}    Set Variable If    '${bandwidth egress maximum}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} bandwidth egress maximum ${bandwidth egress maximum}
    ${cmd_str}    Set Variable If    '${subscriber-id}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} subscriber-id ${subscriber-id}
    ${cmd_str}    Set Variable If    '${description}'=='${EMPTY}'    ${cmd_str} description ${description}
    ${cmd_str}    Set Variable If    '${shutdown}'=='${EMPTY}'    ${cmd_str} shutdown
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

prov_service_on_interface_ont_ethernet
    [Tags]    @author=Anneli
    cli    ${device}    configure
    cli    ${device}    interface ont-ethernet ${ont-ethport} vlan ${vlan}
    ${cmd_str}    set variable    interface ont-ethernet ${ont-ethport}    vlan ${vlan}
    ${cmd_str}    Set Variable If    '${policy-map}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} policy-map ${policy-map}
    Axos Cli With Error Check    ${device}    ${cmd_str}
    ${cmd_str}    Set Variable If    '${class-map-ethernet}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} class-map-ethernet ${class-map-ethernet}
    ${cmd_str}    Set Variable If    '${flow}'=='${EMPTY}'    ${cmd_str}    ${cmd_str}    flow ${flow}
    ${cmd_str}    Set Variable If    '${ingress-meter}'=='${EMPTY}'    ${cmd_str}    ingress-meter ${ingress-meter}
