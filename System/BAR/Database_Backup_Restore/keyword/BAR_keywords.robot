*** Settings ***
Documentation    Database Backup & Restore Test_suite keyword lib

*** Keywords ***

Upload Config File
    [Arguments]          ${device}     ${location}     ${user_id}     ${scp_serverip}     ${user_password}
    [Documentation]      Upload Config File
    [Tags]               @author=llim
    Cli With Error Check    ${device}     upload file config from-file startup-config.xml to-URI scp://${user_id}@${scp_serverip}:${location} password ${user_password}
    Result Should Contain    Initiating upload
    
Download Config File
    [Arguments]          ${device}     ${location}    ${user_id}      ${scp_serverip}      ${user_password}
    [Documentation]      Download the config file 
    [Tags]               @author=llim
    Cli With Error Check    ${device}     download file config from-URI scp://${user_id}@${scp_serverip}:${location}startup-config.xml to-file startup-config.xml password ${user_password}
    Result Should Contain    Initiating download

Verify File Transfer Complete
    [Arguments]          ${device}
    [Documentation]      Verify File Transfer Complete
    [Tags]               @author=llim
    Wait Until Keyword Succeeds    30    5s    Is File Transfer Still In Progress    ${device}
    
Is File Transfer Still In Progress
    [Arguments]          ${device}
    [Documentation]      Check Is File Transfer Still In Progress
    [Tags]               @author=llim
    ${res}   Cli    ${device}    show file transfer-status
    # Result Should Not Contain    In progress
    Should Not Contain Any    ${res}   In progress    Failed
    #Should Match Regexp    Curl\\s+succeeded|Curl\\s+failed|status\\s+Idle
    

Verify 99% Traffic Passed Successfully
    [Arguments]          ${device}     ${port}
    [Documentation]      Verify 99% Traffic Passed Successfully
    [Tags]               @author=llim
    ${result}    Cli    ${device}     show interface pon ${port} usage
    ${egress}    Should Match Regexp    ${result}    egress-avg-bps(\\s+)(\\d+)
    ${ingress}   Should Match Regexp    ${result}    ingress-avg-bps(\\s+)(\\d+)
    Should Be True    99 <= round(100 * ${ingress[2]} / ${egress[2]},1) <= 100
    
Configure User-Defined Users
    [Arguments]    ${device}
    [Documentation]    Configure User-Defined Aaa User
    [Tags]    @author=llim
    Cli With Error Check    ${device}    configure
    Cli With Error Check    ${device}    aaa user authorizeduser password authorized role admin
    Cli With Error Check    ${device}    aaa user unauthorizeduser password unauthorized role oper
    Cli With Error Check    ${device}    end
    
Verify User-Defined Users
    [Arguments]    ${device}
    [Documentation]    Verify User-Defined Aaa User
    [Tags]    @author=llim
    Cli    ${device}    show running-config aaa user    prompt=\\#
    Result Should Contain   authorizeduser
    Result Should Contain   unauthorizeduser
    
Verify No User-Defined Users Configured
    [Arguments]    ${device}
    [Documentation]    Verify No User-Defined Aaa User
    [Tags]    @author=llim
    Cli    ${device}    show running-config aaa user    prompt=\\#
    Result Should Not Contain    authorizeduser
    Result Should Not Contain    unauthorizeduser
    
Verify No Gos Profile Configured
    [Arguments]    ${device}   
    [Documentation]    Verify No Gos Profile configured is successful
    [Tags]    @author=llim
    cli    ${device}    show running-config grade-of-service
    Result Should Contain    No entries found.
    
#Power Cycle Platform Via -48v Power Web
#    [Arguments]    ${browser}    ${url}    ${uname}    ${pword}    ${port}
#    [Documentation]  Power Cycle Platform Via -48v Power Web
#    [Tags]    @author=llim
#    ${str}    Catenate    xpath=//a[@href="outlet?${port}=CCL"]
#    Go To Page    ${browser}    ${url}
#    input_text    ${browser}    name=Username    ${uname}
#    input_text    ${browser}    name=Password    ${pword}
#    Submit Form      ${browser}    xpath=//form[@name='login']
#    Click Element    ${browser}    ${str}
#    Close Browser    ${browser}

    
Configure Class Map
	[Arguments]     ${device}     ${Cmaptype}     ${Cmapname}    ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Configure Class Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Configure Class Map | n1 | ethernet | CM1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     class-map ${Cmaptype} ${Cmapname}
	Cli With Error Check     ${device}     flow 1 rule 1 match untagged
	Cli With Error Check     ${device}     exit
	Cli With Error Check     ${device}     flow 1 rule 2 match vlan ${service_vlan_1}
	Cli With Error Check     ${device}     end 

Configure Policy Map
	[Arguments]     ${device}     ${Pmapname}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Configure Policy Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Pmapname | policy-map name |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Configure Policy Map | n1 | PM1 | ethernet | CM1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     policy-map ${Pmapname}
	Cli With Error Check     ${device}     class-map-${Cmaptype} ${Cmapname}
	Cli With Error Check     ${device}     flow 1
	Cli With Error Check     ${device}     end 

Configure Transport Service Profile
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Configure Transport Service Profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Configure Transport Service Profile | n1 | 103 |
	Cli With Error Check     ${device}	   configure
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     vlan-list ${service_vlan_1}
	Cli With Error Check     ${device}     end 

Verify Transport Service
	[Arguments]     ${device} 	${service_vlan_1}
	[Documentation]     [Author:llim] Description: Verify Transport Service
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Verify Transport Service | n1 | 103 |
	Cli With Error Check     ${device}     show running-config transport-service-profile
	Result Should Contain     transport-service-profile SYSTEM_TSP
	${vlan_str}     Convert to String     ${service_vlan_1}
	Result Should Contain     ${vlan_str}

Verify Class Map
	[Arguments]     ${device}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Verify Class Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Verify Class Map | n1 | ethernet | CM1 |
	Cli With Error Check     ${device}     show running-config class-map ${Cmaptype} ${Cmapname} | details
	Result Should Contain	 ${Cmaptype}
	Result Should Contain    ${Cmapname}

Verify Policy Map
	[Arguments]     ${device}     ${Pmapname}
	[Documentation]     [Author:llim] Description: Verify Policy Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Pmapname | policy-map name |
    ...
    ...    Example:
    ...    | Verify Policy Map | n1 | PM1 |
	Cli With Error Check     ${device}     show running-config policy-map | details
	Result Should Contain    ${Pmapname}

Configure Ethernet Interface
	[Arguments]     ${device}     ${port1}
	[Documentation]     [Author:llim] Description: Configure Ethernet Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port1 | ethernet port |
    ...
    ...    Example:
    ...    | Configure Ethernet Interface | n1 | 1/1/x1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     interface ethernet ${port1}
	Cli With Error Check     ${device}     switchport ENABLED
	Cli With Error Check     ${device}     role inni
	Cli With Error Check     ${device}     lldp admin-state enable
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     end 

Configure Vlan
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Configure Vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Configure Vlan | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     vlan ${service_vlan_1}
	Cli With Error Check	 ${device}     mode N2ONE
	Cli With Error Check     ${device}     l3-service DISABLED
	Cli With Error Check     ${device}     end 

Configure Ont Interface
	[Arguments]     ${device}     ${ont_num}     ${service_vlan_1}    ${Pmapname}    ${ont_port}    
	[Documentation]     [Author:llim] Description: Configure Ont Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_num | ont ID/number |
    ...    | service_vlan_1 | service vlan value |
    ...    | Pmapname | policy-map name |
    ...    | ont_port | ont-ethernet port |
    ...
    ...    Example:
    ...    | Configure Ont Interface | n1 | 882 | 103 | PM1 | g1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     interface ont-ethernet ${ont_num}/${ont_port}
	Cli With Error Check     ${device}     vlan ${service_vlan_1}
	Cli With Error Check     ${device}     policy-map ${Pmapname}
	Cli With Error Check     ${device}     end 

Verify Ont Interface
	[Arguments]     ${device}     ${service_vlan_1}     ${Pmapname}     ${ont_num}     ${ont_port}
	[Documentation]     [Author:llim] Description: Verify Ont Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...    | Pmapname | policy-map name |
    ...    | ont_num | ont ID/number |
    ...    | ont_port | ont-ethernet port |
    ...
    ...    Example:
    ...    | Verify Ont Interface | n1 | 103 | PM1 | 882 | g1 |
	Cli With Error Check      ${device}     show running-config interface ont-ethernet
	Result Should Contain     vlan ${service_vlan_1}
	Result Should Contain     policy-map ${Pmapname}
	Result Should Contain     interface ont-ethernet ${ont_num}/${ont_port}

Unconfigure Ont Interface
	[Arguments]     ${device}     ${ont_num}     ${ont_port}     ${service_vlan_1}     ${Pmapname}
	[Documentation]     [Author:llim] Description: Unconfigure Ont Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_num | ont ID/number |
    ...    | ont_port | ont-ethernet port |
    ...    | service_vlan_1 | service vlan value |
    ...    | Pmapname | policy-map name |
    ...
    ...    Example:
    ...    | Unconfigure Ont Interface | n1 | 882 | g1 | 103 | PM1 |
    Cli     ${device}     configure
	Cli     ${device}     interface ont-ethernet ${ont_num}/${ont_port}
	Cli     ${device}     vlan ${service_vlan_1}
	Cli     ${device}     no policy-map ${Pmapname}
	Cli     ${device}     exit
	Cli     ${device}	  no vlan ${service_vlan_1}
	Cli     ${device}     end 

Unconfigure Class Map
	[Arguments]     ${device}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Unconfigure Class Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Unconfigure Class Map | n1 | ethernet | CM1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     no class-map ${Cmaptype} ${Cmapname}
	Cli With Error Check     ${device}     end 

Unconfigure Policy Map
	[Arguments]     ${device}     ${Pmapname}     ${Cmaptype}     ${Cmapname}
	[Documentation]     [Author:llim] Description: Unconfigure Policy Map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | Pmapname | policy-map name |
    ...    | Cmaptype | class-map type |
    ...    | Cmapname | class-map name |
    ...
    ...    Example:
    ...    | Unconfigure Policy Map | n1 | PM1 | ethernet | CM1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     no policy-map ${Pmapname}
	Cli With Error Check     ${device}     end 

Unconfigure Transport Service Profile
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Unconfigure Transport Service Profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Unconfigure Transport Service Profile | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     no vlan-list ${service_vlan_1}
	Cli With Error Check     ${device}     end 

Unconfigure Ethernet Interface
	[Arguments]     ${device}     ${port1}
	[Documentation]     [Author:llim] Description: Unconfigure Ethernet Interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port1 | ethernet port name |
    ...
    ...    Example:
    ...    | Unconfigure Ethernet Interface | n1 | 1/1/x1 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     interface ethernet ${port1}
	Cli With Error Check     ${device}     no transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     lldp admin-state disable
	Cli With Error Check     ${device}     no role 
	Cli With Error Check     ${device}     switchport DISABLED
	Cli With Error Check     ${device}     end

Unconfigure Vlan From Transport Service Profile
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Unconfigure Vlan From Transport Service Profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Unconfigure Vlan From Transport Service Profile | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     transport-service-profile SYSTEM_TSP
	Cli With Error Check     ${device}     no vlan ${service_vlan_1}
	Cli With Error Check     ${device}     end

Unconfigure Vlan
	[Arguments]     ${device}     ${service_vlan_1}
	[Documentation]     [Author:llim] Description: Unconfigure Vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | service_vlan_1 | service vlan value |
    ...
    ...    Example:
    ...    | Unconfigure Vlan | n1 | 103 |
	Cli With Error Check     ${device}     configure
	Cli With Error Check     ${device}     no vlan ${service_vlan_1}
	Cli With Error Check     ${device}     end
	
Verify Session No Error
 	[Arguments]     ${device}
	[Documentation]     [Author:llim] Description: Verify Session No Error
    Cli     ${device}     show session notifications
    Result Should Not Contain    rror
    Result Should Not Contain    Warning
    Result Should Not Contain    Invalid
    Result Should Not Contain    Aborted


    