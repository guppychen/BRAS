*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***
${model}    NGPON2-4

*** Keywords ***
#----------------------- Common Keywords ------------------------------------#


Show Image Version

    [Documentation]     Show Device Software version		
    [Tags]	@author=aprakash
    [Arguments]     ${device}

    cli   ${device}    show version       prompt=\\#


Verify Ping

    [Documentation]     Verify ping between STC devices		
    [Tags]	@author=aprakash
    [Arguments]    ${device}     ${ipaddr}

    cli    ${device}     ping -c 5 ${ipaddr}     prompt=\\#   timeout=10
    Result Should Not Contain       100% packet loss
    Result Should Contain         5 received

Verify Pingv6

    [Documentation]     Verify ipv6 ping between STC devices		
    [Tags]	@author=aprakash
    [Arguments]    ${device}     ${ipv6addr}


    cli    ${device}     ping6 -c 5 ${ipv6addr}     prompt=\\#
    Result Should Not Contain       100% packet loss
    Result Should Contain         5 received


Verify Ping Fail

    [Documentation]     Verify failure on ping between STC devices	
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${ipaddr}

    cli    ${device}     ping -c 5 ${ipaddr}     prompt=\\#
    Result Should Contain       100% packet loss
    Result Should Not Contain         5 received

Interface_shut_calix

    [Documentation]     Shutdown the Interface			
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${port}    ${slot}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True    Interface_shut_calix_ROLT    ${device}    ${port}    ${slot}
    Run Keyword If     ${result.__contains__('E5-520')}==True    Interface_shut_calix_E5    ${device}    ${port}

Interface_shut_calix_E5

    [Documentation]     Shutdown the Interface			
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${port}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${port}
    cli    ${device}     shutdown
    cli    ${device}     end    prompt=\\#

Interface_shut_calix_ROLT

    [Documentation]     Shutdown the Interface			
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${port}   ${slot}
                                                                                                                     
    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${port}
    cli    ${device}     shutdown
    cli    ${device}     end    prompt=\\#

Interface_noshut_calix

    [Documentation]     Unshut the Interface			
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${port}    ${slot}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True    Interface_noshut_calix_ROLT    ${device}    ${port}    ${slot}
    Run Keyword If     ${result.__contains__('E5-520')}==True    Interface_noshut_calix_E5    ${device}    ${port}


Interface_noshut_calix_E5

    [Documentation]     Unshut the Interface			
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${port}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${port}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Interface_noshut_calix_ROLT

    [Documentation]     Unshut the Interface
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${port}    ${slot}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${port}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Enable Cisco

    [Documentation]     Enable in cisco device			
    [Tags]      @author=aprakash
    [Arguments]         ${device}   ${password}

    cli     ${device}     enable           prompt=\\:    timeout=10    timeout_exception=0
    cli     ${device}     ${password}      prompt=\\#    timeout=10    timeout_exception=0



#----------------------- LAG Keywords ------------------------------------#

Create LAG Group

    [Documentation]    Create static LAG interface group	
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}     ${lacp_mode}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     description ${lacp_mode}${lag_group}
    # [AT-4218] modify by Cindy, start
    cli    ${device}     switchport ENABLED
    cli    ${device}     role inni
    # [AT-4218] modify by Cindy, end
    cli    ${device}     lacp-mode ${lacp_mode}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#


Add Device Interface To LAG

    [Documentation]    Configure Interface with IPv4 address on ROLT		
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}    ${slot}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Add_Device_Interface_To_LAG_Rolt    ${device}     ${interface}      ${lag_group}    ${slot}
    # Run Keyword If     ${result.__contains__('E3-2')}==True     Add_Device_Interface_To_LAG_Rolt    ${device}     ${interface}      ${lag_group}    ${slot}
    # modify by llin AT-5076
    Run Keyword If     ${result.__contains__('E5-520')}==True   Add_Device_Interface_To_LAG_E5      ${device}     ${interface}      ${lag_group}
    # modify by llin AT-5076

Add_Device_Interface_To_LAG_Rolt

    [Documentation]    Configure Interface with IPv4 address on ROLT		
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}   ${slot}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${interface}
    cli    ${device}     switchport ENABLED 
    cli    ${device}     no role lag 
    cli    ${device}     role lag 
    # AT-5076
    cli    ${device}     system-lag ${lag_group}
    # AT-5076
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Add_Device_Interface_To_LAG_E5

    [Documentation]    Configure Interface with IPv4 address on ROLT		
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${interface}
    cli    ${device}     no service-role
    cli    ${device}     service-role lag
    cli    ${device}     group ${lag_group}
    cli    ${device}     exit
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Check LAG group

    [Documentation]    Verify LAG group is created sucessfully		
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    


    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Check_LAG_group_Rolt    ${device}    ${lag_group}
    Run Keyword If     ${result.__contains__('E5-520')}==True     Check_LAG_group_E5    ${device}    ${lag_group}

Check_LAG_group_E5

    [Documentation]    Verify LAG group is created sucessfully		
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group} 

    cli    ${device}     show interface lag members | include group
    Result Should Contain   ${lag_group}

Check_LAG_group_Rolt

    [Documentation]    Verify LAG group is created sucessfully
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group} 

    cli    ${device}     show interface lag ${lag_group} members
    Result Should Contain   ${lag_group}

Configure LAG Group Description

    [Documentation]    Configure Description for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lag_description}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     description ${lag_description}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Configure LAG Group Hash Method

    [Documentation]    Configure Hash Method for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${hash_method}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     no hash-method
    cli    ${device}     hash-method ${hash_method}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Unconfigure LAG Group Hash Method

    [Documentation]    Configure Hash Method for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     no hash-method
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Configure LAG Group Lacp Mode

    [Documentation]    Configure LACP Mode for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lacp_mode}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     lacp-mode ${lacp_mode}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Configure LAG Group Max Port

    [Documentation]    Configure Max Port for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lag_max_port}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     max-port ${lag_max_port}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Configure LAG Group Min Port

    [Documentation]    Configure Min Port for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lag_min_port}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     min-port ${lag_min_port}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Configure LAG Group Max Port Invalid

    [Documentation]    Configure Max Port for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lag_max_port}    ${str1}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    ${result} =    cli    ${device}     max-port ${lag_max_port}
    ${match}   Should Match Regexp  ${result}  Aborted.*(Maximum port count must be greater than or equal to minimum port count).*
    log  ${match[1]}
    Should Be Equal     ${match[1]}     ${str1}
    cli    ${device}     end    prompt=\\#

Configure LAG Group MTU

    [Documentation]    Configure MTU for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lag_mtu}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     mtu ${lag_mtu}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Configure LAG Group Service Role

    [Documentation]    Configure Service Role for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lag_service_role}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     role ${lag_service_role}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Check LAG Group Status

    [Documentation]    Verify the activity status for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${check_id}   	${check_value}


    cli    ${device}     show interface lag ${lag_group} status
    Result Should Contain   ${check_id} .* ${check_value}

Check Interface Added To LAG

    [Documentation]    Verify the ethernet interface added to LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}

    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Result Should Contain   ${interface}

Check LAG Interface State

    [Documentation]    Verify the ethernet interface added to LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}     ${oper_state}

    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Result Should Contain   ${interface}
    Result Should Contain   ${oper_state}

Unconfigure LAG From Device Interface 

    [Documentation]    Unconfigure LAG from the ethernet Interface
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}    ${slot}


    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Unconfigure_LAG_From_Device_Interface_Rolt    ${device}     ${interface}      ${lag_group}    ${slot}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Unconfigure_LAG_From_Device_Interface_E5      ${device}     ${interface}      ${lag_group}

Unconfigure_LAG_From_Device_Interface_Rolt

    [Documentation]    Unconfigure LAG from the ethernet Interface
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}    ${slot}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${interface}
    # AT-5076
    cli    ${device}     no system-lag ${lag_group}
    # AT-5076
    cli    ${device}     no role
    cli    ${device}     no switchport
    cli    ${device}     shutdown
    cli    ${device}     end    prompt=\\#

Unconfigure_LAG_From_Device_Interface_E5

    [Documentation]    Unconfigure LAG from the ethernet Interface
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${interface}
    cli    ${device}     no service-role
    cli    ${device}     end    prompt=\\#

Unconfigure LAG Group Lacp Mode

    [Documentation]    Configure LACP Mode for LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}    ${lacp_mode}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     no lacp-mode
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Unconfigure LAG Group 

    [Documentation]    Unconfigure LAG Group 
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}

    cli    ${device}     configure
    # [AT-4218] modify by Cindy, start
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     no role
    cli    ${device}     no switchport
    cli    ${device}     exit
    # [AT-4218] modify by Cindy, end
    cli    ${device}     no interface lag ${lag_group}
    Result Should Not Contain		Error: failed to apply modifications
    cli    ${device}     end    prompt=\\#

Add Device Interface To LAG With Priority

    [Documentation]    Configure Interface with IPv4 address on ROLT
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}      ${lag_group}    ${lacp_priority}    ${slot}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Add_Device_Interface_To_LAG_Rolt_Priority    ${device}     ${interface}      ${lag_group}     ${lacp_priority}    ${slot}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Add_Device_Interface_To_LAG_E5_Priority     ${device}     ${interface}      ${lag_group}     ${lacp_priority}

Add_Device_Interface_To_LAG_Rolt_Priority

    [Documentation]    Configure Interface with IPv4 address on ROLT
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}     ${lacp_priority}    ${slot}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${interface}
    cli    ${device}     switchport ENABLED
    cli    ${device}     no role lag
    cli    ${device}     role lag
    #  AT-4711 modified by llin
    cli    ${device}     system-lag ${lag_group}
    #  AT-4711 modified by llin
    cli    ${device}     lacp-port-priority ${lacp_priority}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Add_Device_Interface_To_LAG_E5_Priority

    [Documentation]    Configure Interface with IPv4 address on ROLT
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${interface}      ${lag_group}     ${lacp_priority}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${interface}
    cli    ${device}     no service-role
    cli    ${device}     service-role lag
    cli    ${device}     group ${lag_group}
    cli    ${device}     lacp-port-priority ${lacp_priority}
    cli    ${device}     exit
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Check LACP Mode

    [Documentation]    Verify LACP Mode
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}      ${lacp_mode}  

    cli    ${device}     show interface lag ${lag_group} status lacp-mode
    Result Should Contain   ${lacp_mode}

Check LACP Status

    [Documentation]    Verify the ethernet interface added to LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}    ${interface}      ${lag_group}    ${lacp_status} 


    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Result Should Contain   ${interface}
    Result Should Contain   ${lacp_status}


Check Hash Method

    [Documentation]    Verify LACP Mode
    [Tags]      @author=aprakash
    [Arguments]    ${device}     ${lag_group}      ${hash_method}

    cli    ${device}     show interface lag ${lag_group} status hash-method
    Result Should Contain   ${hash_method}

Interface_LAG_shut

    [Documentation]     Shutdown the Interface
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${lag_group}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     shutdown
    cli    ${device}     end    prompt=\\#

Interface_LAG_noshut

    [Documentation]     Enable the Interface
    [Tags]      @author=aprakash
    [Arguments]        ${device}    ${lag_group}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     shutdown
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Check Interface 1G

    [Documentation]    Verify the ethernet interface added to LAG interface group
    [Tags]      @author=aprakash
    [Arguments]    ${device}    ${interface}      ${ether_type}


    cli    ${device}     show interface ethernet ${interface} configuration | include ethertype
    Result Should Contain   ${ether_type}

Disable L3 Service From Vlan
    [Documentation]    Disable L3 service from vlan	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${vlan_id}
    
    log    no need to do this operation on MILAN
    # cli    ${device}     configure
    # cli    ${device}     vlan ${vlan_id}
    # cli    ${device}     l3-service DISABLED
    # cli    ${device}     end    prompt=\\#

Check L3 Service On Vlan
    [Documentation]    Check L3 service is disabled on vlan	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${vlan_id}

    log    no need to do this operation on MILAN
    # ${result} =  cli    ${device}    show vlan-summary | include ${vlan_id}
    # Should Match Regexp  ${result}   ${vlan_id}\\s+L2 

Create Transport Service Profile
    [Documentation]    Create transport service profile for vlan		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${tsp_profile}     ${vlan_id}

    cli    ${device}     configure
    cli    ${device}     transport-service-profile ${tsp_profile}
    cli    ${device}     vlan-list ${vlan_id}
    cli    ${device}     end    prompt=\\#


Check Transport Service Profile Created
    [Documentation]    Check whether transport service profile created		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${tsp_profile}

    cli    ${device}     show running-config transport-service-profile
    Result Should Contain   ${tsp_profile}

Add Transport Service Profile To Lag Group
    [Documentation]    Adding transport service profile to lag interface		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${tsp_profile}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Add_Transport_Service_Profile_To_Lag_Group_Rolt    ${device}     ${lag_group}      ${tsp_profile}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Add_Transport_Service_Profile_To_Lag_Group_E5      ${device}     ${lag_group}      ${tsp_profile}

Add_Transport_Service_Profile_To_Lag_Group_Rolt
    [Documentation]    Adding transport service profile to lag interface of Rolt		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${tsp_profile}
    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     switchport ENABLED
    cli    ${device}     role inni
    cli    ${device}     transport-service-profile ${tsp_profile}
    cli    ${device}     end    prompt=\\#


Add_Transport_Service_Profile_To_Lag_Group_E5
    [Documentation]    Adding transport service profile to lag interface of E5		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${tsp_profile}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     service-role inni
    cli    ${device}     transport-service-profile ${tsp_profile}
    cli    ${device}     end    prompt=\\#

Check Transport Service Profile Added To LAG Interface
    [Documentation]    Check transport service profile added to LAG interface.		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${tsp_profile}

    cli    ${device}     show running-config interface lag ${lag_group}
    Result Should Contain   ${tsp_profile}

Add Transport Service Profile To Interface
    [Documentation]    Adding transport service profile to ethernet interface		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}     ${tsp_profile}    ${slot}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Add_Transport_Service_Profile_To_Interface_Rolt    ${device}     ${interface}      ${tsp_profile}    ${slot}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Add_Transport_Service_Profile_To_Interface_E5      ${device}     ${interface}      ${tsp_profile}

Add_Transport_Service_Profile_To_Interface_Rolt
    [Documentation]    Adding transport service profile to ethernet interface of Rolt		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}     ${tsp_profile}    ${slot}
    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${interface}
    cli    ${device}     no shutdown
    cli    ${device}     switchport ENABLED
    cli    ${device}     role inni
    cli    ${device}     transport-service-profile ${tsp_profile}
    cli    ${device}     end    prompt=\\#


Add_Transport_Service_Profile_To_Interface_E5
    [Documentation]    Adding transport service profile to ethernet interface of E5		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}     ${tsp_profile}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${interface}
    cli    ${device}     service-role inni
    cli    ${device}     transport-service-profile ${tsp_profile}
    cli    ${device}     end    prompt=\\#

Check Transport Service Profile Added To Interface
    [Documentation]    Checking transport service profile added to ethernet interface	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}     ${tsp_profile}    ${slot}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Check_Transport_Service_Profile_Added_To_Interface_Rolt    ${device}     ${interface}      ${tsp_profile}    ${slot}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Check_Transport_Service_Profile_Added_To_Interface_E5      ${device}     ${interface}      ${tsp_profile}

Check_Transport_Service_Profile_Added_To_Interface_Rolt
    [Documentation]    Checking transport service profile to Rolt ethernet interface	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}     ${tsp_profile}    ${slot}
    cli    ${device}     show running-config interface ethernet ${shelf}/${slot}/${interface}
    Result Should Contain   ${tsp_profile}

Check_Transport_Service_Profile_Added_To_Interface_E5
    [Documentation]    Checking transport service profile to E5 ethernet interface	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}     ${tsp_profile}
    cli    ${device}     show running-config interface ethernet ${interface}
    Result Should Contain   ${tsp_profile}

Remove Transport Service Profile From Lag Group
    [Documentation]    Adding transport service profile from lag interface		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Remove_Transport_Service_Profile_From_Lag_Group_Rolt    ${device}     ${lag_group}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Remove_Transport_Service_Profile_From_Lag_Group_E5      ${device}     ${lag_group}

Remove_Transport_Service_Profile_From_Lag_Group_Rolt
    [Documentation]    Removing transport service profile from lag interface of Rolt		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}
    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     role inni
    cli    ${device}     no transport-service-profile
    cli    ${device}     end    prompt=\\#


Remove_Transport_Service_Profile_From_Lag_Group_E5
    [Documentation]    Removing transport service profile from lag interface of E5		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}
    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     service-role inni
    cli    ${device}     no transport-service-profile
    cli    ${device}     exit
    cli    ${device}     no service-role inni
    cli    ${device}     end    prompt=\\#

Remove Transport Service Profile From Interface
    [Documentation]    Adding transport service profile to lag interface		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}    ${slot}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Remove_Transport_Service_Profile_From_Interface_Rolt    ${device}     ${interface}    ${slot}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Remove_Transport_Service_Profile_From_Interface_E5      ${device}     ${interface}

Remove_Transport_Service_Profile_From_Interface_Rolt
    [Documentation]    Removing transport service profile from Rolt ethernet interface		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}    ${slot}
    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${interface}
    cli    ${device}     no role
    cli    ${device}     no transport-service-profile
    cli    ${device}     no switchport
    cli    ${device}     shutdown
    cli    ${device}     end    prompt=\\#


Remove_Transport_Service_Profile_From_Interface_E5
    [Documentation]    Removing transport service profile from E5 ethernet interface		
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${interface}
    cli    ${device}     configure
    cli    ${device}     interface ethernet ${interface}
    cli    ${device}     service-role inni
    cli    ${device}     no transport-service-profile
    cli    ${device}     end    prompt=\\#

Remove Transport Service Profile
    [Documentation]    Unconfigure transport service profile	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${tsp_profile}

    cli    ${device}     configure
    cli    ${device}     no transport-service-profile ${tsp_profile}
    cli    ${device}     end    prompt=\\#

Check LAG Group Member Status
    [Documentation]    Verify the operating state and LACP status for LAG member	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}    ${oper_state}     ${lacp_status}

    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Result Should Contain   ${oper_state}
    Result Should Contain   ${lacp_status}

Check LAG Group Member Status At Interface Shut
    [Documentation]    Verify the operating state and LACP status for LAG member After shut The Interface
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}

    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Result Should Contain   down

Clear Lag Interface Counters
    [Documentation]    Clear Lag Interface Counters	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}

    cli    ${device}     clear interface lag ${lag_group} counters

Check Lag Interface Traffic Utilization With And Without Traffic Standby
    [Documentation]    Checking Tx and Rx Utilization of Lag group member without traffic flow At Standby State
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}

    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Should Match Regexp     ${result}     standby\\s+0\\s+0

Check Lag Interface Traffic Utilization With Traffic Active
    [Documentation]    Checking Tx and Rx Utilization of Lag group member with traffic flow At Active State
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}

    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Should Not Match Regexp     ${result}     active\\s+0\\s+0

Check Lag Interface Traffic Utilization With Traffic Static
    [Documentation]    Checking Tx and Rx Utilization of Lag group member with traffic flow At Active State
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}

    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Should Not Match Regexp     ${result}     static\\s+0\\s+0

Check Lag Interface Traffic Utilization Without Traffic Active
    [Documentation]    Checking Tx and Rx Utilization of Lag group member with traffic flow At Active State
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}

     ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
     Should Match Regexp     ${result}     active\\s+0\\s+0

Check Lag Interface Traffic Utilization Without Traffic Static
    [Documentation]    Checking Tx and Rx Utilization of Lag group member with traffic flow At Active State
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}

     ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
     Should Match Regexp     ${result}     static\\s+0\\s+0

Check Lag Interface Traffic Utilization With And Without Traffic Down
    [Documentation]    Checking Tx and Rx Utilization of Lag group member without traffic flow At Standby State
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface}


    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
    Should Match Regexp     ${result}     down\\s+0\\s+0

Check Lag Member Traffic Distribution Tx Static
    [Documentation]    Checking Lag traffic distribution For Tx
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface1}     ${interface2}
    # modified by llin 
    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface1}
    Should Match Regexp  ${result}  static\\s+\\d+\\s+[2-3]
    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface2}
    Should Match Regexp  ${result}  static\\s+\\d+\\s+[2-3]

Check Lag Member Traffic Distribution Rx Static
    [Documentation]    Checking Lag traffic distribution For Rx 
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface1}     ${interface2}

    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface1}
    Should Match Regexp  ${result}  static\\s+[2-3]\\s+\\d+
    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface2}
    Should Match Regexp  ${result}  static\\s+[2-3]\\s+\\d+

Check Lag Interface Tx Counters Without Traffic
    [Documentation]    Check lag interface tx unicast counters without traffic flow	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}

    cli    ${device}    show interface lag ${lag_group} counters | include tx-unicast-pkts
    Result Should Contain   tx-unicast-pkts   0

Check Lag Interface Rx Counters Without Traffic
    [Documentation]    Check lag interface tx unicast counters without traffic flow	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}

    cli    ${device}    show interface lag ${lag_group} counters | include rx-unicast-pkts
    Result Should Contain   rx-unicast-pkts   0

Check Lag Interface Tx Counters With Traffic
    [Documentation]    Check lag interface tx unicast counters with traffic flow	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}

    cli    ${device}     show interface lag ${lag_group} counters interface-counters tx-unicast-pkts
    Result Should Not Contain   counters interface-counters tx-unicast-pkts 0

Check Lag Interface Rx Counters With Traffic
    [Documentation]    Check lag interface tx unicast counters without traffic flow	
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}

    cli    ${device}     show interface lag ${lag_group} counters interface-counters tx-unicast-pkts
    Result Should Not Contain   counters interface-counters rx-unicast-pkts 0

Check Lag Counters For Tx And Rx

    [Documentation]     Comparing the counters At Transmit And Recieve Lag interface.
    [Tags]      @author=sgupta
    [Arguments]        ${device1}     ${device2}     ${lag_group}     ${packet_type}
    ${result} =    cli    ${device1}     show interface lag ${lag_group} counters interface-counters tx-${packet_type}-pkts
    ${match1}   Should Match Regexp  ${result}  counters interface-counters tx-${packet_type}-pkts\\s(\\d+)
    log   ${match1[1]}
    ${result} =    cli    ${device2}     show interface lag ${lag_group} counters interface-counters rx-${packet_type}-pkts
    ${match2}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    log   ${match2[1]}
    Should Be Equal     ${match1[1]}     ${match2[1]}

Check Lag Interface Counters Without Traffic Tx
    [Documentation]    Check lag interface tx counters without traffic flow
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${packet_type}

    cli    ${device}    show interface lag ${lag_group} counters | include tx-${packet_type}-pkts
    Result Should Contain   tx-${packet_type}-pkts   0

Check Lag Interface Counters Without Traffic Rx
    [Documentation]    Check lag interface tx counters without traffic flow
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${packet_type}

    cli    ${device}    show interface lag ${lag_group} counters | include rx-${packet_type}-pkts
    Result Should Contain   rx-${packet_type}-pkts   0

Check Lag Interface Counters With Traffic Tx
    [Documentation]    Check lag interface tx counters with traffic flow
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${packet_type}

    cli    ${device}     show interface lag ${lag_group} counters interface-counters tx-${packet_type}-pkts
    Result Should Not Contain   counters interface-counters tx-${packet_type}-pkts 0

Check Lag Interface Counters With Traffic Rx
    [Documentation]    Check lag interface tx unicast counters without traffic flow
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${packet_type}

    cli    ${device}     show interface lag ${lag_group} counters interface-counters tx-${packet_type}-pkts
    Result Should Not Contain   counters interface-counters rx-${packet_type}-pkts 0

Check LAG Group Max Port
    [Documentation]    Check Max Port for LAG interface group
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}    ${lag_max_port}

    cli    ${device}     show interface lag ${lag_group} status max-port
    ${result} =    Convert To String   ${lag_max_port}
    Result Should Contain   ${result}

Check LAG Group Min Port
    [Documentation]    Check Max Port for LAG interface group
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}    ${lag_min_port}

    cli    ${device}     show interface lag ${lag_group} status min-port
    Result Should Contain   ${lag_min_port}

Check LAG Group Status Operating State
    [Documentation]    Check LAG Group Status Operating State
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}    ${oper_state}

    cli    ${device}     show interface lag ${lag_group} status oper-state
    Result Should Contain   ${oper_state}

Check LAG Group Status Lacp Mode
    [Documentation]    Check LAG Group Status Lacp Mode
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}    ${lacp_mode}

    cli    ${device}     show interface lag ${lag_group} status lacp-mode
    Result Should Contain   ${lacp_mode}

#----------------------Nalam Keywords--------------------

Create LAG Group with LACP mode

    [Documentation]    Create LAG interface group with LACP mode
    [Tags]      @author=nkumar
    [Arguments]    ${device}     ${lag_group}   ${lacp}

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    # [AT-4218] modify by Cindy, start
    cli    ${device}     switchport ENABLED
    cli    ${device}     role inni
    # [AT-4218] modify by Cindy, end
    cli    ${device}     lacp-mode ${lacp}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#


Create System Priority For LAG

    [Documentation]    Create prority for LAG System
    [Tags]      @author=nkumar
    [Arguments]    ${device}     ${system_prority}

    cli    ${device}     configure
    cli    ${device}     lacp actor-system-priority ${system_prority}
    cli    ${device}     end    prompt=\\#


Check System Priority in LAG

    [Documentation]    Check prority for LAG System
    [Tags]      @author=nkumar
    [Arguments]    ${device}    ${system_prority}

    cli    ${device}     show running-config lacp actor-system-priority
    ${result} =    Convert To String   ${system_prority}
    Result Should Contain    ${result}


Check The LAG Status Shutdown

    [Documentation]    Check LAG status shutdown
    [Tags]      @author=nkumar
    [Arguments]    ${device}   ${lag_group}

    cli    ${device}      show running-config interface lag ${lag_group} shutdown
    Result Should Contain   shutdown


Check Port Priority in LAG

    [Documentation]    Check prority for LAG System
    [Tags]      @author=nkumar
    [Arguments]    ${device}    ${shelf}   ${slot}   ${port}   ${port_priority}

    cli    ${device}     show interface ethernet ${shelf}/${slot}/${port} status lacp-port-priority
    Result Should Contain   ${port_priority}

Check Valid Characters and Bound Status of LAG System

    [Documentation]    Check Valid Status of LAG System
    [Tags]      @author=nkumar
    [Arguments]    ${device}   ${invalid_lag_group}

    cli    ${device}     configure
    ${result}    cli    ${device}     interface lag ${invalid_lag_group}
    Result Should Contain    ${result}    illegal reference
    cli    ${device}     end    prompt=\\#

Unconfigure Service Role

    [Documentation]    Unconfigure service role
    [Tags]      @author=nkumar
    [Arguments]    ${device}     ${lag_group}


    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     shutdown
    cli    ${device}     no service-role inni
    cli    ${device}     end    prompt=\\#

Clear Counter in DCLI mode

    [Documentation]    delete counter value through DCLI
    [Tags]      @author=nkumar
    [Arguments]    ${device}


    cli    ${device}     set.sio.port.counters.clear ${lag_group}
    Result Should Contain    ${lag_group}: counters cleared


Check Status Description

    [Documentation]    LAG Group Staus Description
    [Tags]      @author=nkumar
    [Arguments]    ${device}

    cli    ${device}     show interface lag la1 status description
    Result Should Contain    status description active${lag_group}


Check Transport Profile Deleted

    [Documentation]    Verify that transport profile has been deleted
    [Tags]      @author=nkumar
    [Arguments]    ${device}

    cli    ${device}     sh run int lag ${lag_group}
    Result Should Not Contain    transport-service-profile


Check LAG Group Status Admin State

    [Documentation]    Verify the admin state of LAG
    [Tags]      @author=nkumar
    [Arguments]    ${device}     ${lag_group}    ${admin_state}

    cli    ${device}      show interface lag ${lag_group} status admin-state
    Result Should Contain   status admin-state ${admin_state}


Check LAG Group Status Max Speed

    [Documentation]    Verify the maximum speed of LAG
    [Tags]      @author=nkumar
    [Arguments]    ${device}     ${lag_group}    ${max_speed}

    cli    ${device}      show interface lag ${lag_group} status max-speed
    Result Should Contain   status max-speed ${max_speed}


Check LAG Group Status Operation Speed

    [Documentation]    Verify the operational speed of LAG
    [Tags]      @author=nkumar
    [Arguments]    ${device}     ${lag_group}    ${oper_speed}

    cli    ${device}      show interface lag ${lag_group} status oper-speed
    Result Should Contain   status oper-speed ${oper_speed}


Check Lag Member Traffic Distribution Tx Active
    [Documentation]    Checking Lag traffic distribution For Tx
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface1}     ${interface2}

    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface1}
    Should Match Regexp  ${result}  active\\s+\\d+\\s+[2-3]
    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface2}
    Should Match Regexp  ${result}  active\\s+\\d+\\s+[2-3]

Check Lag Member Traffic Distribution Rx Active
    [Documentation]    Checking Lag traffic distribution For Rx
    [Tags]      @author=sgupta
    [Arguments]    ${device}     ${lag_group}     ${interface1}     ${interface2}

    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface1}
    Should Match Regexp  ${result}  active\\s+[2-3]\\s+\\d+
    ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface2}
    Should Match Regexp  ${result}  active\\s+[2-3]\\s+\\d+


Check Alarm Status With LACP

    [Documentation]    Checking the status of the alarm and verifying its mode
    [Tags]      @author=nkumar
    [Arguments]    ${device}     ${lacp_mode}     ${lacp_status_on_port}

    cli    ${device}     show alarm ${lacp_mode} | include lacp
    Result should contain   ${lacp_status_on_port}


##----Sathish keyword------#######

Check LAG Group Alarm Status

    [Documentation]    Check LAG Group Alarm Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${lag_group}    ${Alarm1}    ${status}

    ${result} =    cli    ${device}     show interface lag ${lag_group} | include ${Alarm1}
    Should Match Regexp   ${result}     (${Alarm1}\\s+${status})

Check LAG Group Alarm Ethernet Status

    [Documentation]    Check LAG Group Alarm Ethernet Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}    ${Alarm}    ${status}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True      Check LAG Group Alarm Ethernet ROLT_Status    ${device}     ${port}    ${Alarm}    ${status}
    Run Keyword If     ${result.__contains__('E5-520')}==True    Check LAG Group Alarm Ethernet E5_Status    ${device}     ${port}    ${Alarm}    ${status}

Check LAG Group Alarm Ethernet ROLT_Status

    [Documentation]    Check LAG Group Alarm Ethernet Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}    ${Alarm}    ${status}

    ${result} =    cli    ${device}     show interface ethernet ${shelf}/${slot}/${port} | include ${Alarm}
    Should Match Regexp   ${result}     (${Alarm}\\s+${status})

Check LAG Group Alarm Ethernet E5_Status

    [Documentation]    Check LAG Group Alarm Ethernet Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}    ${Alarm}    ${status}

    ${result} =    cli    ${device}     show interface ethernet ${port} | include ${Alarm}
    Should Match Regexp   ${result}     (${Alarm}\\s+${status})


Shutdown Lag Interface

    [Documentation]      Shutdown Lag Interface on ROLT device
    [Arguments]          ${device}     ${lag_group}
    [Tags]        @author=Layer2-HCL-Team

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     shutdown
    cli    ${device}     end     prompt=\\#

Unshutdown Lag Interface

    [Documentation]      Unshutdown Lag Interface on ROLT device
    [Arguments]          ${device}     ${lag_group}
    [Tags]        @author=Layer2-HCL-Team

    cli    ${device}     configure
    cli    ${device}     interface lag ${lag_group}
    cli    ${device}     no shutdown
    cli    ${device}     end     prompt=\\#

Check LAG Attirbutes Retrieve Status

    [Documentation]    Check LAG Group Attirbutes Retrieve Ethernet Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}      ${lag_group}     ${port}    ${rx-status}    ${def-status}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True      Check LAG Attirbutes Retrieve ROLT_Status    ${device}      ${lag_group}     ${port}    ${rx-status}    ${def-status}
    Run Keyword If     ${result.__contains__('E5-520')}==True    Check LAG Attirbutes Retrieve E5_Status      ${device}      ${lag_group}     ${port}    ${rx-status}    ${def-status}

Check LAG Attirbutes Retrieve ROLT_Status

    [Documentation]    Check LAG Group Attirbutes Retrieve ROLT Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}      ${lag_group}     ${port}    ${rx-status}    ${def-status}

    ${result} =    cli    ${device}     show interface lag ${lag_group} lacp ethernet interface ${shelf}/${slot}/${port} | include rx-state
    Should Match Regexp   ${result}     (rx-state\\s+${rx-status})

    ${result} =    cli    ${device}     show interface lag ${lag_group} lacp ethernet interface ${shelf}/${slot}/${port} | begin actor | until partner
    Should Match Regexp   ${result}     (defaulted\\s+${def-status})

    ${result} =    cli    ${device}     show interface lag ${lag_group} lacp ethernet interface ${shelf}/${slot}/${port} | begin partner | until actor
    Should Match Regexp   ${result}     (defaulted\\s+${def-status})

Check LAG Attirbutes Retrieve E5_Status

    [Documentation]    Check LAG Group Attirbutes Retrieve E5 Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}      ${lag_group}     ${port}    ${rx-status}    ${def-status}

    ${result} =    cli    ${device}     show interface lag ${lag_group} lacp ethernet ${port} | include rx-state
    Should Match Regexp   ${result}     (rx-state\\s+${rx-status})

    ${result} =    cli    ${device}     show interface lag ${lag_group} lacp ethernet ${port} | begin actor | until partner
    Should Match Regexp   ${result}     (defaulted\\s+${def-status})

    ${result} =    cli    ${device}     show interface lag ${lag_group} lacp ethernet ${port} | begin partner | until actor
    Should Match Regexp   ${result}     (defaulted\\s+${def-status})


Verify Lag Interface Traffic TX Utilization Status

    [Documentation]    Checking Tx Utilization of Lag group member with traffic flow At lacp State
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${lag_group}     ${interface}     ${lacp_Status}     ${value}

     ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
     ${match1}   Should Match Regexp     ${result}     ${lacp_Status}\\s+0\\s+(\\d+)
     log   ${match1[1]}
     Should Not Contain     ${match1[1]}     ${value}

Verify Lag Interface Traffic RX Utilization Status

    [Documentation]    Checking Rx Utilization of Lag group member with traffic flow At lacp State
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${lag_group}     ${interface}     ${lacp_Status}     ${value}

     ${result} =    cli    ${device}     show interface lag ${lag_group} members | include ${interface}
     ${match1}   Should Match Regexp     ${result}     ${lacp_Status}\\s+(\\d+)\\s+0
     log   ${match1[1]}
     Should Not Contain     ${match1[1]}     ${value}

Verify Lag Interface Traffic TX RX Utilization Status

    [Documentation]    Checking Tx Rx Utilization of Lag group member with traffic flow At lacp State
    [Tags]      @author=smuruges
    [Arguments]    ${device1}    ${device2}   ${lag_group}     ${interface1}    ${interface2}    ${lacp_Status}     ${value}

     ${result} =    cli    ${device1}     show interface lag ${lag_group} members | include ${interface1}
     ${match1}   Should Match Regexp     ${result}     ${lacp_Status}\\s+0\\s+(\\d+)
     log   ${match1[1]}
     ${result} =    cli    ${device2}     show interface lag ${lag_group} members | include ${interface2}
     ${match2}   Should Match Regexp     ${result}     ${lacp_Status}\\s+(\\d+)\\s+0
     log   ${match2[1]}
     # modified by llin due to we change the 10G port to 1G 2017.7.21
     Should Be True     ${match1[1]} > 1
     Should Be True     ${match2[1]} > 1
     # modified by llin due to we change the 10G port to 1G 2017.7.21


Unconfigure LAG Group From Device Interface

    [Documentation]    Unconfigure LAG Group from the ethernet Interface
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${interface}      ${lag_group}


    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Unconfigure_LAG_Group_From_Device_Interface_Rolt    ${device}     ${interface}      ${lag_group}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Unconfigure_LAG_Group_From_Device_Interface_E5      ${device}     ${interface}      ${lag_group}

Unconfigure_LAG_Group_From_Device_Interface_Rolt

    [Documentation]    Unconfigure LAG from the ethernet Interface
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${interface}      ${lag_group}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${interface}
    cli    ${device}     no system-lag ${lag_group}
    cli    ${device}     end    prompt=\\#

Unconfigure_LAG_Group_From_Device_Interface_E5

    [Documentation]    Unconfigure LAG from the ethernet Interface
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${interface}      ${lag_group}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${interface}
    cli    ${device}     service-role lag
    cli    ${device}     no group
    cli    ${device}     end    prompt=\\#

Add Device Interface To LAG With Timeout

    [Documentation]    Add Device Interface To LAG With Timeout on devices
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${interface}      ${lag_group}    ${lacp_timeout}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True     Add_Device_Interface_To_LAG_Rolt_Timeout    ${device}     ${interface}      ${lag_group}     ${lacp_timeout}
    Run Keyword If     ${result.__contains__('E5-520')}==True   Add_Device_Interface_To_LAG_E5_Timeout     ${device}     ${interface}      ${lag_group}     ${lacp_timeout}

Add_Device_Interface_To_LAG_Rolt_Timeout

    [Documentation]    Add Device Interface To LAG With Timeout on ROLT
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${interface}      ${lag_group}     ${lacp_timeout}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${shelf}/${slot}/${interface}
    cli    ${device}     switchport ENABLED
    cli    ${device}     no role lag
    cli    ${device}     role lag
    # AT-4711  modified by llin
    cli    ${device}     system-lag ${lag_group}
    # AT-4711  modified by llin
    cli    ${device}     lacp-port-timeout ${lacp_timeout}
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#

Add_Device_Interface_To_LAG_E5_Timeout

    [Documentation]    Add Device Interface To LAG With Timeout on E5
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${interface}      ${lag_group}     ${lacp_timeout}

    cli    ${device}     configure
    cli    ${device}     interface ethernet ${interface}
    cli    ${device}     no service-role
    cli    ${device}     service-role lag
    cli    ${device}     group ${lag_group}
    cli    ${device}     lacp-port-timeout ${lacp_timeout}
    cli    ${device}     exit
    cli    ${device}     no shutdown
    cli    ${device}     end    prompt=\\#


Check LAG Group Ethernet Status

    [Documentation]    Check LAG Group Ethernet Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}    ${lacp-port}    ${status}

    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True      Check LAG Group Ethernet ROLT_Status    ${device}     ${port}    ${lacp-port}    ${status}
    Run Keyword If     ${result.__contains__('E5-520')}==True    Check LAG Group Ethernet E5_Status      ${device}     ${port}    ${lacp-port}    ${status}

Check LAG Group Ethernet ROLT_Status

    [Documentation]    Check LAG Group ROLT Ethernet Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}    ${lacp-port}    ${status}

    ${result} =    cli    ${device}     show interface ethernet ${shelf}/${slot}/${port} | include ${lacp-port}
    Should Match Regexp   ${result}     (${lacp-port}\\s+${status})

Check LAG Group Ethernet E5_Status

    [Documentation]    Check LAG Group E5 Ethernet Status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}    ${lacp-port}    ${status}

    ${result} =    cli    ${device}     show interface ethernet ${port} | include ${lacp-port}
    Should Match Regexp   ${result}     (${lacp-port}\\s+${status})


Check Lag Interface Counters For Tx And Rx

    [Documentation]     Comparing the counters At Transmit And Recieve Lag interface.
    [Tags]      @author=smuruges
    [Arguments]        ${device1}     ${device2}     ${port1}    ${port2}    ${packet_type}
    ${result} =    cli    ${device1}     show interface ethernet ${shelf}/${slot}/${port1} counters interface-counters tx-${packet_type}-pkts
    ${match1}   Should Match Regexp  ${result}  counters interface-counters tx-${packet_type}-pkts\\s(\\d+)
    log   ${match1[1]}
    ${result} =    cli    ${device2}     show interface ethernet ${shelf}/${slot}/${port2} counters interface-counters rx-${packet_type}-pkts
    ${match2}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    log   ${match2[1]}
    Should Be Equal     ${match1[1]}     ${match2[1]}


Check Lag Interface Counters For Tx And Rx Packets value

    [Documentation]     Comparing the counters At Transmit And Recieve Lag interface tx and rx values.
    [Tags]      @author=smuruges
    [Arguments]        ${device1}     ${device2}     ${lag_group}    ${port2}    ${port3}   ${packet_type}

    ${result} =    cli    ${device1}     show interface lag ${lag_group} counters interface-counters tx-${packet_type}-pkts
    ${match1}   Should Match Regexp  ${result}  counters interface-counters tx-${packet_type}-pkts\\s(\\d+)
    ${value1}   Set Variable   int(${match1[1]})
    log   ${value1}
    ${result}    cli  ${device2}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True      Check Lag Interface Counters For Tx And Rx Packets value ROLT    ${device2}     ${lag_group}    ${port2}    ${port3}   ${packet_type}     ${value1}
    Run Keyword If     ${result.__contains__('E5-520')}==True    Check Lag Interface Counters For Tx And Rx Packets value E5      ${device2}     ${lag_group}    ${port2}    ${port3}   ${packet_type}     ${value1}

Check Lag Interface Counters For Tx And Rx Packets value ROLT

    [Documentation]     Comparing the counters At Transmit And Recieve Lag interface tx and rx values.
    [Tags]      @author=smuruges
    [Arguments]       ${device2}     ${lag_group}    ${port2}    ${port3}   ${packet_type}     ${value1}

    ${result} =    cli    ${device2}     show interface ethernet ${shelf}/${slot}/${port2} counters interface-counters rx-${packet_type}-pkts
    ${match2}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    ${value2}   Set Variable   ${match2[1]}
    log   ${value2}
    ${result} =    cli    ${device2}     show interface ethernet ${shelf}/${slot}/${port3} counters interface-counters rx-${packet_type}-pkts
    ${match3}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    ${value3}   Set Variable   ${match3[1]}
    log   ${value3}
    ${value4}   Evaluate   ${value2}+${value3}
    ${value5}   Set Variable   int(${value4})
    log   ${value5}
    Should Be Equal    ${value1}    ${value5}

Check Lag Interface Counters For Tx And Rx Packets value E5

    [Documentation]     Comparing the counters At Transmit And Recieve Lag interface tx and rx values.
    [Tags]      @author=smuruges
    [Arguments]        ${device2}     ${lag_group}    ${port2}    ${port3}   ${packet_type}     ${value1}

    ${result} =    cli    ${device2}     show interface ethernet ${port2} counters interface-counters rx-${packet_type}-pkts
    ${match2}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    ${value2}   Set Variable   ${match2[1]}
    log   ${value2}
    ${result} =    cli    ${device2}     show interface ethernet ${port3} counters interface-counters rx-${packet_type}-pkts
    ${match3}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    ${value3}   Set Variable   ${match3[1]}
    log   ${value3}
    ${value4}   Evaluate   ${value2}+${value3}
    ${value5}   Set Variable   int(${value4})
    log   ${value5}
    Should Be Equal    ${value1}    ${value5}

Verify Interface Traffic
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Interface Traffic
    [Tags]    @author=skoya
    cli    ${device}    show interface ethernet ${shelf}/${slot}/${port} counters
    Result Match Regexp    pkts-512to1023\\s+\\d+

Disable PM Session In Interface
    [Arguments]    ${device}    ${port}
    [Documentation]    Disable PM session in corresponding interface
    [Tags]    @author=skoya
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${shelf}/${slot}/${port}
    cli    ${device}    no rmon-session one-minute ${historicalbin}
    cli    ${device}    no rmon-session five-minutes ${historicalbin}
    cli    ${device}    no rmon-session fifteen-minutes ${historicalbin}
    cli    ${device}    no rmon-session one-hour ${historicalbin}
    cli    ${device}    no rmon-session one-day ${historicalbin}
    cli    ${device}    no rmon-session infinite 1
    cli    ${device}    no rmon-session one-minute 60
    cli    ${device}    no rmon-session five-minutes 12
    cli    ${device}    no rmon-session fifteen-minutes 4
    cli    ${device}    no rmon-session one-hour 12
    cli    ${device}    no rmon-session one-day 1
    cli    ${device}    end    prompt=\\#

Not Sync TOD
    [Arguments]    ${device}
    [Documentation]    Enable PM session at time not synced to Time of Day
    [Tags]    @author=skoya
    ${time}    cli    ${device}    show clock
    ${time1}    Should Match Regexp    ${time}    (\\d+)(\\:)(\\d)(\\d)(\\:)(\\d)(\\d)
    ${time21}    Should Match Regexp    ${time1[6]}    \\d
    ${time22}    Should Match Regexp    ${time1[7]}    \\d
    ${time2}    Evaluate    (${time21} * 10) + ${time22}
    ${time31}    Should Match Regexp    ${time1[3]}    \\d
    ${time32}    Should Match Regexp    ${time1[4]}    \\d
    ${time3}    Evaluate    (${time31} * 10) + ${time32}
    ${bintime1}    Evaluate    ${bin_time} - 1
    ${wait1}    Evaluate    (${bintime1} - ${time3} % ${bin_time}) * 60
    ${wait}    Evaluate    59 - ${time2}
    ${totalwait}    Evaluate    ${wait} + ${wait1} 
    sleep    ${totalwait}

Enable PM Session In Interface
    [Arguments]    ${device}    ${port}
    [Documentation]    Enable PM session in corresponding interface
    [Tags]    @author=skoya
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${shelf}/${slot}/${port}
    cli    ${device}    rmon-session ${bin_duration} ${historicalbin} gos-profile-name ${profilename} session-name ${session_name} bin-gos enable interval-gos enable
    cli    ${device}    end    prompt=\\#

Verify PM Session Is Created
    [Arguments]    ${device}    ${port}    ${sessionnumber}
    [Documentation]    Verify Current Performance Monitoring session
    [Tags]    @author=skoya
    cli    ${device}    show interface ethernet ${shelf}/${slot}/${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    Result Should Contain    number ${sessionnumber}


Verify Not Synced TOD Common Bin Attribites
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Common attributes specific to the bins are present
    [Tags]    @author=skoya
    cli    ${device}    show interface ethernet ${shelf}/${slot}/${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    start-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect TRUE
    Result Should Contain    cause PM Bin is partial
    Result Should Contain    is-current TRUE
    ${wait_time}    Evaluate    ${bin_time} * 60
    sleep    ${wait_time}
    cli    ${device}    show interface ethernet ${shelf}/${slot}/${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed
    Result Should Contain    suspect TRUE
    Result Should Contain    cause PM Bin is partial
    Result Should Contain    is-current FALSE

Verify PM Session Counters Five Minutes
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify PM Session counters
    [Tags]    @author=skoya
    cli    ${device}    show interface ethernet ${shelf}/${slot}/${port} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Match Regexp    pkts-512to1023\\s29\\d{5}|pkts-512to1023\\s30\\d{5}


Configure Grade Of Service Profile
    [Arguments]    ${device}    ${profilename}
    [Documentation]    Configure Grade Of Service
    [Tags]    @author=skoya
    cli    ${device}    configure
    cli    ${device}    grade-of-service rmon-gos-profile ${profilename} bin-gos octets threshold 2000 tca-name octets
    cli    ${device}    grade-of-service rmon-gos-profile ${profilename} bin-gos pkts-512to1023 threshold 2000 tca-name pkts-1024to1518
    cli    ${device}    grade-of-service rmon-gos-profile ${profilename} bin-gos rx-pkts threshold 2000 tca-name rx-pkts
    cli    ${device}    end    prompt=\\#

Verify GOS Profile configured
    [Arguments]    ${device}    ${profilename}
    [Documentation]    Verify GOS Profile configured is successful
    [Tags]    @author=skoya
    cli    ${device}    show running-config grade-of-service
    Result Should Contain    grade-of-service
    Result Should Contain    rmon-gos-profile ${profilename}
    Result Should Contain    bin-gos octets
    Result Should Contain    bin-gos pkts-512to1023
    Result Should Contain    bin-gos rx-pkts

Clear Interface Counter
    [Arguments]    ${device}    ${port}
    [Documentation]    clearing interface counter before starting traffic
    [Tags]    @author=skoya
    ${result}    cli  ${device}    show inventory    prompt=\\#
    Run Keyword If     ${result.__contains__('${model}')}==True    Clear_Interface_Counter_ROLT    ${device}    ${port}
    Run Keyword If     ${result.__contains__('E5-520')}==True    Clear_Interface_Counter_E5    ${device}    ${port}

Clear_Interface_Counter_ROLT

    [Arguments]    ${device}    ${port}
    [Documentation]    clearing interface counter before starting traffic
    [Tags]    @author=skoya
    cli  ${device}    clear interface ethernet ${shelf}/${slot}/${port} counters

Clear_Interface_Counter_E5

    [Arguments]    ${device}    ${port}
    [Documentation]    clearing interface counter before starting traffic
    [Tags]    @author=skoya
    cli  ${device}   clear interface ethernet ${port} counters


Unconfigure Grade Of Service Profile
    [Arguments]    ${device}
    [Documentation]    Unonfigure Grade Of Service
    [Tags]    @author=skoya
    cli    ${device}    configure
    cli    ${device}    no grade-of-service rmon-gos-profile ${profilename}
    cli    ${device}    end    prompt=\\#

Check Lag Associated Interface Counters For Tx And Rx Packets value

    [Documentation]     Comparing the counters At Transmit And Recieve Lag interface tx and rx values.
    [Tags]      @author=smuruges
    [Arguments]        ${device1}     ${lag_group}     ${port1}     ${port2}    ${packet_type}

    ${result} =    cli    ${device1}     show interface lag ${lag_group} counters interface-counters tx-${packet_type}-pkts
    ${match1}   Should Match Regexp  ${result}  counters interface-counters tx-${packet_type}-pkts\\s(\\d+)
    ${value1}   Set Variable   int(${match1[1]})
    log   ${value1}
    ${result} =    cli    ${device1}     show interface lag ${lag_group} counters interface-counters rx-${packet_type}-pkts
    ${match2}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    ${value2}   Set Variable   int(${match2[1]})
    log   ${value2}
    ${result} =    cli    ${device1}     show interface ethernet ${shelf}/${slot}/${port1} counters interface-counters tx-${packet_type}-pkts
    ${match3}   Should Match Regexp  ${result}  counters interface-counters tx-${packet_type}-pkts\\s(\\d+)
    ${value3}   Set Variable   ${match3[1]}
    log   ${value3}
    ${result} =    cli    ${device1}     show interface ethernet ${shelf}/${slot}/${port2} counters interface-counters tx-${packet_type}-pkts
    ${match4}   Should Match Regexp  ${result}  counters interface-counters tx-${packet_type}-pkts\\s(\\d+)
    ${value4}   Set Variable   ${match4[1]}
    log   ${value4}
    ${value_a}   Evaluate   ${value3}+${value4}
    ${value_b}   Set Variable   int(${value_a})
    log   ${value_b}
    Should Be Equal    ${value1}    ${value_b}
    ${result} =    cli    ${device1}     show interface ethernet ${shelf}/${slot}/${port1} counters interface-counters rx-${packet_type}-pkts
    ${match5}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    ${value5}   Set Variable   ${match5[1]}
    log   ${value5}
    ${result} =    cli    ${device1}     show interface ethernet ${shelf}/${slot}/${port2} counters interface-counters rx-${packet_type}-pkts
    ${match6}   Should Match Regexp  ${result}  counters interface-counters rx-${packet_type}-pkts\\s(\\d+)
    ${value6}   Set Variable   ${match6[1]}
    log   ${value6}
    ${value_c}   Evaluate   ${value5}+${value6}
    ${value_d}   Set Variable   int(${value_c})
    log   ${value_d}
    Should Be Equal    ${value2}    ${value_d}

Verify LAG Interface Traffic
    [Arguments]    ${device}    ${lag_group}
    [Documentation]    Verify LAG Interface Traffic
    [Tags]    @author=smuruges
    cli    ${device}    show interface lag ${lag_group} counters
    Result Match Regexp    pkts-512to1023\\s+\\d+

Disable PM Session In LAG Interface
    [Arguments]    ${device}    ${lag_group}
    [Documentation]    Disable PM session in corresponding LAG interface
    [Tags]    @author=smuruges
    cli    ${device}    configure
    cli    ${device}    interface lag ${lag_group}
    cli    ${device}    no rmon-session one-minute ${historicalbin}
    cli    ${device}    no rmon-session five-minutes ${historicalbin}
    cli    ${device}    no rmon-session fifteen-minutes ${historicalbin}
    cli    ${device}    no rmon-session one-hour ${historicalbin}
    cli    ${device}    no rmon-session one-day ${historicalbin}
    cli    ${device}    no rmon-session infinite 1
    cli    ${device}    no rmon-session one-minute 60
    cli    ${device}    no rmon-session five-minutes 12
    cli    ${device}    no rmon-session fifteen-minutes 4
    cli    ${device}    no rmon-session one-hour 12
    cli    ${device}    no rmon-session one-day 1
    cli    ${device}    end    prompt=\\#

Enable PM Session In LAG Interface
    [Arguments]    ${device}    ${lag_group}
    [Documentation]    Enable PM session in corresponding interface
    [Tags]    @author=smuruges
    cli    ${device}    configure
    cli    ${device}    interface lag ${lag_group}
    cli    ${device}    rmon-session ${bin_duration} ${historicalbin} gos-profile-name ${profilename} session-name ${session_name} bin-gos enable interval-gos enable
    cli    ${device}    end    prompt=\\#

Verify PM Session Is Created on LAG Interface
    [Arguments]    ${device}    ${lag_group}    ${sessionnumber}
    [Documentation]    Verify Current Performance Monitoring session
    [Tags]    @author=smuruges
    ${res}    cli    ${device}    show interface lag ${lag_group} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    is-current TRUE
    ${match}    ${num}    Should Match Regexp    ${res}    number (\\d+)
    should be true    abs(${num}-${sessionnumber})<=1

Verify Not Synced TOD Common Bin Attribites on LAG Interface
    [Arguments]    ${device}    ${lag_group}
    [Documentation]    Verify Common attributes specific to the bins are present
    [Tags]    @author=smuruges
    cli    ${device}    show interface lag ${lag_group} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 0
    Result Should Contain    start-time
    Result Should Contain    time-elapsed
    Result Should Contain    is-current TRUE
    ${wait_time}    Evaluate    ${bin_time} * 60 
    sleep    ${wait_time}
    cli    ${device}    show interface lag ${lag_group} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    Result Should Contain    start-time
    Result Should Contain    end-time
    Result Should Contain    time-elapsed
    Result Should Contain    is-current FALSE

Verify PM Session LAG Interface Counters Five Minutes
    [Arguments]    ${device}    ${lag_group}
    [Documentation]    Verify PM Session counters
    [Tags]    @author=smuruges
    ${result} =    cli    ${device}    show interface lag ${lag_group} performance-monitoring rmon-session bin-duration ${bin_duration} bin-or-interval bin num-show 1 num-back 1
    #Result Match Regexp    pkts-512to1023\\s60\\d{9}|pkts-512to1023\\s61\\d{9}
    ${match1}   Should Match Regexp  ${result}    pkts-512to1023\\s(\\d+)
    log   ${match1[1]}
    Should Be True     ${match1[1]} > 100000

#####ASR Keyword ######

Create Bundle Ethernet l2 trans profile ASR

    [Documentation]    Create bundle ethernet l2 transport profile
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${id}

    cli    ${device}     configure
    cli    ${device}     interface Bundle-Ether ${id}
    cli    ${device}     l2transport
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#

Create Ethernet l2 trans profile ASR

    [Documentation]    Create Ethernet l2 transport profile
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}

    cli    ${device}     configure
    cli    ${device}     interface ${port}
    cli    ${device}     negotiation auto
    cli    ${device}     l2transport
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#

Create Ethernet bind bundle ASR

    [Documentation]    Create Ethernet bind bundle
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}     ${id}     ${lacp_stat}

    cli    ${device}     configure
    cli    ${device}     interface ${port}
    cli    ${device}     bundle id ${id} mode ${lacp_stat}
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#

Create vlan bridge bind ASR

    [Documentation]    Create Ethernet bind bundle
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}     ${id}     ${vlan_id}

    cli    ${device}     configure
    cli    ${device}     l2vpn
    cli    ${device}     bridge group ${vlan_id}
    cli    ${device}     bridge-domain VLAN${vlan_id}
    cli    ${device}     interface Bundle-Ether${id}
    cli    ${device}     interface ${port}
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#


Verify Interface Bundle Ethernet status ASR

    [Documentation]    Verify interface bundle ethernet status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${id}     ${status}

    ${result} =  cli    ${device}     show interface bundle-ether ${id} | include Bundle-Ether${id} is ${status}
    Should Match Regexp  ${result}    Bundle-Ether${id}\\s+is\\s+${status}

Verify Bundle interface Ethernet status ASR

    [Documentation]    Verify bundle interface ethernet status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${id}    ${port}     ${status}

    ${result} =  cli    ${device}     show interface bundle-ether ${id} | include ${port}
    Should Match Regexp  ${result}    ${port}\\s+Full-duplex\\s.*${status}

Verify Bundle Ethernet status ASR

    [Documentation]    Verify bundle ethernet status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${id}     ${status}

    ${result} =  cli    ${device}     show bundle bundle-ether ${id} | include Status
    Should Match Regexp  ${result}    Status:\\s+${status}

Verify Bundle Ethernet interface status ASR

    [Documentation]    Verify bundle ethernet interface status
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${id}     ${port}     ${status}

    ${result} =  cli    ${device}     show bundle bundle-ether ${id} | include ${port}
    Should Match Regexp  ${result}    ${port}\\s+Local\\s+${status}

Unconfigure Bundle Ethernet l2 trans profile ASR

    [Documentation]    Unconfigure bundle ethernet l2 transport profile
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${id}

    cli    ${device}     configure
    cli    ${device}     interface Bundle-Ether ${id}
    cli    ${device}     no l2transport
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#

Unconfigure Ethernet l2 trans profile ASR

    [Documentation]    Unconfigure Ethernet l2 transport profile
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}

    cli    ${device}     configure
    cli    ${device}     interface ${port}
#    cli    ${device}     no negotiation auto
    cli    ${device}     no l2transport
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#

Unconfigure Ethernet bind bundle ASR

    [Documentation]    Unconfigure Ethernet bind bundle
    [Tags]      @author=smuruges
    [Arguments]    ${device}     ${port}     ${id}     ${lacp_stat}

    cli    ${device}     configure
    cli    ${device}     interface ${port}
    cli    ${device}     no bundle id ${id} mode ${lacp_stat}
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#

Unconfigure l2vpn binded bundle ASR

    [Documentation]    Unconfigure l2vpn binded bundle
    [Tags]      @author=smuruges
    [Arguments]    ${device}

    cli    ${device}     configure
    cli    ${device}     no l2vpn
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#

Configure LAG Group Max Port ASR

    [Documentation]    Configure LAG Group Max Port ASR
    [Tags]      @author=smuruges
    [Arguments]    ${device}    ${id}    ${max_port_id}

    cli    ${device}     configure
    cli    ${device}     interface bundle-ether ${id}
    cli    ${device}     bundle maximum-active links ${max_port_id}
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#


Unconfigure LAG Group Max Port ASR

    [Documentation]    Configure LAG Group Max Port ASR
    [Tags]      @author=smuruges
    [Arguments]    ${device}    ${id}    ${max_port_id}

    cli    ${device}     configure
    cli    ${device}     interface bundle-ether ${id}
    cli    ${device}     no bundle maximum-active links ${max_port_id}
    cli    ${device}     commit
    cli    ${device}     end    prompt=\\#


