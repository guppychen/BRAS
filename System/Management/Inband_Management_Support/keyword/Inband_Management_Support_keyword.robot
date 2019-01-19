*** Settings ***
Documentation    test_suite keyword lib
Resource    ../base.robot
*** Variable ***


*** Keywords ***
prov_interface_vlan
    [Arguments]    ${device}    ${vlan_id}    ${ip_adress}=${EMPTY}    ${prefix}=${EMPTY}    ${dhcp}=No
    [Documentation]    create interface vlan
    [Tags]    @author=Ronnie_Yi
    prov_vlan   ${device}    ${vlan_id}
    cli    ${device}    configure
    run keyword if    '${dhcp}'=='No'    Axos Cli With Error Check    ${device}    interface vlan ${vlan_id} ip address ${ip_adress}/${prefix}
    ...    ELSE IF    '${dhcp}'=='Yes'    Axos Cli With Error Check    ${device}    interface vlan ${vlan_id} ip address dhcp
    Axos Cli With Error Check    ${device}    no sh
    [Teardown]    cli    ${device}    end

prov_ip_route
    [Arguments]    ${device}    ${next_hop_ip_adress}
    [Documentation]    create ip route
    [Tags]    @author=Yeast_Jiang
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ip route 0.0.0.0/0 next-hop ${next_hop_ip_adress}
    [Teardown]    cli    ${device}    end


send_ping_and_check_no_loss
    [Arguments]    ${device}    ${ping_ip}
    [Documentation]    send ping
    [Tags]    @author=Ronnie_Yi
    ${result}   Axos Cli With Error Check    ${device}    ping ${ping_ip} -c 1
    should not contain    ${result}     100% packet loss
    should contain    ${result}     0% packet loss


send_ping_and_check_fail
    [Arguments]    ${device}    ${ping_ip}
    [Documentation]    send ping
    [Tags]    @author=Ronnie_Yi
    ${result}   Axos Cli With Error Check    ${device}    ping ${ping_ip} -c 1
    should contain    ${result}    Network is unreachable

check_interface_vlan_mac_address
    [Arguments]    ${device}    ${vlan_id}
    [Documentation]    check mac address
    [Tags]    @author=Yeast_Jiang
    ${result}    Axos Cli With Error Check    ${device}   show interface vlan ${vlan_id}
    ${list1}    Get Regexp Matches    ${result}       mac-addr\\s+(\\S+)
    ${result}    Axos Cli With Error Check    ${device}   show inventory
    ${list2}    Get Regexp Matches    ${result}       mac\\s+(\\S+)
    ${result1}      set variable    ${list1}[1]
    ${result2}      set variable    ${list1}[1]
    Should Be Equal    ${result1}    ${result2}


check_interface_vlan_status
    [Arguments]    ${device}    ${vlan_id}    ${ip_address}    ${prefix}
    [Documentation]    check mac address
    [Tags]    @author=Ronni_yi
    ${result}    Axos Cli With Error Check    ${device}   show interface vlan ${vlan_id}
    should match regexp    ${result}    vlan-id\\s+${vlan_id}
    should match regexp    ${result}    admin-state\\s+enable
    should match regexp    ${result}    oper-state\\s+up
    should match regexp    ${result}    fwd-state\\s+forwarding
    should match regexp    ${result}    ip-address\\s+ipv4\\s+${ip_address}/${prefix}
    check_interface_vlan_mac_address    ${device}    ${vlan_id}

dprov_interface_vlan
    [Arguments]    ${device}    ${vlan_id}
    [Documentation]    delete interface vlan
    [Tags]    @author=Ronnie_Yi
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface vlan ${vlan_id}
    Axos Cli With Error Check    ${device}    no ip
    Axos Cli With Error Check    ${device}    top
    Axos Cli With Error Check    ${device}    no interface vlan ${vlan_id}
    [Teardown]    cli    ${device}    end


change_interface_vlan_ip
    [Arguments]    ${device}    ${vlan_id}    ${ip_adress}=${EMPTY}    ${prefix}=${EMPTY}    ${dhcp}=No
    [Documentation]    change interface_vlan_ip
    [Tags]    @author=Ronnie_Yi
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface vlan ${vlan_id}
    Axos Cli With Error Check    ${device}    no ip
    run keyword if    '${dhcp}'=='No'    Axos Cli With Error Check    ${device}    ip address ${ip_adress}/${prefix}
    run keyword if    '${dhcp}'=='Yes'    Axos Cli With Error Check    ${device}    ip address dhcp
    [Teardown]    cli    ${device}    end


dprov_ip_route
    [Arguments]    ${device}    ${next_hop_ip_adress}
    [Documentation]    delete ip route
    [Tags]    @author=Yeast_Jiang
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    no ip route 0.0.0.0/0 next-hop ${next_hop_ip_adress}
    [Teardown]    cli    ${device}    end


check_interface_vlan_Dynamic_ip
    [Arguments]    ${device}    ${vlan_id}
    [Documentation]    check interface vlan get dynamic ip and return ip
    [Tags]    @author=Ronnie_Yi
    ${tmp}    Axos Cli With Error Check    n1_console    show interface vlan ${vlan_id}    
    ${result}    should match regexp    ${tmp}    ip-address\\s+ipv4\\s+(\\S+)/\\S+
    [Return]    ${result[1]}


change_interface_vlan_status
    [Arguments]    ${device}    ${vlan_id}    ${cmd}=${EMPTY}
    [Documentation]    check interface vlan get dynamic ip and return ip
    [Tags]    @author=Ronnie_Yi
    cli    ${device}    configure
    Axos Cli With Error Check    n1_console    interface vlan ${vlan_id}
    run keyword if    '${cmd}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd}
    [Teardown]    cli    ${device}    end