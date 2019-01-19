*** Settings ***
Documentation     Alarms-Events-Syslog keyword lib
Library           String
Library           Collections
Library           XML    use_lxml=True
Library           DateTime
Library           OperatingSystem

*** Keywords ***
Check Inventory
    [Arguments]    ${device}
    [Documentation]    Check type of hardware
    [Tags]    @author=ssekar
    ${result}    cli    ${device}    show inventory    prompt=\\#      timeout=10
    ${shelfslot}    Set Variable If    ${result.__contains__('E3-2')}==True    shelf 1 slot 1    !
    [Return]    ${shelfslot}

ROLT Image Version
    [Arguments]    ${device}
    [Documentation]    Show ROLT Software version
    [Tags]    @author=ssekar
    cli    ${device}    show version    prompt=\\#      timeout=50

Configure Interface IPv4
    [Arguments]    ${device}    ${port}    ${ipaddr}    ${mask}
    [Documentation]    Identify Interface configuration based on ROLT or E5
    [Tags]    @author=ssekar
    ${result}    cli    ${device}    show inventory    prompt=\\#        timeout=50
    Run Keyword If    ${result.__contains__('E3-2')}==True    Configure Interface IPv4 ROLT    ${device}    ${port}    ${ipaddr}    ${mask}
    Run Keyword If    ${result.__contains__('E5-520')}==True    Configure Interface IPv4 E5    ${device}    ${port}    ${ipaddr}    ${mask}

Configure Interface IPv4 E5
    [Arguments]    ${device}    ${port}    ${ipaddr}    ${mask}
    [Documentation]    Configure Interface with IPv4 address on E5 device
    [Tags]    @author=ssekar
    cli    ${device}    configure       timeout=50
    cli    ${device}    interface ethernet ${port}          timeout=50
    cli    ${device}    no shutdown     timeout=50
    cli    ${device}    no ip address    timeout=10    timeout_exception=0    prompt=\\#
    cli    ${device}    ip address ${ipaddr} prefix-length ${mask}      timeout=50
    cli    ${device}    end    prompt=\\#

Configure Interface IPv4 ROLT
    [Arguments]    ${device}    ${port}    ${ipaddr}    ${mask}
    [Documentation]    Configure Interface with IPv4 address on ROLT
    [Tags]    @author=ssekar
    cli    ${device}    configure
    cli    ${device}    interface ethernet ${port}
    cli    ${device}    no switchport
    cli    ${device}    no shutdown
    cli    ${device}    no ip address    timeout=10    timeout_exception=0    prompt=\\#
    cli    ${device}    ip address ${ipaddr} prefix-length ${mask}
    cli    ${device}    end    prompt=\\#

Unconfigure Interface IPv4
    [Arguments]    ${device}    ${port}
    [Documentation]    Unconfigure Interface IPv4
    [Tags]    @author=ssekar
    cli    ${device}    configure
    cli    ${device}    interface ethernet 1/1/${port}
    cli    ${device}    no ip address    timeout=10    timeout_exception=0    prompt=\\#
    cli    ${device}    end    prompt=\\#

Interface_shut_calix_ROLT
    [Arguments]    ${device}    ${port}
    [Documentation]    Shutdown the Interface
    [Tags]    @author=ssekar
    cli    ${device}    configure
    cli    ${device}    shelf 1 slot 1
    cli    ${device}    interface ethernet 1/1/${port}
    cli    ${device}    shutdown
    cli    ${device}    end    prompt=\\#

Interface_noshut_calix_ROLT
    [Arguments]    ${device}    ${port}
    [Documentation]    Unshut the Interface
    [Tags]    @author=ssekar
    cli    ${device}    configure
    cli    ${device}    shelf 1 slot 1
    cli    ${device}    interface ethernet 1/1/${port}
    cli    ${device}    no shutdown
    cli    ${device}    end    prompt=\\#

Verify IP Configuration
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify IP Configuration on ROLT/E5
    [Tags]        @author=ssekar
    cli    ${device}    show ip interface interface ${port}
    Result Should Contain    enable
    Result Should Contain    up

Verify alarms filtered by address
    [Arguments]    ${device}    ${disable_port}
    [Documentation]    Verify Active alarms filtered by address using key and value
    [Tags]        @author=ssekar
    ${result}=    cli    ${device}    show alarm active address key port value ${disable_port}      timeout=50
    Result Should Contain    description loss of signal
    Result Should Contain    ${disable_port}']
    Should Match Regexp    ${result}    .*(${disable_port}'])

Verify alarms filtered by address netconf
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Active alarms filtered by address using key and value
    [Tags]        @author=ssekar
    ${result}=     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-address xmlns="http://www.calix.com/ns/exa/base"><key>port</key><value>${port}</value></show-alarm-instances-active-address></rpc>
    Should Contain    ${result.xml}     <name>loss-of-signal</name> 
    Should Contain    ${result.xml}     ${port}']</address>

Getting instance-id from Triggered alarms
    [Arguments]    ${device}    ${alarm}     ${env}=false
    [Documentation]    Getting instance-id from Triggered alarms
    [Tags]        @author=ssekar
    ${command}    Set Variable If    '${alarm}' == 'ethernet_rmon'     show alarm active subscope id 1221     
    ...           '${alarm}' == 'running_config_unsaved'     show alarm active subscope id 702    
    ...           '${alarm}' == 'loss_of_signal'       show alarm active subscope id 1201      
    ...           '${alarm}' == 'ntp_prov'       show alarm active subscope id 1919    
    ...           '${alarm}' == 'app_sus'        show alarm active subscope id 1702      
    ...           '${alarm}' == 'source-verify-resources-limited'     show alarm active subscope id 2302
    ...           '${env}' == 'true'       show alarm active subscope name ${alarm}  

    ${result}     cli    ${device}      ${command}      timeout=50
    @{result}    Get Regexp Matches    ${result}    instance-id ([0-9.]+)    1
    ${instance-id}    Get From List    ${result}    0
    [Return]    ${instance-id}

Verifying Alarm history stores the cleared alarm
    [Arguments]    ${device}    ${instance-id}      ${alarm}
    [Documentation]    Verifying Alarm history stores the cleared alarm
    [Tags]        @author=ssekar

    ${result}     cli    ${device}      show alarm history subscope instance-id ${instance-id}
    Should Contain    ${result}      perceived-severity CLEAR
    Should Contain    ${result}      name ${alarm}


Getting instance-id from Triggered alarms using netconf
    [Arguments]    ${device}    ${alarm}
    [Documentation]    Getting instance-id from Triggered alarms
    [Tags]        @author=ssekar
    ${command}   Set Variable If     '${alarm}' == 'ethernet_rmon'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1221</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...           '${alarm}' == 'running_config_unsaved'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>702</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...           '${alarm}' == 'ntp_prov'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1919</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...           '${alarm}' == 'app_sus'       <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1702</id></show-alarm-instances-active-subscope></rpc>]]>]]>

    Log    *** Getting instance-id from triggered active alarm ***
    ${show_alarm}=    Netconf Raw    n1_netconf    xml=${command}
    Run Keyword If    '${alarm}' == 'running_config_unsaved'       Should contain    ${show_alarm.xml}      <name>running-config-unsaved</name>
    Run Keyword If    '${alarm}' == 'ethernet_rmon'       Should contain    ${show_alarm.xml}     <name>ethernet-rmon-session-stopped</name>
    Run Keyword If    '${alarm}' == 'ntp_prov'       Should contain    ${show_alarm.xml}     <name>ntp-prov</name>
    ${str}=    Convert to string    ${show_alarm}
    ${instanceid}=    Get Lines Containing String    ${str}    instance-id
    ${first}=    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0
    [Return]    ${instance_id}

Clearing RMON MINOR alarm
    [Arguments]    ${linux}=None    ${device}=None      ${user_interface}=None       ${rmonport}=x1
    [Documentation]    Clearing RMON alarm
    [Tags]        @author=ssekar

    ${port_id}    Run Keyword If    '${user_interface}' == 'cli'    cli    ${device}    show interface ethernet status oper-state | tab      timeout=50
    @{port_id}      Run Keyword If      '${user_interface}' == 'cli'     Get Regexp Matches     ${port_id}      ([0-9a-z/]+).*    1
    ${port_id}      Run Keyword If     '${user_interface}' == 'cli'     Get From List     ${port_id}      1

    ${result}    Run Keyword If    '${user_interface}' == 'cli'   cli    ${device}    show inventory    prompt=\\#      timeout=50
    Run Keyword If    '${user_interface}' == 'cli'    cli    ${device}    configure    timeout=50
    ${port}    Run Keyword If    '${user_interface}' == 'cli'   Set Variable If    ${result.__contains__('${hostname}')}==True     ${port_id}      ${rmonport}
    Run Keyword If    '${user_interface}' == 'cli'   Run Keywords    cli    ${device}    interface ethernet ${port}      timeout=50
    ...   AND      cli    ${device}    no shut      timeout=50 
    ...   AND      cli    ${device}    rmon-session one-minute 60      timeout=50
    ...   AND      cli    ${device}    admin-state enable     timeout=50
    ...   AND      cli    ${device}    end    prompt=\\#       timeout=50
    ...   AND      cli    ${device}    accept running-config      timeout=50
    ...   AND      cli    ${device}    copy running-config startup-config      timeout=50

    ${net_port_id}    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<rpc message-id="m-33" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><interfaces-state xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name></name><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type></interface></interfaces-state></filter></get></rpc> ]]>]]>
    ${net_port_id}    Run Keyword If     '${user_interface}' == 'netconf'    Convert to string    ${net_port_id}
    ${net_port_id}      Run Keyword If    '${user_interface}' == 'netconf'    Get Regexp Matches    ${net_port_id}      <interface><name>([0-9a-z/]+)</name>     1
    ${net_port_id}      Run Keyword If     '${user_interface}' == 'netconf'    Get From List    ${net_port_id}   1

 
    ${result}    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter xmlns="http://www.calix.com/ns/exa/base"><status><system><inventory/></system></status></filter></get></rpc>]]>]]>
    ${str}      Run Keyword If    '${user_interface}' == 'netconf'   Convert to string     ${result}
    ${port}    Run Keyword If    '${user_interface}' == 'netconf'    Set Variable If    ${str.__contains__('${hostname}')}==True    ${net_port_id}     ${rmonport}
    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${port}</name><ethernet xmlns="http://www.calix.com/ns/ethernet-std"><rmon-session><bin-duration>one-minute</bin-duration><bin-count>60</bin-count><admin-state>enable</admin-state></rmon-session></ethernet></interface></interfaces></config></edit-config></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>

    #Sleep for 5s in total to clear the alarm
    BuiltIn.Sleep    5s    
    ${result}    Run Keyword If    '${user_interface}' == 'cli'      cli    ${device}    show alarm active subscope name ethernet-rmon-session-stopped     timeout=50
    Run Keyword If    '${user_interface}' == 'cli'    Should Not Contain    ${result}     ${port_id}']

    ${result}      Run Keyword If    '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>ethernet-rmon-session-stopped</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'     Should Not Contain    ${result.xml}     ${net_port_id}']

Triggering RMON MINOR alarm
    [Arguments]    ${linux}=None    ${device}=None      ${user_interface}=None      ${rmonport}=x1
    [Documentation]    Trigerring RMON alarm
    [Tags]        @author=ssekar

    ${port_id}    Run Keyword If    '${user_interface}' == 'cli'    cli    ${device}    show interface ethernet status oper-state | tab      timeout=50
    @{port_id}      Run Keyword If      '${user_interface}' == 'cli'     Get Regexp Matches     ${port_id}      ([0-9a-z/]+).*    1
    ${port_id}      Run Keyword If     '${user_interface}' == 'cli'     Get From List     ${port_id}      1
 
    ${result}    Run Keyword If    '${user_interface}' == 'cli'   cli    ${device}    show inventory    prompt=\\#      timeout=50
    Run Keyword If    '${user_interface}' == 'cli'    cli    ${device}    configure     timeout=50
    ${port}    Run Keyword If    '${user_interface}' == 'cli'   Set Variable If    ${result.__contains__('${hostname}')}==True    ${port_id}      ${rmonport}
    Run Keyword If    '${user_interface}' == 'cli'   Run Keywords    cli    ${device}    interface ethernet ${port}       timeout=50
    ...   AND      cli    ${device}    no shut     timeout=50
    ...   AND      cli    ${device}    no rmon-session      timeout=50
    ...   AND      cli    ${device}    rmon-session one-minute 60      timeout=50
    ...   AND      cli    ${device}    admin-state enable      timeout=50
    ...   AND      cli    ${device}    admin-state disable       timeout=50
    ...   AND      cli    ${device}    end    prompt=\\#       timeout=50

    ${net_port_id}    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<rpc message-id="m-33" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><interfaces-state xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name></name><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type></interface></interfaces-state></filter></get></rpc> ]]>]]>
    ${net_port_id}    Run Keyword If     '${user_interface}' == 'netconf'    Convert to string    ${net_port_id}
    ${net_port_id}      Run Keyword If    '${user_interface}' == 'netconf'    Get Regexp Matches    ${net_port_id}      <interface><name>([0-9a-z/]+)</name>     1
    ${net_port_id}      Run Keyword If     '${user_interface}' == 'netconf'    Get From List    ${net_port_id}   1

    ${result}    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter xmlns="http://www.calix.com/ns/exa/base"><status><system><inventory/></system></status></filter></get></rpc>]]>]]>
    ${str}      Run Keyword If    '${user_interface}' == 'netconf'   Convert to string     ${result}
    ${port}    Run Keyword If    '${user_interface}' == 'netconf'      Set Variable If    ${str.__contains__('${hostname}')}==True    ${net_port_id}     ${rmonport}

    ${remove_rmon}    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get-config><source><running/></source><filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${port}</name><description/><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><ethernet xmlns="http://www.calix.com/ns/ethernet-std"><rmon-session><bin-duration>one-minute</bin-duration><bin-count></bin-count></rmon-session></ethernet></interface></interfaces></filter></get-config></rpc>]]>]]>
    ${remove_rmon_str}       Run Keyword If    '${user_interface}' == 'netconf'   Convert to string     ${remove_rmon}
    ${remove_rmon_str}       Run Keyword If    '${user_interface}' == 'netconf'   Get Regexp Matches    ${remove_rmon_str}      <bin-count>([0-9]+)</bin-count>     1
    ${remove_len}    Run Keyword If    '${user_interface}' == 'netconf'   Get Length    ${remove_rmon_str}
    ${remove_rmon_str}       Run Keyword If    '${user_interface}' == 'netconf' and ${remove_len} > 0    Get From List    ${remove_rmon_str}       0
    Run Keyword If    '${user_interface}' == 'netconf' and ${remove_len} > 0     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${port}</name><ethernet xmlns="http://www.calix.com/ns/ethernet-std"><rmon-session xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete"><bin-duration>one-minute</bin-duration><bin-count>${remove_rmon_str}</bin-count></rmon-session></ethernet></interface></interfaces></config></edit-config></rpc>]]>]]>


    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${port}</name><ethernet xmlns="http://www.calix.com/ns/ethernet-std"><rmon-session><bin-duration>one-minute</bin-duration><bin-count>60</bin-count><admin-state>disable</admin-state></rmon-session></ethernet></interface></interfaces></config></edit-config></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>

    #Sleep for 5s in total to populate the alarm
    BuiltIn.Sleep    5s    
    ${result}    Run Keyword If    '${user_interface}' == 'cli'      cli    ${device}    show alarm active subscope name ethernet-rmon-session-stopped     timeout=50
    Run Keyword If    '${user_interface}' == 'cli'    Should Contain    ${result}    name ethernet-rmon-session-stopped
    Run Keyword If    '${user_interface}' == 'cli'    Should Contain    ${result}      ${port_id}']

    ${result}      Run Keyword If    '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>ethernet-rmon-session-stopped</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'     Should Contain    ${result.xml}    <id>1221</id>
    Run Keyword If    '${user_interface}' == 'netconf'     Should Contain    ${result.xml}     <description>Ethernet port rmon-session has been stopped</description>

Verifying alarms filtered by time
    [Arguments]    ${device}    ${total_count}     ${alarm_type}=active
    [Documentation]    Verifying alarms filtered by time
    [Tags]        @author=ssekar
    ${result}    Run Keyword If   '${alarm_type}' == 'active'     cli    ${device}    show alarm active subscope count ${total_count}      timeout=90    
    ...     ELSE IF    '${alarm_type}' == 'history'     cli    ${device}    show alarm history subscope count ${total_count}     timeout=90
    Should Contain    ${result}      total-count ${total_count}
    @{match}    GetRegexp Matches    ${result}       ne-event-time ([0-9A-Z:+\-]+)     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 50     50    ${len}
    ${tot_count}=    Evaluate    ${len}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${len}-1)    modules=random
    ${start_time}       Get From List     ${match}    ${start}
    ${end_time}         Get From List     ${match}    ${end}
    @{time}    GetRegexp Matches    ${start_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    @{time1}    GetRegexp Matches    ${end_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    ${tuple}    Get From List    ${time}    0
    ${tuple1}    Get From List    ${time1}    0
    @{list}    Convert To List    ${tuple}
    @{list1}    Convert To List    ${tuple1}
    ${year1}    Get From List    ${list}    0
    ${year2}    Get From List    ${list1}    0
    ${month1}    Get From List    ${list}    1
    ${month2}    Get From List    ${list1}    1
    ${day1}    Get From List    ${list}    2
    ${day2}    Get From List    ${list1}    2
    ${hour1}    Get From List    ${list}    3
    ${hour2}    Get From List    ${list1}    3
    ${min1}    Get From List    ${list}    4
    ${min2}    Get From List    ${list1}    4
    ${sec1}    Get From List    ${list}    5
    ${sec2}    Get From List    ${list1}    5
    ${yr_chk}    Evaluate    ($year1 < $year2 )
    ${mon_chk}    Evaluate    ($year1 == $year2 and $month1 < $month2)
    ${day_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 < $day2)
    ${hrs_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 < $hour2)
    ${mins_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 == $hour2 and $min1 < $min2)
    ${sec_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 <= $day2 and $hour1 == $hour2 and $min1 == $min2 and $sec1 <= $sec2)
    ${tty}    Evaluate    ($yr_chk or $mon_chk or $day_chk or $hrs_chk or $mins_chk or $sec_chk == True)
    ${x}    Set Variable If    ${tty} == False    ${end_time}    ${start_time}
    ${end_time}    Set Variable If    ${tty} == False    ${start_time}    ${end_time}
    ${start_time}    Set Variable If    ${tty} == False    ${x}    ${x}
    ${result}    Run Keyword If   '${alarm_type}' == 'active'    cli    ${device}     show alarm active timerange start-time ${start_time} end-time ${end_time}    timeout=90
    ...      ELSE IF    '${alarm_type}' == 'history'    cli    ${device}     show alarm history timerange start-time ${start_time} end-time ${end_time}    timeout=90
    Run Keyword If   '${alarm_type}' == 'active' or '${alarm_type}' == 'history'     Run Keywords     Should Contain    ${result}     ne-event-time ${start_time}
    ...       AND     Should Contain    ${result}     ne-event-time ${end_time}
    ${start_datetime} =      Convert Date        ${start_time}      datetime
    ${start_datetime}     Convert Date        ${start_time}      epoch
    ${end_datetime} =      Convert Date        ${end_time}        datetime
    ${end_datetime}         Convert Date        ${end_datetime}      epoch
    @{match}    Get Regexp Matches    ${result}     ne-event-time ([0-9A-Z:+\-]+)    1
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    Log    ${INDEX}
    \    ${time}    Get From List    ${match}    ${INDEX}
    \    ${result_datetime}     Convert Date        ${time}      datetime
    \    ${result_datetime}     Convert Date      ${result_datetime}    epoch
    #\    ${result_datetime}    Convert To Integer    ${result_datetime}
    \    Should Be True    ${result_datetime} >= ${start_datetime}
    \    Should Be True    ${result_datetime} <= ${end_datetime} 

Verifying alarms filtered by time using netconf
    [Arguments]    ${device}    ${total_count}     ${alarm_type}=active
    [Documentation]    Verifying alarms filtered by time using netconf
    [Tags]        @author=ssekar

    ${result}    Run Keyword If   '${alarm_type}' == 'active'    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...       ELSE IF      '${alarm_type}' == 'history'     Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    ...       ELSE IF      '${alarm_type}' == 'archive'     Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-archive-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}     <ne-event-time>([0-9A-Z:+\-]+)</ne-event-time>    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    ${tot_count}=    Evaluate    ${len}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${len}-1)    modules=random
    ${start_time}       Get From List     ${match}    ${start}
    ${end_time}         Get From List     ${match}    ${end}
    @{time}    GetRegexp Matches    ${start_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    @{time1}    GetRegexp Matches    ${end_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    ${tuple}    Get From List    ${time}    0
    ${tuple1}    Get From List    ${time1}    0
    @{list}    Convert To List    ${tuple}
    @{list1}    Convert To List    ${tuple1}
    ${year1}    Get From List    ${list}    0
    ${year2}    Get From List    ${list1}    0
    ${month1}    Get From List    ${list}    1
    ${month2}    Get From List    ${list1}    1
    ${day1}    Get From List    ${list}    2
    ${day2}    Get From List    ${list1}    2
    ${hour1}    Get From List    ${list}    3
    ${hour2}    Get From List    ${list1}    3
    ${min1}    Get From List    ${list}    4
    ${min2}    Get From List    ${list1}    4
    ${sec1}    Get From List    ${list}    5
    ${sec2}    Get From List    ${list1}    5
    ${yr_chk}    Evaluate    ($year1 < $year2 )
    ${mon_chk}    Evaluate    ($year1 == $year2 and $month1 < $month2)
    ${day_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 < $day2)
    ${hrs_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 < $hour2)
    ${mins_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 == $hour2 and $min1 < $min2)
    ${sec_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 <= $day2 and $hour1 == $hour2 and $min1 == $min2 and $sec1 <= $sec2)
    ${tty}    Evaluate    ($yr_chk or $mon_chk or $day_chk or $hrs_chk or $mins_chk or $sec_chk == True)
    ${x}    Set Variable If    ${tty} == False    ${end_time}    ${start_time}
    ${end_time}    Set Variable If    ${tty} == False    ${start_time}    ${end_time}
    ${start_time}    Set Variable If    ${tty} == False    ${x}    ${x}
    ${result}    Run Keyword If   '${alarm_type}' == 'active'    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-timerange xmlns="http://www.calix.com/ns/exa/base"><start-time>${start_time}</start-time><end-time>${end_time}</end-time></show-alarm-instances-active-timerange></rpc>]]>]]>
    ...    ELSE IF     '${alarm_type}' == 'history'    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-timerange xmlns="http://www.calix.com/ns/exa/base"><start-time>${start_time}</start-time><end-time>${end_time}</end-time></show-alarm-instances-history-timerange></rpc>]]>]]>
    ...    ELSE IF     '${alarm_type}' == 'archive'    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-timerange xmlns="http://www.calix.com/ns/exa/base"><start-time>${start_time}</start-time><end-time>${end_time}</end-time></show-alarm-instances-archive-timerange></rpc>]]>]]>
    Log      ${result}
    #Sleep for 6s in total to populate the result
    BuiltIn.Sleep    6s
    Run Keyword If   '${alarm_type}' == 'active' or '${alarm_type}' == 'history' or '${alarm_type}' == 'archive'     Run Keywords     Should Contain    ${result.xml}     <ne-event-time>${start_time}</ne-event-time>
    ...       AND     Should Contain    ${result.xml}     <ne-event-time>${end_time}</ne-event-time>
    ${start_datetime} =      Convert Date        ${start_time}      datetime
    ${start_datetime}     Convert Date        ${start_time}      epoch
    #${start_datetime}     Convert To Integer    ${start_datetime}
    ${end_datetime} =      Convert Date        ${end_time}        datetime
    ${end_datetime}         Convert Date        ${end_datetime}      epoch
    #${end_datetime}      Convert To Integer    ${end_datetime}
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}     <ne-event-time>([0-9A-Z:+\-]+)</ne-event-time>    1
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    Log    ${INDEX}
    \    ${time}    Get From List    ${match}    ${INDEX}
    \    ${result_datetime}     Convert Date        ${time}      datetime
    \    ${result_datetime}     Convert Date      ${result_datetime}    epoch
    #\    ${result_datetime}    Convert To Integer    ${result_datetime}
    \    Should Be True    ${result_datetime} >= ${start_datetime}
    \    Should Be True    ${result_datetime} <= ${end_datetime}

Configuring OSPF on Cisco
    [Arguments]    ${device}    ${device_ip}     ${user}   ${password}   ${enable_pw}     ${network1}    ${network2}     ${port1}      ${port2}     ${ip_addr_1} 
    ...            ${ip_addr_2}       ${prefix_length}
    [Documentation]      Configuring OSPF on Cisco
    [Tags]        @author=ssekar

    Telnet.Open Connection     ${device_ip}        timeout=30
    Telnet.Login        ${user}      ${password}    login_prompt=Username:   password_prompt=Password:     login_timeout=10 seconds
    Telnet.Write        enable
    Telnet.Write        ${enable_pw}
    Telnet.Write        configure terminal
    Telnet.Read Until      (config)#
    Telnet.Write        router ospf 1
    Telnet.Write        area 0.0.0.255 nssa
    Telnet.Write        network ${network1} 0.0.0.255 area 0.0.0.255
    Telnet.Write        network ${network2} 0.0.0.255 area 0.0.0.255
    Telnet.Write        exit
    Telnet.Write        interface ${port1}
    Telnet.Write        ip address ${ip_addr_1} ${prefix_length}
    Telnet.Write        no shut
    Telnet.Write        interface ${port2}
    Telnet.Write        ip address ${ip_addr_2} ${prefix_length}
    Telnet.Write        no shut
    Telnet.Write        end
    Telnet.Write        exit
    
Unconfigure OSPF on Cisco
    [Arguments]    ${device}    ${device_ip}     ${user}   ${password}   ${enable_pw}     
    [Documentation]      Unconfigure OSPF on Cisco
    [Tags]        @author=ssekar

    Telnet.Open Connection     ${device_ip}        timeout=30
    Telnet.Login        ${user}      ${password}    login_prompt=Username:   password_prompt=Password:     login_timeout=10 seconds
    Telnet.Write        enable
    Telnet.Write        ${enable_pw}
    Telnet.Write        configure terminal
    Telnet.Read Until      (config)#
    Telnet.Write        no router ospf 1
    Telnet.Write        end
    Telnet.Write        exit

Shutting down the port on Cisco
    [Arguments]    ${device}    ${device_ip}     ${user}   ${password}   ${enable_pw}     ${port}
    [Documentation]    Shutting down the port on Cisco
    [Tags]        @author=ssekar

    Telnet.Open Connection     ${device_ip}        timeout=30	
    Telnet.Login       ${user}      ${password}    login_prompt=Username:   password_prompt=Password:     login_timeout=10 seconds
    Telnet.Write      enable
    Telnet.Write      ${enable_pw}
    Telnet.Write      configure terminal
    Telnet.Read Until      (config)#
    #Sleep for 5s before shutting down the port 
    Sleep    5s
    Telnet.Write       interface ${port}
    Telnet.Write      no shut
    Telnet.Write      shut
    Telnet.Write      end
    Telnet.Write      exit
    #Sleep for 5s after shutting down the port
    Sleep    5s

Enabling the Cisco shutdown port
    [Arguments]    ${device}    ${device_ip}     ${user}   ${password}   ${enable_pw}     ${port}
    [Documentation]    Shutting down the port on Cisco
    [Tags]        @author=ssekar

    Telnet.Open Connection     ${device_ip}        timeout=30
    Telnet.Login       ${user}      ${password}    login_prompt=Username:   password_prompt=Password:     login_timeout=10 seconds
    Telnet.Write      enable
    Telnet.Write      ${enable_pw}
    Telnet.Write      configure terminal
    Telnet.Read Until       (config)#
    #Sleep for 5s before enabling the port
    Sleep      5s
    Telnet.Write       interface ${port}
    Telnet.Write      shut
    Telnet.Write      no shut
    Telnet.Write      end
    Telnet.Write      exit
    #Sleep for 5s after enabling the port
    Sleep    5s

Triggering Loss of Signal MAJOR alarm
    [Arguments]    ${device}=None     ${linux}=None     ${user_interface}=None
    [Documentation]    Triggering Loss of Signal MAJOR alarm
    [Tags]        @author=ssekar

    Log      ********** Netconf: Verifying Admin state of Ethernet interfaces are UP otherwise enabling it ************
    : FOR     ${INDEX}    IN RANGE    0    5
    \     ${admin_net}      Run Keyword If     '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<rpc message-id="m-33" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><interfaces-state xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name></name><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><admin-status>down</admin-status></interface></interfaces-state></filter></get></rpc> ]]>]]>
    \     ${str}       Run Keyword If     '${user_interface}' == 'netconf'      Convert to string    ${admin_net}
    \     @{portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Regexp Matches    ${str}      <interface><name>([0-9a-z/]+)</name>     1
    \     ${length_portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Length     ${portname}
    \     ${admin_net_status}     Run Keyword If     '${user_interface}' == 'netconf'   Set Variable If     ${length_portname} > 0       net_admin_down    net_admin_up
    \     Exit For Loop If      '${user_interface}' == 'netconf' and '${admin_net_status}' == 'net_admin_up'
    \     ${admin_net_id}     Run Keyword If     '${user_interface}' == 'netconf' and '${admin_net_status}' == 'net_admin_down'     Get From List    ${portname}    0
    \     Run Keyword If     '${user_interface}' == 'netconf' and '${admin_net_status}' == 'net_admin_down'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${admin_net_id}</name><enabled>true</enabled></interface></interfaces></config></edit-config></rpc>]]>]]> 
  

    Log      ********* Getting Interface which are in DOWN state in Netconf *********
    : FOR     ${INDEX}    IN RANGE    0    5
    \     ${result_netconf}    Run Keyword If     '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<rpc message-id="m-33" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><interfaces-state xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name></name><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><oper-status>down</oper-status></interface></interfaces-state></filter></get></rpc> ]]>]]>
    \     ${str}       Run Keyword If     '${user_interface}' == 'netconf'      Convert to string    ${result_netconf}
    \     @{portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Regexp Matches    ${str}      <interface><name>([0-9a-z/]+)</name>     1
    \     ${length_portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Length     ${portname}
    \     ${net_port_status}     Run Keyword If     '${user_interface}' == 'netconf'   Set Variable If     ${length_portname} > 0       net_port_down     net_port_up
    \     Log      ${net_port_status}
    \     ${net_port_id}    Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'    Get From List    ${portname}    0
    \     Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_up'       Shutting down the port on Cisco     device=n2_cisco    device_ip=${DEVICES.n2_cisco.ip}     user=${DEVICES.n2_cisco.user}     password=${DEVICES.n2_cisco.password}     enable_pw=${DEVICES.n2_cisco.enable_password}       port=${DEVICES.n2_cisco.ports.p1.port} 
    \    Exit For Loop If      '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'
   
    Log      ********** Shut and unshut interface for Alarm to get triggered in Netconf **********
    Run Keyword If     '${user_interface}' == 'netconf'     Run Keywords     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${net_port_id}</name><enabled>false</enabled></interface></interfaces></config></edit-config></rpc>]]>]]> 
    #Sleep for 7s for Alarms to generate properly after shut
    ...      AND     BuiltIn.Sleep    7s
    ...      AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${net_port_id}</name><enabled>true</enabled></interface></interfaces></config></edit-config></rpc>]]>]]>
    #Sleep for 10s after no shut
    ...      AND     BuiltIn.Sleep    10s

    Log      ********** CLI: Verifying Admin state of Ethernet interfaces are UP otherwise enabling it ************
    : FOR     ${INDEX}    IN RANGE    1    5
    \    ${admin_state}     Run Keyword If     '${user_interface}' == 'cli'    cli    ${device}    show interface ethernet status admin-state | tab | include disable      timeout=50           retry=4
    \    @{port_admin}     Run Keyword If     '${user_interface}' == 'cli'     Get Regexp Matches    ${admin_state}     ([0-9a-z/]+).*    1
    \    ${length_port_admin}     Run Keyword If     '${user_interface}' == 'cli'     Get Length     ${port_admin}
    \    ${port_admin_status}     Run Keyword If     '${user_interface}' == 'cli'     Set Variable If    ${length_port_admin} > 1     admin_ports_down     admin_all_ports_up
    \    Exit For Loop If      '${user_interface}' == 'cli' and '${port_admin_status}' == 'admin_all_ports_up'
    \    ${list_port_admin}    Run Keyword If     '${port_admin_status}' == 'admin_ports_down' and '${user_interface}' == 'cli'     Get From List    ${port_admin}    1
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down' and '${user_interface}' == 'cli'     cli    ${device}    configure      timeout=50
    \    ...      prompt=\\#     retry=4
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down' and '${user_interface}' == 'cli'     cli    ${device}    interface ethernet ${list_port_admin}
    \    ...      prompt=\\#     retry=4     timeout=50
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down' and '${user_interface}' == 'cli'     cli    ${device}    no shut    prompt=\\#     retry=4
    \    ...     timeout=50
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down' and '${user_interface}' == 'cli'     cli    ${device}    end    timeout=50    prompt=\\# 
    \    ...     retry=4

    Log      ********** Getting Interface which are in DOWN state in cli ************
    : FOR     ${INDEX}    IN RANGE    1    5
    \    ${result}    Run Keyword If     '${user_interface}' == 'cli'    cli    ${device}    show interface ethernet status oper-state | tab | include down   
    \    ...     timeout=50           retry=4
    \    @{port_id}    Run Keyword If     '${user_interface}' == 'cli'     Get Regexp Matches    ${result}    ([0-9a-z/]+).*    1
    \    ${length_port_id}   Run Keyword If     '${user_interface}' == 'cli'      Get Length     ${port_id} 
    \    ${port_status}     Run Keyword If     '${user_interface}' == 'cli'    Set Variable If    ${length_port_id} > 1      port_down     all_ports_up
    \    ${port_id}    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'    Get From List    ${port_id}    1

    \    Log      ********** Shutting down connected Ethernet interface on Cisco device when all ports are UP in cli ************
    \    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'all_ports_up'     Shutting down the port on Cisco     device=n2_cisco    device_ip=${DEVICES.n2_cisco.ip}     user=${DEVICES.n2_cisco.user}     password=${DEVICES.n2_cisco.password}     enable_pw=${DEVICES.n2_cisco.enable_password}       port=${DEVICES.n2_cisco.ports.p1.port}
    \    Exit For Loop If      '${user_interface}' == 'cli' and '${port_status}' == 'port_down' 

    Log      ********** Shut and unshut interface for Alarm to get triggered in cli ************
    Run Keyword If     '${user_interface}' == 'cli'      cli    ${device}    configure      timeout=50     prompt=\\#     retry=4
    Run Keyword If     '${user_interface}' == 'cli'      cli    ${device}    interface ethernet ${port_id}     timeout=50     prompt=\\#     retry=4
    Run Keyword If     '${user_interface}' == 'cli'     cli    ${device}    shut     timeout=50      prompt=\\#     retry=4
    #Sleep for 5s for Alarms to generate properly after shut
    Run Keyword If     '${user_interface}' == 'cli'       BuiltIn.Sleep    5s 
    Run Keyword If     '${user_interface}' == 'cli'      cli    ${device}    no shut    timeout=50     prompt=\\#     retry=4
    #Sleep for 10s after noshut
    Run Keyword If     '${user_interface}' == 'cli'      BuiltIn.Sleep    10s
    Run Keyword If     '${user_interface}' == 'cli'       cli    ${device}    end    prompt=\\#     timeout=50     retry=4
    Run Keyword If     '${user_interface}' == 'cli'    cli    ${device}    accept running-config     timeout=50
    Run Keyword If     '${user_interface}' == 'cli'    cli    ${device}    copy running-config startup-config      timeout=50       prompt=\\#     retry=4

    Log     ******* Verifying alarm got triggered in cli **********
#    ${result1}    Run Keyword If     '${user_interface}' == 'cli'    cli    ${device}    show alarm active subscope id 1201 | include ${port_id}     timeout=50         retry=4
#    Run Keyword If     '${user_interface}' == 'cli'    Should Contain     ${result1}    name loss-of-signal
#    Run Keyword If     '${user_interface}' == 'cli'    Should Contain     ${result1}    description loss of signal
    #${port_ids}   Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'    Split String    ${port_id}    /
    #${port_id}   Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'    Get From List    ${port_ids}    2
#    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'      Should Contain      ${result1}      ${port_id}']

    Run Keyword If     '${user_interface}' == 'cli'    Wait Until Keyword Succeeds      2 min     10 sec    Send Command And Confirm Expect     ${device}   show alarm active subscope id 1201 name loss-of-signal
      ...     name loss-of-signal(.*\\r\\n){1,}.*description loss of signal(.*\\r\\n){1,}.*${port_id}

    Log     ******* Verifying alarm got triggered in netconf *********
    ${result2}    Run Keyword If     '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1201</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If     '${user_interface}' == 'netconf'    Should Contain      ${result2.xml}       <name>loss-of-signal</name>
    Run Keyword If     '${user_interface}' == 'netconf'    Should Contain      ${result2.xml}       <description>loss of signal</description>
    #${net_port_ids}   Run Keyword If    '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'      Split String    ${net_port_id}   /
    #${net_port_id}    Run Keyword If    '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'      Get From List    ${net_port_ids}    2
    Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'     Should Contain      ${result2.xml}      ${net_port_id}']

    Log     ******* Returning down port id in netconf *******
    Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'     Return From Keyword     ${net_port_id}

    Log     ******* Returning down port id in cli *********
    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'      Return From Keyword     ${port_id}
   
Clearing Loss of Signal MAJOR alarm
    [Arguments]      ${device}=None       ${linux}=None     ${user_interface}=None
    [Documentation]      Clearing Loss of Signal MAJOR alarm
    [Tags]        @author=ssekar

    ${result_netconf}    Run Keyword If     '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<rpc message-id="m-33" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><interfaces-state xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name></name><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><oper-status>down</oper-status></interface></interfaces-state></filter></get></rpc> ]]>]]>
    ${str}       Run Keyword If     '${user_interface}' == 'netconf'      Convert to string    ${result_netconf}
    @{portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Regexp Matches    ${str}      <interface><name>([0-9a-z/]+)</name>     1
    ${length_portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Length     ${portname}
    ${net_port_status}     Run Keyword If     '${user_interface}' == 'netconf'    Set Variable If    ${length_portname} > 0       net_port_down     net_port_up
    ${net_port_id}    Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'    Get From List    ${portname}    0

    ${result}    Run Keyword If     '${user_interface}' == 'cli'     cli    ${device}    show interface ethernet status oper-state | tab | include down    timeout=50
    @{port_id}    Run Keyword If     '${user_interface}' == 'cli'     Get Regexp Matches    ${result}    ([0-9/a-z]+).*    1
    ${length_port_id}   Run Keyword If     '${user_interface}' == 'cli'      Get Length     ${port_id}
    ${port_status}     Run Keyword If     '${user_interface}' == 'cli'    Set Variable If    ${length_port_id} > 1      port_down     all_ports_up
    ${port_id}    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'    Get From List    ${port_id}    1

    Log    ******* Enabling the Cisco Shutdown port to clear the alarm *********
# common operation for cisoco
#    Run Keyword If     '${user_interface}' == 'cli' or '${user_interface}' == 'netconf'    Enabling the Cisco shutdown port      device=n2_cisco    device_ip=${DEVICES.n2_cisco.ip}     user=${DEVICES.n2_cisco.user}     password=${DEVICES.n2_cisco.password}     enable_pw=${DEVICES.n2_cisco.enable_password}       port=${DEVICES.n2_cisco.ports.p1.port}
    #Sleep for 5s
    Sleep     5s

    ${result_netconf}    Run Keyword If     '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<rpc message-id="m-33" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><interfaces-state xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name></name><type xmlns:eth-std="http://www.calix.com/ns/ethernet-std">eth-std:ethernetCsmacd</type><oper-status>down</oper-status></interface></interfaces-state></filter></get></rpc> ]]>]]>
    ${str}       Run Keyword If     '${user_interface}' == 'netconf'      Convert to string    ${result_netconf}
    @{portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Regexp Matches    ${str}      <interface><name>([0-9a-z/]+)</name>     1
    ${length_portname}    Run Keyword If     '${user_interface}' == 'netconf'    Get Length     ${portname}
    ${net_port_status}     Run Keyword If     '${user_interface}' == 'netconf'    Set Variable If    ${length_portname} > 0       net_port_down1     net_port_up
    ${net_port_id1}    Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'    Get From List    ${portname}    0

    ${result}    Run Keyword If     '${user_interface}' == 'cli'     cli    ${device}    show interface ethernet status oper-state | tab | include down    timeout=50
    @{port_id}    Run Keyword If     '${user_interface}' == 'cli'     Get Regexp Matches    ${result}    ([0-9/a-z]+).*    1
    ${length_port_id}   Run Keyword If     '${user_interface}' == 'cli'      Get Length     ${port_id}
    ${port_status}     Run Keyword If     '${user_interface}' == 'cli'    Set Variable If    ${length_port_id} > 1      port_down1     all_ports_up
    ${port_id1}    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down1'    Get From List    ${port_id}    1


    Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down1'     Run Keywords     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${net_port_id}</name><enabled>true</enabled></interface></interfaces></config></edit-config></rpc>]]>]]>
    ...      AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${net_port_id}</name><enabled>false</enabled></interface></interfaces></config></edit-config></rpc>]]>]]>
    #Sleep for 7s after shut
    ...      AND     BuiltIn.Sleep    7s
    ...      AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    ...      AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>

 
    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down1'     Run Keywords     cli    ${device}    configure    timeout=50    prompt=\\#
    ...       AND     cli    ${device}    interface ethernet ${port_id1}     timeout=50     prompt=\\#     retry=4
    ...       AND     cli    ${device}    no shut    timeout=50      prompt=\\#     retry=4
    #Sleep for 5s after enabling it
    ...       AND     BuiltIn.Sleep    5s
    ...       AND     cli    ${device}    shut     timeout=50      prompt=\\#     retry=4
    #Sleep for 5s after shut
    ...       AND     BuiltIn.Sleep    5s  
    ...       AND     cli    ${device}    end      prompt=\\#     timeout=50      prompt=\\#     retry=4
    ...       AND     cli    ${device}    accept running-config     timeout=50    prompt=\\#     retry=4
    ...       AND     cli    ${device}    copy running-config startup-config     timeout=50     prompt=\\#     retry=4
    

    ${port_ids}   Run Keyword If    '${user_interface}' == 'cli' and '${port_status}' == 'port_down'    Split String    ${port_id}    /
    ${port_id}   Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'    Get From List    ${port_ids}    2
    ${result}    Run Keyword If     '${user_interface}' == 'cli'    cli    ${device}    show alarm active subscope id 1201     timeout=50         retry=4
    Run Keyword If     '${user_interface}' == 'cli' and '${port_status}' == 'port_down'      Should Not Contain      ${result}      ${port_id}']

    ${result2}    Run Keyword If     '${user_interface}' == 'netconf'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1201</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    ${port_ids}   Run Keyword If    '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'      Split String    ${net_port_id}   /
    ${port_id}    Run Keyword If    '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'      Get From List    ${port_ids}    2
    Run Keyword If     '${user_interface}' == 'netconf' and '${net_port_status}' == 'net_port_down'     Should Not Contain      ${result2.xml}      ${port_id}']

Trigerring NTP prov alarm netconf
    [Arguments]    ${device}
    [Documentation]    Trigerring NTP prov alarm 
    [Tags]        @author=ssekar

    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address>255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s to trigger the alarm
    BuiltIn.Sleep    3s
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete">255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete">255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s to trigger the alarm
    BuiltIn.Sleep    3s
    ${result}       Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1919</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}      <name>ntp-prov</name>
    ${str}=    Convert to string    ${result}
    ${instanceid}=    Get Lines Containing String    ${str}    instance-id
    @{first}=    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0

    Log    *** Verifying NTP prov alarm is maintained in Historical alarms ***
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}       <name>ntp-prov</name>
    Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Should Contain      ${result.xml}       <perceived-severity>MAJOR</perceived-severity>
    [Return]    ${instance_id}

Trigerring NTPD down alarm
    [Arguments]    ${device}      ${local_pc_ip}
    [Documentation]    Trigerring NTPD down alarm
    [Tags]        @author=ssekar

    cli     ${device}     configure       timeout=50
    cli     ${device}     ntp server 1 ${local_pc_ip}      timeout=90
    cli     ${device}     ntp server 2 ${local_pc_ip}      timeout=90
    cli     ${device}     ntp server 1 invalid       timeout=90
    cli     ${device}     ntp server 2 invalid       timeout=90
    cli     ${device}     end
    ${result}      cli     ${device}     show alarm active subscope name ntpd-down
    Should Contain      ${result}      description NTP daemon is not running 
    @{first}=    Get Regexp Matches    ${result}    instance-id ([0-9.]+)     1
    ${instance_id}    Get From List    ${first}    0

    Log    *** Verifying NTPD alarm is maintained in Historical alarms ***
    ${result}    cli     ${device}     show alarm history subscope instance-id ${instance_id}
    Should Contain      ${result}      name ntpd-down
    [Return]    ${instance_id}

Clearing NTPD down alarm 
    [Arguments]    ${device}      ${instance_id}
    [Documentation]   Clearing NTPD down alarm
    [Tags]        @author=ssekar

    cli     ${device}     configure       timeout=50
    cli     ${device}     no ntp server 1      timeout=90
    cli     ${device}     no ntp server 2      timeout=90
    cli     ${device}     end
    ${result}      cli     ${device}     show alarm history subscope instance-id ${instance_id}
    Should Contain      ${result}      name ntpd-down
    Should Contain      ${result}      perceived-severity CLEAR
    ${clear_time}      Get Lines Containing String     ${result}     ne-event-time
    @{clear_time}      Get Regexp Matches    ${clear_time}     ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    [Return]     ${clear_time}
    
Trigerring NTPD down alarm netconf
    [Arguments]    ${device}      ${local_pc_ip}
    [Documentation]    Trigerring NTPD down alarm
    [Tags]        @author=ssekar

    ${result}   Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>${local_pc_ip}</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Should Contain      ${result.xml}       <ok/>
    # Sleep for 7s to trigger the alarm
    BuiltIn.Sleep    7s
    ${result}     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address>${local_pc_ip}</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Should Contain      ${result.xml}       <ok/>
    # Sleep for 7s to trigger the alarm
    BuiltIn.Sleep    7s
    ${result}     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>invalid</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Should Contain      ${result.xml}       <ok/>
    # Sleep for 7s
    BuiltIn.Sleep    7s
    ${result}         Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address>invalid</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Should Contain      ${result.xml}       <ok/>
    # Sleep for 7s to trigger the alarm
    BuiltIn.Sleep    7s
    ${result1}       Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>ntpd-down</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    Should Contain      ${result1.xml}       <name>ntpd-down</name> 
    ${str}=    Convert to string    ${result1}
    ${instanceid}=    Get Lines Containing String    ${str}    instance-id
    @{first}=    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0

    Log    *** Verifying NTPD alarm is maintained in Historical alarms ***
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}       <name>ntpd-down</name>
    Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Should Contain      ${result.xml}       <perceived-severity>MAJOR</perceived-severity>
    [Return]    ${instance_id}

Clearing NTPD down alarm netconf
    [Arguments]    ${device}      ${instance_id}
    [Documentation]   Clearing NTPD down alarm 
    [Tags]        @author=ssekar

    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete">invalid</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Should Contain      ${result.xml}       <ok/>
    # Sleep for 7s
    BuiltIn.Sleep    7s

    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete">invalid</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s to clear the alarm
    BuiltIn.Sleep    3s

    ${result}    Run Keyword If     '${instance_id}' != 'None'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <name>ntpd-down</name>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <perceived-severity>CLEAR</perceived-severity>

    ${result}    Run Keyword If     '${instance_id}' != 'None'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If     '${instance_id}' != 'None'     Should Not Contain      ${result.xml}        <instance-id>${instance_id}</instance-id>

Trigerring NTP prov alarm 
    [Arguments]    ${device}
    [Documentation]    Trigerring NTP prov alarm
    [Tags]        @author=ssekar

    cli    ${device}      configure     timeout=50        prompt=\\#     retry=4
    cli    ${device}      ntp server 1 255.255.255.254     timeout=90      prompt=\\#     retry=4
    cli    ${device}      ntp server 2 255.255.255.254     timeout=90      prompt=\\#     retry=4
    cli    ${device}      end      timeout=90         prompt=\\#     retry=4
    ${result}      cli    ${device}       show alarm active subscope id 1919     timeout=50           retry=4
    Should Not Contain      ${result}      name ntp-prov
    cli    ${device}      configure     timeout=50      prompt=\\#     retry=4
    cli    ${device}       no ntp server 1 255.255.255.254     timeout=50      prompt=\\#     retry=4
    cli    ${device}       no ntp server 2 255.255.255.254     timeout=50      prompt=\\#     retry=4
    cli    ${device}       end     timeout=50       prompt=\\#     retry=4
    ${result}      cli    ${device}       show alarm active subscope id 1919     timeout=50          retry=4
    Should Contain      ${result}      name ntp-prov
    @{result1}    Get Regexp Matches    ${result}    instance-id ([0-9.]+)    1
    ${instance-id}    Get From List    ${result1}    0
    ${result}      cli    ${device}       show alarm history subscope instance-id ${instance-id}     timeout=60         retry=4
    Should Contain      ${result}        instance-id ${instance-id}
    Should Contain      ${result}        perceived-severity MAJOR
    [Return]     ${instance-id}

Clearing NTP prov alarm
    [Arguments]    ${device}     ${instance-id}=None
    [Documentation]    Clearing NTP prov alarm
    [Tags]        @author=ssekar

    cli    ${device}      configure      timeout=50      prompt=\\#     retry=4
    cli    ${device}      ntp server 1 invalid         timeout=50     prompt=\\#     retry=4
    cli    ${device}      ntp server 2 invalid         timeout=50    prompt=\\#     retry=4
    cli    ${device}      end      timeout=90     prompt=\\#     retry=4
    ${result}      cli    ${device}       show alarm active subscope id 1919     timeout=50         retry=4
    Should Not Contain      ${result}      name ntp-prov 
    ${result}    Run Keyword If     '${instance-id}' != 'None'      cli    ${device}     show alarm history subscope instance-id ${instance-id}      timeout=60
    ...            retry=4
    Run Keyword If     '${instance-id}' != 'None'     Should Contain      ${result}      name ntp-prov
    Run Keyword If     '${instance-id}' != 'None'     Should Contain      ${result}      perceived-severity CLEAR
    Run Keyword If     '${instance-id}' != 'None'     Should Contain      ${result}      instance-id ${instance-id}

Clearing NTP prov alarm netconf
    [Arguments]    ${device}     ${instance_id}=None
    [Documentation]    Clearing NTP prov alarm 
    [Tags]        @author=ssekar

    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>invalid</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address>invalid</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s to clear the alarm
    BuiltIn.Sleep    3s

    ${result}    Run Keyword If     '${instance_id}' != 'None'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <name>ntp-prov</name>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <perceived-severity>CLEAR</perceived-severity>

    ${result}    Run Keyword If     '${instance_id}' != 'None'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If     '${instance_id}' != 'None'     Should Not Contain      ${result.xml}        <instance-id>${instance_id}</instance-id>
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1919</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Should Not Contain      ${result.xml}       <name>ntp-prov</name>

Trigerring NTP server reachability alarm netconf
    [Arguments]    ${device}      ${local_pc_ip}
    [Documentation]    Trigerring NTP server reachability alarm
    [Tags]        @author=ssekar

    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>${local_pc_ip}</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 7s after configuring valid NTP server 1 IP
    BuiltIn.Sleep    7s
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address>${local_pc_ip}</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s after configuring valid NTP server 2 IP 
    BuiltIn.Sleep    3s
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s to trigger the alarm
    BuiltIn.Sleep    3s
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address>255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s to trigger the alarm
    BuiltIn.Sleep    3s
    ${result}       Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1918</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}      <name>ntp-server-reachability</name>
 
    ${str}=    Convert to string    ${result}
    ${instanceid}=    Get Lines Containing String    ${str}    instance-id
    @{first}=    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0
    Log    *** Verifying NTP server reachability alarm is maintained in Historical alarms ***
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}       <name>ntp-server-reachability</name>
    Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Should Contain      ${result.xml}       <perceived-severity>MAJOR</perceived-severity>
    [Return]    ${instance_id}

Clearing NTP server reachability alarm netconf
    [Arguments]    ${device}     ${instance_id}=None
    [Documentation]    Clearing NTP server reachability alarm
    [Tags]        @author=ssekar

    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete">255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>2</id><address xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete">255.255.255.254</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 3s to clear the alarm
    BuiltIn.Sleep    3s

    ${result}    Run Keyword If     '${instance_id}' != 'None'    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <name>ntp-server-reachability</name>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Run Keyword If     '${instance_id}' != 'None'     Should Contain      ${result.xml}       <perceived-severity>CLEAR</perceived-severity>

    ${result}    Run Keyword If     '${instance_id}' != 'None'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If     '${instance_id}' != 'None'     Should Not Contain      ${result.xml}        <instance-id>${instance_id}</instance-id>


Triggering any one alarm for severity INFO
    [Arguments]    ${device}=None     ${linux}=None     ${user_interface}=None
    [Documentation]    Triggering any one alarm for severity INFO
    [Tags]        @author=ssekar

    Run Keyword If     '${user_interface}' == 'cli'     Run Keywords     cli    ${device}    configure    timeout=50
    ...       AND     cli    ${device}    no contact    timeout=50
    ...       AND     cli    ${device}    end     timeout=50
    ...       AND     cli    ${device}    accept running-config     timeout=50
    ...       AND     cli    ${device}    copy running-config startup-config     timeout=50
    ...       AND     cli    ${device}    configure     timeout=50
    ...       AND     cli    ${device}    contact Ero     timeout=50
    ...       AND     cli    ${device}    end    prompt=\\#      timeout=50

    Run Keyword If     '${user_interface}' == 'netconf'    Run Keywords    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact></contact></system></config></config></edit-config></rpc>]]>]]>
    ...       AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    ...       AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
    ...       AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact>Ero1</contact></system></config></config></edit-config></rpc>]]>]]>
    # Sleep for 2 secs for Alarm to get trigerred in  Active table
    BuiltIn.Sleep    2s
    ${result}    Run Keyword If    '${user_interface}' == 'cli'    cli    ${device}    show alarm active subscope id 702     timeout=50
    Run Keyword If    '${user_interface}' == 'cli'     Should Contain    ${result}    name running-config-unsaved
    @{result1}    Run Keyword If    '${user_interface}' == 'cli'     Get Regexp Matches    ${result}    instance-id ([0-9.]+)    1
    ${instance-id}    Run Keyword If    '${user_interface}' == 'cli'     Get From List    ${result1}    0

    ${result}    Run Keyword If    '${user_interface}' == 'netconf'    Netconf Raw    ${device}     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>702</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'    Should contain    ${result.xml}     702 
    ${str}=    Run Keyword If    '${user_interface}' == 'netconf'    Convert to string    ${result}
    ${instanceid}=    Run Keyword If    '${user_interface}' == 'netconf'    Get Lines Containing String    ${str}    instance-id
    @{first}=    Run Keyword If    '${user_interface}' == 'netconf'    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Run Keyword If    '${user_interface}' == 'netconf'    Get From List    ${first}    0

    Run Keyword If    '${user_interface}' == 'cli'    Return From Keyword     ${instance-id}    
    ...   ELSE IF     '${user_interface}' == 'netconf'      Return From Keyword     ${instance_id}

Clear running-config INFO alarm
    [Arguments]    ${device}=None     ${linux}=None     ${user_interface}=None     ${instance-id}=None
    [Documentation]    Clearing running-config INFO alarm
    [Tags]        @author=ssekar

    Run Keyword If     '${user_interface}' == 'cli'     Run Keywords     cli    ${device}    configure     timeout=50
    ...       AND     cli    ${device}    no contact     timeout=50
    ...       AND     cli    ${device}    end    prompt=\\#      timeout=50
    ...       AND     cli    ${device}    accept running-config      timeout=50
    ...       AND     cli    ${device}    copy running-config startup-config     timeout=50

    Run Keyword If     '${user_interface}' == 'netconf'    Run Keywords    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact></contact></system></config></config></edit-config></rpc>]]>]]>
    ...       AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    ...       AND     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>

    # Sleep for 5 secs for Alarm to get cleared from Active table
    BuiltIn.Sleep    5

    ${result}    Run Keyword If    '${user_interface}' == 'cli'      cli    ${device}    show alarm active subscope id 702     timeout=50
    Run Keyword If    '${user_interface}' == 'cli' and '${instance-id}' == 'None'    Should Not Contain    ${result}    name running-config-unsaved
    Run Keyword If    '${user_interface}' == 'cli' and '${instance-id}' != 'None'     Should Not Contain      ${result}     instance-id ${instance-id}

    ${result}    Run Keyword If    '${user_interface}' == 'netconf'     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>702</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf' and '${instance-id}' == 'None'     Should Not Contain     ${result.xml}     <name>running-config-unsaved</name>
    Run Keyword If    '${user_interface}' == 'netconf' and '${instance-id}' != 'None'     Should Not Contain     ${result.xml}    <instance-id>${instance-id}</instance-id>

Historical_alarm_interface_down
    [Arguments]    ${device}    ${linux}
    [Documentation]    Verifying Loss of signal alarm is maintained in Active and Historical alarm, and checking History maintains CLEARED as well as Active alarms
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec        Triggering Loss of Signal MAJOR alarm        device=${device}     linux=${linux}     user_interface=cli
    ${result}    cli     ${device}        show alarm active subscope id 1201       timeout=60
    Should Contain      ${result}        name loss-of-signal

    @{result1}    Get Regexp Matches    ${result}    instance-id ([0-9.]+)    1
    ${instance-id}    Get From List    ${result1}    0

    Log    *** Verifying triggered loss of signal alarm is maintained in Historical alarms ***
    ${result}    cli     ${device}        show alarm history subscope instance-id ${instance-id}       timeout=60
    Should Contain      ${result}        name loss-of-signal
    Should Contain      ${result}        instance-id ${instance-id}
    Should Contain      ${result}        perceived-severity MAJOR
  
    Wait Until Keyword Succeeds      2 min     10 sec        Clearing Loss of Signal MAJOR alarm        device=${device}        linux=${linux}      user_interface=cli

    Log    *** Verifying cleared loss of signal alarm is maintained only in Historical alarms ***
    ${result}    cli    ${device}     show alarm history subscope instance-id ${instance-id}       timeout=60
    Should Contain      ${result}        name loss-of-signal
    Should Contain      ${result}        instance-id ${instance-id}
    Should Contain      ${result}        perceived-severity CLEAR

    ${result}    cli     ${device}        show alarm active subscope id 1201       timeout=60
    Should Not Contain      ${result}        instance-id ${instance-id}

Historical_alarm_interface_down_netconf
    [Arguments]    ${device}      ${linux} 
    [Documentation]    Verifying Loss of signal alarm is maintained in Active and Historical alarm, and checking History maintains CLEARED as well as Active alarms
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec        Triggering Loss of Signal MAJOR alarm        device=${device}        linux=${linux}      user_interface=netconf
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1201</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}       <name>loss-of-signal</name>

    ${str}=    Convert to string    ${result}
    ${instanceid}=    Get Lines Containing String    ${str}    instance-id
    @{first}=    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0
    
    Log    *** Verifying triggered loss of signal alarm is maintained in Historical alarms ***
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}       <name>loss-of-signal</name>
    Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Should Contain      ${result.xml}       <perceived-severity>MAJOR</perceived-severity>

    Wait Until Keyword Succeeds      2 min     10 sec        Clearing Loss of Signal MAJOR alarm        device=${device}         linux=${linux}       user_interface=netconf

    Log    *** Verifying cleared loss of signal alarm is maintained only in Historical alarms ***
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    Should Contain      ${result.xml}       <name>loss-of-signal</name>
    Should Contain      ${result.xml}       <instance-id>${instance_id}</instance-id>
    Should Contain      ${result.xml}       <perceived-severity>CLEAR</perceived-severity>
        
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Should Not Contain      ${result.xml}        <instance-id>${instance_id}</instance-id>

Increasing_Alarm_history_count_and_history_filter_netconf
    [Arguments]    ${device}      ${linux}
    [Documentation]    Increasing the alarm history count to minimum 100
    [Tags]        @author=ssekar

    Run Keyword     Historical_alarm_interface_down_netconf      ${device}       ${linux}
    Run Keyword     Triggering CRITICAL alarm     linux=${linux}     device=${device}      user_interface=netconf
    Run Keyword     Clearing CRITICAL alarm     linux=${linux}     device=${device}      user_interface=netconf

    : FOR    ${INDEX}    IN RANGE    1    17
    \      Log    ${INDEX}
    \      ${run_instance_id}    Wait Until Keyword Succeeds      2 min     10 sec        Triggering any one alarm for severity INFO     device=${device}     user_interface=netconf
    \      Wait Until Keyword Succeeds      2 min     10 sec        Clear running-config INFO alarm     device=${device}     user_interface=netconf     instance-id=${run_instance_id}
    \      ${instance_id}      Wait Until Keyword Succeeds      2 min     10 sec        Trigerring NTP prov alarm netconf      ${device}
    \      Wait Until Keyword Succeeds      2 min     10 sec        Clearing NTP prov alarm netconf      ${device}     ${instance_id}
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/history"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    @{total_count}     Get Regexp Matches    ${str}    <total-count>([0-9]+)</total-count>     1
    ${total_count}     Get From List    ${total_count}     0
    ${result}      Evaluate    ($total_count >= 100)
    Should Be Equal     '${result}'     'True' 

    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><id>1201</id></show-alarm-instances-history-filter></rpc>]]>]]>
    Should Contain      ${result.xml}       <name>loss-of-signal</name>
    Should Contain      ${result.xml}       <perceived-severity>CLEAR</perceived-severity>
    Should Contain      ${result.xml}       <perceived-severity>MAJOR</perceived-severity>

Increasing_Alarm_history_count_and_history_filter
    [Arguments]    ${device}        ${linux}
    [Documentation]    Increasing the alarm history count to minimum 100
    [Tags]        @author=ssekar

    Run Keyword      Historical_alarm_interface_down       ${device}       ${linux}
    Run Keyword      Triggering CRITICAL alarm     linux=${linux}     device=${device}      user_interface=cli
    Run Keyword      Clearing CRITICAL alarm     linux=${linux}     device=${device}      user_interface=cli

    : FOR    ${INDEX}    IN RANGE    1    17
    \      Log    ${INDEX}
    \      ${run_instance_id}    Wait Until Keyword Succeeds      2 min     10 sec        Triggering any one alarm for severity INFO     device=${device}     user_interface=cli
    \      Wait Until Keyword Succeeds      2 min     10 sec        Clear running-config INFO alarm     device=${device}     user_interface=cli    instance-id=${run_instance_id}
    \      ${instance_id}     Wait Until Keyword Succeeds      2 min     10 sec        Trigerring NTP prov alarm      ${device}
    \      Wait Until Keyword Succeeds      2 min     10 sec        Clearing NTP prov alarm        ${device}     ${instance_id}

    ${total_count}     Getting Alarm history total count    ${device}
    ${result}      Evaluate    ($total_count >= 100)
    Should Be Equal     '${result}'     'True'

    ${result}    cli     ${device}        show alarm history filter id 1201      timeout=60
    Should Contain      ${result}       name loss-of-signal
    Should Contain      ${result}       perceived-severity CLEAR
    Should Contain      ${result}       perceived-severity MAJOR    

Verify Alarm filtered by severity
    [Arguments]    ${device}     ${alarm_type}=None     ${perceived_security}=None
    [Documentation]    Alarms filtered by severity
    [Tags]        @author=ssekar

    ${result}   Run Keyword If   '${alarm_type}' == 'active'    cli    ${device}    show alarm active subscope perceived-severity ${perceived_security}      timeout=50
    ...     ELSE IF     '${alarm_type}' == 'definition'    cli    ${device}    show alarm definitions subscope perceived-severity ${perceived_security}     timeout=50
    ...     ELSE IF     '${alarm_type}' == 'history'     cli    ${device}    show alarm history subscope perceived-severity ${perceived_security}       timeout=50
    ...     ELSE IF     '${alarm_type}' == 'archive'     cli    ${device}    show alarm archive subscope perceived-severity ${perceived_security}      timeout=90
    ...     ELSE IF     '${alarm_type}' == 'suppress'    cli    ${device}     show alarm suppressed subscope perceived-severity ${perceived_security}     timeout=90

    Log    Checking CRITICAL alarms
    Run Keyword If   '${perceived_security}' == 'CRITICAL'    Run Keywords     Result Should Not Contain    perceived-severity MINOR
    ...    AND     Result Should Not Contain    perceived-severity MAJOR
    ...    AND     Result Should Not Contain    perceived-severity CLEAR
    ...    AND     Result Should Not Contain    perceived-severity INFO
    ...    AND     Result Should Not Contain    perceived-severity WARNING
    ...    AND     Result Should Not Contain    perceived-severity INDETERMINATE

    Log    Checking MAJOR alarms
    Run Keyword If   '${perceived_security}' == 'MAJOR'    Run Keywords     Result Should Not Contain    perceived-severity MINOR
    ...    AND     Result Should Not Contain    perceived-severity CLEAR
    ...    AND     Result Should Not Contain    perceived-severity INFO
    ...    AND     Result Should Not Contain    perceived-severity WARNING
    ...    AND     Result Should Not Contain    perceived-severity INDETERMINATE

    Log    Checking MINOR alarms
    Run Keyword If   '${perceived_security}' == 'MINOR'   Run Keywords      Result Should Not Contain    perceived-severity CLEAR
    ...    AND     Result Should Not Contain    perceived-severity INFO
    ...    AND     Result Should Not Contain    perceived-severity WARNING
    ...    AND     Result Should Not Contain    perceived-severity INDETERMINATE

    Log    Checking WARNING alarms
    Run Keyword If   '${perceived_security}' == 'WARNING'     Run Keywords      Result Should Not Contain    perceived-severity CLEAR
    ...    AND     Result Should Not Contain    perceived-severity INFO
    ...    AND     Result Should Not Contain    perceived-severity INDETERMINATE

    Log    Checking CLEAR alarms
    Run Keyword If   '${perceived_security}' == 'CLEAR'     Result Should Not Contain    perceived-severity INDETERMINATE

    Log    Checking INFO alarms
    Run Keyword If   '${perceived_security}' == 'INFO'     Result Should Not Contain    perceived-severity INDETERMINATE

Verify Alarm filtered by severity using netconf
    [Arguments]    ${device}       ${alarm_type}=None     ${perceived_security}=None
    [Documentation]    Alarms filtered by severity using netconf
    [Tags]        @author=ssekar
    ${result}   Run Keyword If   '${alarm_type}' == 'active'     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><perceived-severity>${perceived_security}</perceived-severity></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...     ELSE IF    '${alarm_type}' == 'definition'     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><perceived-severity>${perceived_security}</perceived-severity></show-alarm-definitions-subscope></rpc>]]>]]>
    ...     ELSE IF    '${alarm_type}' == 'history'     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><perceived-severity>${perceived_security}</perceived-severity></show-alarm-instances-history-subscope></rpc>]]>]]>
    ...     ELSE IF    '${alarm_type}' == 'suppress'     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-suppressed-subscope xmlns="http://www.calix.com/ns/exa/base"><perceived-severity>${perceived_security}</perceived-severity></show-alarm-instances-suppressed-subscope></rpc>]]>]]>
    ...     ELSE IF    '${alarm_type}' == 'archive'     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-subscope xmlns="http://www.calix.com/ns/exa/base"><perceived-severity>${perceived_security}</perceived-severity></show-alarm-instances-archive-subscope></rpc>]]>]]>
    

    Run Keyword If   '${perceived_security}' == 'MINOR'     Run Keywords     Should Not Contain     ${result.xml}      <perceived-severity>CLEAR</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INFO</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>WARNING</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INDETERMINATE</perceived-severity>
    Run Keyword If   '${perceived_security}' == 'MAJOR'     Run Keywords     Should Not Contain     ${result.xml}      <perceived-severity>CLEAR</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INFO</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>WARNING</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INDETERMINATE</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>MINOR</perceived-severity>
    ...       AND     Should Contain     ${result.xml}      <perceived-severity>MAJOR</perceived-severity>
    Run Keyword If   '${perceived_security}' == 'CRITICAL'    Run Keywords     Should Not Contain     ${result.xml}      <perceived-severity>CLEAR</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INFO</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>WARNING</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INDETERMINATE</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>MINOR</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>MAJOR</perceived-severity>
    Run Keyword If   '${perceived_security}' == 'WARNING'    Run Keywords     Should Not Contain     ${result.xml}      <perceived-severity>CLEAR</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INFO</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}      <perceived-severity>INDETERMINATE</perceived-severity>
    ...       AND     Should Contain     ${result.xml}      <perceived-severity>MAJOR</perceived-severity>
    Run Keyword If   '${perceived_security}' == 'CLEAR'     Run Keywords    Should Contain    ${result.xml}     <perceived-severity>MAJOR</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}       <perceived-severity>INDETERMINATE</perceived-severity>
    Run Keyword If   '${perceived_security}' == 'INFO'    Run Keywords     Should Contain    ${result.xml}     <perceived-severity>MAJOR</perceived-severity>
    ...       AND     Should Contain     ${result.xml}      <perceived-severity>INFO</perceived-severity>
    ...       AND     Should Not Contain     ${result.xml}       <perceived-severity>INDETERMINATE</perceived-severity>

Configure SYSLOG server on DUT
    [Arguments]    ${device}    ${syslog_server_ip}      ${log_level}=DEBUG
    [Documentation]        Configure SYSLOG server
    [Tags]        @author=ssekar
    ${result}     cli    ${device}      show running-config logging host | include logging | linnum     timeout=50
    @{result1}    Get Regexp Matches    ${result}    logging host ([0-9.]+)    1
    ${line1}    Get Lines Containing String    ${result}    logging host
    ${count1}    Get Line Count    ${line1}
    ${count1}=    Evaluate    ${count1}-1
    ${syslog_ip_removed}    Run Keyword If    ${count1} >= 3    Get From List    ${result1}    0
    Run Keyword If    ${count1} >= 3    Run Keywords    cli   ${device}    configure     timeout=50
    ...    AND     cli    ${device}    no logging host ${syslog_ip_removed}     timeout=50
    ...    AND     cli    ${device}    end      timeout=50
    ...    AND     cli    ${device}    copy run start     timeout=50
    cli    ${device}      configure       timeout=90
    cli    ${device}      logging host ${syslog_server_ip} admin-state ENABLED      timeout=90
    cli    ${device}      log-level ${log_level}      timeout=90
    cli    ${device}      port 514       timeout=90
    cli    ${device}      transport UDP      timeout=90
    cli    ${device}      end      timeout=90
    cli    ${device}    copy run start       timeout=90
    ${result}     cli    ${device}      show running-config logging host ${syslog_server_ip}      timeout=90
    Result Should Contain       logging host ${syslog_server_ip}

Configure SYSLOG server on DUT using netconf
    [Arguments]    ${device}    ${syslog_server_ip}
    [Documentation]        Configure SYSLOG server
    [Tags]        @author=ssekar
    ${result}     Netconf Raw     ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/logging/host"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    @{hosts}    Get Regexp Matches    ${str}     <name>([0-9.]+)</name>     1
    ${length}   Get Length    ${hosts}
    ${host}    Run Keyword If    ${length} >= 3      Get From List   ${hosts}    0
    ${result}    Run Keyword If    ${length} >= 3      Netconf Raw     ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><logging><host xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete"><name>${host}</name></host></logging></system></config></config></edit-config></rpc>]]>]]>
    Run Keyword If    ${length} >= 3           Should Contain     ${result.xml}       <ok/>
    ${result}    Netconf Raw     ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><logging><host><name>${syslog_server_ip}</name><transport>UDP</transport><port>514</port><log-level>DEBUG</log-level></host></logging></system></config></config></edit-config></rpc>]]>]]>
    Should Contain     ${result.xml}       <ok/>

Configuring_SNMPv3_on_DUT
    [Arguments]    ${device}    ${snmp_manager_ip}
    [Documentation]        Configure SNMP
    [Tags]        @author=ssekar
    cli    ${device}      configure      timeout=90
    cli    ${device}      snmp v3 admin-state enable      timeout=90
    cli    ${device}      v3 user griffins      timeout=90
    cli    ${device}      authentication protocol MD5 key string67890      timeout=90
    cli    ${device}      privacy protocol DES key string67890      timeout=90
    cli    ${device}      exit             timeout=90
    cli    ${device}      v3 trap-host ${snmp_manager_ip} griffins      timeout=90
    cli    ${device}      security-level authPriv trap-type trap        timeout=90
    cli    ${device}      end          timeout=90
    ${result}     cli    ${device}      show running-config snmp v3     timeout=90
    Result Should Contain       v3 admin-state enable
    Result Should Contain       v3 trap-host ${snmp_manager_ip} griffins

Unconfiguring_SNMPv3_on_DUT
    [Arguments]    ${device}    ${snmp_manager_ip}
    [Documentation]        Configure SNMP
    [Tags]        @author=ssekar
    cli    ${device}      configure      timeout=90
    cli    ${device}      snmp v3 admin-state enable     timeout=90
    cli    ${device}      no v3 trap-host ${snmp_manager_ip} griffins
    cli    ${device}      no v3 user griffins
    cli    ${device}      end          timeout=90      
    ${result}     cli    ${device}      show running-config snmp v3     timeout=90
    Result Should Not Contain       v3 trap-host ${snmp_manager_ip} griffins 

Configuring_SNMP_on_DUT
    [Arguments]    ${device}    ${snmp_manager_ip}
    [Documentation]        Configure SNMP 
    [Tags]        @author=ssekar
    ${result}    cli    ${device}      show running-config snmp v2 community    timeout=90
    ${result}    Get Lines Containing String    ${result}    v2 community
    @{com}    Get Regexp Matches     ${result}      v2 community (.*) ro       1
    ${len}    Get Length     ${com}
    ${community}    Run Keyword If     ${len} >= 7      Get From List     ${com}   3 
    Run Keyword If     ${len} >= 7      Run Keywords      cli    ${device}      configure      timeout=90
    ...   AND      cli    ${device}      snmp v2 admin-state enable     timeout=90
    ...   AND      cli    ${device}      no v2 community ${community} ro     timeout=90
    ...   AND      cli    ${device}      end      timeout=90 
    
    cli    ${device}      configure      timeout=90
    cli    ${device}      snmp v2 admin-state enable     timeout=90
    cli    ${device}      v2 community nms ro     timeout=90
    cli    ${device}      v2 trap-host ${snmp_manager_ip} nms    timeout=90
    cli    ${device}      trap-type trap     timeout=90
    cli    ${device}      end      timeout=90
    ${result}     cli    ${device}      show running-config snmp v2    timeout=90
    Result Should Contain       v2 admin-state enable
    Result Should Contain       v2 community nms ro
    Result Should Contain       v2 trap-host ${snmp_manager_ip} nms

Configuring_SNMP_on_DUT_using_netconf
    [Arguments]    ${device}    ${snmp_manager_ip}
    [Documentation]        Configure SNMP
    [Tags]        @author=ssekar
    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><snmp><v2><admin-state>enable</admin-state><community><community-string>nms</community-string><access>ro</access></community><trap-host><host>${snmp_manager_ip}</host><community>nms</community></trap-host></v2></snmp></system></config></config></edit-config></rpc>]]>]]>
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="m-10"><get-config><source><running></running></source><ns0:filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><config xmlns="http://www.calix.com/ns/exa/base"><system><snmp><v2></v2></snmp></system></config></ns0:filter></get-config></rpc>]]>]]>
    Should Contain      ${result.xml}      <community-string>nms</community-string>
    Should Contain      ${result.xml}      <host>${snmp_manager_ip}</host>

Configuring_SNMPv3_on_DUT_using_netconf
    [Arguments]    ${device}    ${snmp_manager_ip}
    [Documentation]        Configure SNMP
    [Tags]        @author=ssekar
    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><snmp><v3><admin-state>enable</admin-state><user><name>griffins</name><authentication><protocol>MD5</protocol><key>string123</key></authentication><privacy><protocol>DES</protocol><key>string123</key></privacy></user><user><name>griffins</name></user><trap-host><host>${snmp_manager_ip}</host><user>griffins</user></trap-host></v3></snmp></system></config></config></edit-config></rpc>]]>]]>
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="m-10"><get-config><source><running></running></source><ns0:filter xmlns:ns0="urn:ietf:params:xml:ns:netconf:base:1.0" ns0:type="subtree"><config xmlns="http://www.calix.com/ns/exa/base"><system><snmp><v3></v3></snmp></system></config></ns0:filter></get-config></rpc>]]>]]>
    Should Contain      ${result.xml}      <host>${snmp_manager_ip}</host><user>griffins</user>

Unconfiguring_SNMP_on_DUT
    [Arguments]    ${device}    ${snmp_manager_ip}
    [Documentation]        Configure SNMP
    [Tags]        @author=ssekar
    cli    ${device}      configure     timeout=90
    cli    ${device}      snmp v2 admin-state enable     timeout=90
    cli    ${device}      no v2 trap-host ${snmp_manager_ip} nms    timeout=90
    cli    ${device}      no v2 community nms ro     timeout=90
    cli    ${device}      end    timeout=90
    ${result}     cli    ${device}      show running-config snmp v2    timeout=90
    Result Should Not Contain       v2 community nms ro
    Result Should Not Contain       v2 trap-host ${snmp_manager_ip} nms

SNMP_start_trap
    [Arguments]    ${device}    ${port}
    [Documentation]        SNMP start trap
    [Tags]        @author=ssekar
    Snmp Start Trap Host     ${device}      ${port}

SNMP_stop_trap
    [Arguments]    ${device}   
    [Documentation]        SNMP stop trap and verifying it is received
    [Tags]        @author=ssekar
    # Sleep for 70 seconds
    sleep    70s
    snmp stop trap host    ${device} 
    ${result}    snmp get trap host results    ${device}
    Log    ${result} 
    ${len}      Get Length     ${result}
    Return From Keyword     ${result}     ${len}

Enabling NTP server
    [Arguments]    ${device}     ${local_pc_ip}
    [Documentation]        Enabling NTP server
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      30 sec     10 sec     cli    ${device}      configure     timeout=40
    Wait Until Keyword Succeeds      30 sec     10 sec     cli    ${device}      no ntp server 1      timeout=120
    Wait Until Keyword Succeeds      30 sec     10 sec     cli    ${device}      no ntp server 2      timeout=80
    Wait Until Keyword Succeeds      30 sec     10 sec     cli    ${device}      ntp server 1 ${local_pc_ip}      timeout=120
    Wait Until Keyword Succeeds      30 sec     10 sec     cli    ${device}      end     timeout=30
    ${result}    Wait Until Keyword Succeeds      30 sec     10 sec     cli    ${device}      show ntp server      timeout=80
    Should Contain       ${result}      ntp server ${local_pc_ip}
    Should Contain       ${result}      connection-status   Connected
    ${time}   Get DUT current time      ${device} 

SNMP_trap_verification_for_NTP_alarm
    [Arguments]    ${device}    ${result}     ${instance-id}=None     ${parameter}=None
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}
    @{append}    Create List     
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}       Get Dictionary Values     ${list}    
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${ntp_prov}       Get Matches     ${dictionary_value}    regexp=ntp-prov
    \     ${ntp_alarm_raise}       Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    \     ${ntp_alarm_clear}       Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    \     ${ntp_instance_id}       Get Matches     ${dictionary_value}    regexp=${instance-id}
   
    \     ${ntp_length}    Get Length     ${ntp_prov} 
    \     ${ntp_alarm_raise_length}       Get Length     ${ntp_alarm_raise}
    \     ${ntp_alarm_clear_length}       Get Length     ${ntp_alarm_clear}
    \     ${ntp_instance_id_length}       Get Length     ${ntp_instance_id}

    \     Log    *** NTP category check ***
    \     ${ntp_category_key}      Run Keyword If     ${ntp_length} != 0 and '${parameter}' == 'category'    Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmCategory.[0-9]+
    \     ${ntp_category_key}      Run Keyword If     ${ntp_length} != 0 and '${parameter}' == 'category'    Get From List      ${ntp_category_key}     0
    \     ${ntp_category_value}     Run Keyword If    ${ntp_length} != 0 and '${parameter}' == 'category'     Get From Dictionary    ${list}      ${ntp_category_key}
    \     Run Keyword If      ${ntp_length} != 0 and '${parameter}' == 'category'     Should Be Equal As Integers      ${ntp_category_value}     6

    \     Log    *** NTP Alarm type ***
    \     ${ntp_alarm_type_key}      Run Keyword If     ${ntp_length} != 0 and '${parameter}' == 'alarm_type'    Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmType.[0-9]+
    \     ${ntp_alarm_type_key}      Run Keyword If     ${ntp_length} != 0 and '${parameter}' == 'alarm_type'    Get From List      ${ntp_alarm_type_key}      0
    \     ${ntp_alarm_type_value}     Run Keyword If    ${ntp_length} != 0 and '${parameter}' == 'alarm_type'    Get From Dictionary    ${list}      ${ntp_alarm_type_key}  
    \     Run Keyword If      ${ntp_length} != 0 and '${parameter}' == 'alarm_type'     Should Be Equal As Integers      ${ntp_alarm_type_value}      2

    \     Log    *** Verifying NTP severity check 6-clear 1-Major ***
    \     ${ntp_severity_key}      Run Keyword If     '${parameter}' == 'severity' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)   Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmSeverity.[0-9]+
    \     ${ntp_severity_key}      Run Keyword If     '${parameter}' == 'severity' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)    Get From List      ${ntp_severity_key}    0
    \     ${ntp_severity_value}     Run Keyword If     '${parameter}' == 'severity' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)   Get From Dictionary    ${list}      ${ntp_severity_key}
    \     Run Keyword If      '${parameter}' == 'severity' and ${ntp_length} != 0 and ${ntp_alarm_clear_length} != 0    Should Be Equal As Integers      ${ntp_severity_value}    6
    \     Run Keyword If      '${parameter}' == 'severity' and ${ntp_length} != 0 and ${ntp_alarm_raise_length} != 0    Should Be Equal As Integers      ${ntp_severity_value}    1

    \     Log    *** NTP prov description ***
    \     ${ntp_description_key}      Run Keyword If     '${parameter}' == 'description' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmText.[0-9]+
    \     ${ntp_description_key}      Run Keyword If     '${parameter}' == 'description' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get From List      ${ntp_description_key}      0
    \     ${ntp_description_value}     Run Keyword If     '${parameter}' == 'description' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)      Get From Dictionary    ${list}      ${ntp_description_key}
    \     Run Keyword If     '${parameter}' == 'description' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)       Should Be Equal      ${ntp_description_value}     This alarm is to indicate that NTP is not provisioned  

    \     Log    *** Checking NTP prov service-affect is False (2) ***
    \     ${ntp_service_affect_key}      Run Keyword If     '${parameter}' == 'service_affect' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmServiceAffecting.[0-9]+
    \     ${ntp_service_affect_key}      Run Keyword If     '${parameter}' == 'service_affect' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get From List      ${ntp_service_affect_key}     0
    \     ${ntp_service_affect_value}     Run Keyword If     '${parameter}' == 'service_affect' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get From Dictionary    ${list}      ${ntp_service_affect_key}
    \     Run Keyword If     '${parameter}' == 'service_affect' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Should Be Equal As Integers     ${ntp_service_affect_value}      2

    \     Log    *** NTP prov address ***
    \     ${ntp_address_key}      Run Keyword If     '${parameter}' == 'address' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmAddress.[0-9]+
    \     ${ntp_address_key}      Run Keyword If     '${parameter}' == 'address' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get From List      ${ntp_address_key}       0
    \     ${ntp_address_value}     Run Keyword If     '${parameter}' == 'address' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)     Get From Dictionary    ${list}      ${ntp_address_key}
    \     Run Keyword If     '${parameter}' == 'address' and ${ntp_length} != 0 and (${ntp_alarm_clear_length} != 0 or ${ntp_alarm_raise_length} != 0)      Should Be Equal      ${ntp_address_value}     /config/system/ntp


    \     ${ntp_alarm_unshelve}      Run Keyword If   (${ntp_length} != 0 and ${ntp_alarm_raise_length} != 0)    Get From List     ${ntp_alarm_raise}    0
    \     ${ntp_alarm_shelve}      Run Keyword If    (${ntp_length} != 0 and ${ntp_alarm_clear_length} != 0)    Get From List     ${ntp_alarm_clear}    0
    \     ${ntp_alarm_instance_id}     Run Keyword If    (${ntp_length} != 0 and ${ntp_instance_id_length} != 0)    Get From List     ${ntp_instance_id}     0
    \     ${ntp_name}     Run Keyword If    ${ntp_length} != 0    Get From List     ${ntp_prov}    0

    \     Append To List     ${append}      ${ntp_name}
    \     Append To List      ${append}       ${ntp_alarm_unshelve}
    \     Append To List      ${append}       ${ntp_alarm_shelve}
    \     Append To List      ${append}       ${ntp_alarm_instance_id}
    \     Log     ${append}
    ${match}      Get Match Count      ${append}      regexp=ntp-prov
    Should Be True     ${match} >= 2
    ${match}      Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    Should Be True     ${match} >= 1
    ${match}      Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    Should Be True     ${match} >= 1
    ${match}      Get Match Count      ${append}      regexp=${instance-id}
    Should Be True     ${match} >= 2

SNMP_trap_verification_for_application_suspended_alarm
    [Arguments]    ${device}    ${result}      ${instance-id}=None     ${parameter}=None
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}
    @{append}    Create List
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}        Get Dictionary Values     ${list}
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${app_sus}         Get Matches     ${dictionary_value}    regexp=application-suspended 
    \     ${app_alarm_raise}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    \     ${app_alarm_clear}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    \     ${app_instance_id}        Get Matches     ${dictionary_value}    regexp=${instance-id}

    \     ${app_length}    Get Length     ${app_sus}
    \     ${app_alarm_raise_length}       Get Length    ${app_alarm_raise}
    \     ${app_alarm_clear_length}       Get Length    ${app_alarm_clear}
    \     ${app_instance_id_length}       Get Length    ${app_instance_id}

    \     Log    *** Application suspended alarm Category ***
    \     ${app_category_key}      Run Keyword If     ${app_length} != 0 and '${parameter}' == 'category'     Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmCategory.[0-9]+
    \     ${app_category_key}      Run Keyword If     ${app_length} != 0 and '${parameter}' == 'category'      Get From List      ${app_category_key}     0
    \     ${app_category_value}     Run Keyword If    ${app_length} != 0 and '${parameter}' == 'category'     Get From Dictionary    ${list}      ${app_category_key}
    \     Run Keyword If      ${app_length} != 0 and '${parameter}' == 'category'     Should Be Equal As Integers      ${app_category_value}     14

    \     Log    *** ARC Alarm type ***
    \     ${app_alarm_type_key}      Run Keyword If     ${app_length} != 0 and '${parameter}' == 'alarm_type'    Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmType.[0-9]+
    \     ${app_alarm_type_key}      Run Keyword If     ${app_length} != 0 and '${parameter}' == 'alarm_type'    Get From List      ${app_alarm_type_key}      0
    \     ${app_alarm_type_value}     Run Keyword If    ${app_length} != 0 and '${parameter}' == 'alarm_type'    Get From Dictionary    ${list}      ${app_alarm_type_key}
    \     Run Keyword If      ${app_length} != 0 and '${parameter}' == 'alarm_type'      Should Be Equal As Integers      ${app_alarm_type_value}      2

    \     Log    *** Verifying Application suspended severity check 6-clear 0-critical ***
    \     ${app_severity_key}      Run Keyword If     '${parameter}' == 'severity' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)   Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmSeverity.[0-9]+
    \     ${app_severity_key}      Run Keyword If    '${parameter}' == 'severity' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)    Get From List      ${app_severity_key}    0
    \     ${app_severity_value}     Run Keyword If    '${parameter}' == 'severity' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)   Get From Dictionary    ${list}      ${app_severity_key}
    \     Run Keyword If      '${parameter}' == 'severity' and ${app_length} != 0 and ${app_alarm_clear_length} != 0    Should Be Equal As Integers      ${app_severity_value}    6
    \     Run Keyword If      '${parameter}' == 'severity' and ${app_length} != 0 and ${app_alarm_raise_length} != 0    Should Be Equal As Integers      ${app_severity_value}    0

    \     Log    *** Application suspended description ***
    \     ${app_description_key}      Run Keyword If     '${parameter}' == 'description' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmText.[0-9]+
    \     ${app_description_key}      Run Keyword If     '${parameter}' == 'description' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get From List      ${app_description_key}      0
    \     ${app_description_value}     Run Keyword If     '${parameter}' == 'description' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)      Get From Dictionary    ${list}      ${app_description_key}
    \     Run Keyword If     '${parameter}' == 'description' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)       Should Be Equal      ${app_description_value}     An application has repeatedly failed to execute properly

    \     Log    *** Verifying Application suspended service-affect is False(2) ***
    \     ${app_service_affect_key}      Run Keyword If     '${parameter}' == 'service_affect' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmServiceAffecting.[0-9]+
    \     ${app_service_affect_key}      Run Keyword If     '${parameter}' == 'service_affect' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get From List      ${app_service_affect_key}     0
    \     ${app_service_affect_value}     Run Keyword If     '${parameter}' == 'service_affect' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get From Dictionary    ${list}      ${app_service_affect_key}
    \     Run Keyword If     '${parameter}' == 'service_affect' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Should Be Equal As Integers     ${app_service_affect_value}      2

    \     Log    *** Application suspended address ***
    \     ${app_sus_address_key}      Run Keyword If     '${parameter}' == 'address' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get Matches     ${dictionary_keys}    regexp=AXOS-ALARM-MIB::axosAlarmAddress.[0-9]+
    \     ${app_sus_address_key}      Run Keyword If     '${parameter}' == 'address' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get From List      ${app_sus_address_key}       0
    \     ${app_sus_address_value}     Run Keyword If     '${parameter}' == 'address' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)     Get From Dictionary    ${list}      ${app_sus_address_key}
    \     Run Keyword If     '${parameter}' == 'address' and ${app_length} != 0 and (${app_alarm_clear_length} != 0 or ${app_alarm_raise_length} != 0)      Should Be Equal      ${app_sus_address_value}     /config/system
    
    \     ${app_alarm_unshelve}      Run Keyword If    (${app_length} != 0 and ${app_alarm_raise_length} != 0)    Get From List      ${app_alarm_raise}     0
    \     ${app_alarm_shelve}      Run Keyword If     (${app_length} != 0 and ${app_alarm_clear_length} != 0)    Get From List          ${app_alarm_clear}    0     
    \     ${app_alarm_instance_id}     Run Keyword If     (${app_length} != 0 and ${app_instance_id_length} != 0)       Get From List       ${app_instance_id}     0
    \     ${app_name}      Run Keyword If      ${app_length} != 0     Get From List    ${app_sus}     0

    \     Append To List     ${append}      ${app_name}
    \     Append To List     ${append}      ${app_alarm_unshelve}
    \     Append To List     ${append}      ${app_alarm_shelve}
    \     Append To List     ${append}      ${app_alarm_instance_id}
    \     Log     ${append}

    ${match}     Get Match Count      ${append}      regexp=application-suspended
    Should Be True     ${match} >= 2
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    Should Be True     ${match} >= 1
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    Should Be True     ${match} >= 1
    ${match}     Get Match Count      ${append}      regexp=${instance-id}
    Should Be True     ${match} >= 2

SNMP_trap_verification_for_running_config_unsaved_alarm
    [Arguments]    ${device}    ${result}      ${instance-id}=None     ${parameter}=None
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}
    @{append}    Create List
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}        Get Dictionary Values     ${list}
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${run_con}         Get Matches     ${dictionary_value}    regexp=running-config-unsaved
    \     ${run_alarm_raise}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    \     ${run_alarm_clear}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    \     ${run_instance_id}        Get Matches     ${dictionary_value}    regexp=${instance-id}

    \     ${run_length}    Get Length     ${run_con}
    \     ${run_alarm_raise_length}       Get Length    ${run_alarm_raise}
    \     ${run_alarm_clear_length}       Get Length    ${run_alarm_clear}
    \     ${run_instance_id_length}       Get Length    ${run_instance_id} 

    \     ${run_con_alarm_raise}      Run Keyword If    (${run_length} != 0 and ${run_alarm_raise_length} != 0)    Get From List      ${run_alarm_raise}     0
    \     ${run_con_alarm_clear}      Run Keyword If     (${run_length} != 0 and ${run_alarm_clear_length} != 0)    Get From List          ${run_alarm_clear}    0
    \     ${run_con_alarm_instance_id}     Run Keyword If     (${run_length} != 0 and ${run_instance_id_length} != 0)       Get From List       ${run_instance_id}     0
    \     ${run_con_name}      Run Keyword If      ${run_length} != 0     Get From List    ${run_con}     0

    \     Append To List     ${append}      ${run_con_name}
    \     Append To List     ${append}      ${run_con_alarm_raise}
    \     Append To List     ${append}      ${run_con_alarm_clear}
    \     Append To List     ${append}      ${run_con_alarm_instance_id}
    \     Log     ${append}

    ${match}      Run Keyword If     '${parameter}' != 'ack'     Get Match Count      ${append}      regexp=running-config-unsaved
    Run Keyword If     '${parameter}' != 'ack'    Should Not Be Equal As Integers      ${match}    0
    ${match}     Run Keyword If     '${parameter}' == 'shelve' or '${parameter}' == 'clear'    Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    Run Keyword If     '${parameter}' == 'shelve' or '${parameter}' == 'clear'    Should Be True     ${match} >= 1
    ${match}     Run Keyword If     '${parameter}' == 'unshelve' or '${parameter}' == 'raise'    Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    Run Keyword If     '${parameter}' == 'unshelve' or '${parameter}' == 'raise'   Should Be True     ${match} >= 1
    ${match}     Run Keyword If     '${parameter}' != 'ack'      Get Match Count      ${append}      regexp=${instance-id}
    Run Keyword If     '${parameter}' != 'ack'       Should Not Be Equal As Integers      ${match}    0
    ${match}     Run Keyword If     '${parameter}' == 'ack'      Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    Run Keyword If     '${parameter}' == 'ack'      Should Be Equal As Integers      ${match}    0

SNMP_trap_verification_for_loss_of_signal_alarm
    [Arguments]    ${device}    ${result}      
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}
    @{append}    Create List
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}        Get Dictionary Values     ${list}
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${signal_loss}    Get Matches     ${dictionary_value}    regexp=loss-of-signal
    \     ${signal_alarm_raise}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    \     ${signal_alarm_clear}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmCleared

    \     ${signal_length}    Get Length     ${signal_loss}
    \     ${signal_alarm_raise_length}       Get Length    ${signal_alarm_raise}
    \     ${signal_alarm_clear_length}       Get Length    ${signal_alarm_clear}    

    \     ${signal_loss_alarm_raise}     Run Keyword If    (${signal_length} != 0 and ${signal_alarm_raise_length} != 0)    Get From List     ${signal_alarm_raise}   0
    \     ${signal_loss_alarm_clear}     Run Keyword If    (${signal_length} != 0 and ${signal_alarm_clear_length} != 0)    Get From List     ${signal_alarm_clear}   0
    \     ${signal_loss_name}      Run Keyword If    ${signal_length} != 0       Get From List    ${signal_loss}    0

    \     Append To List     ${append}      ${signal_loss_name}
    \     Append To List     ${append}      ${signal_loss_alarm_raise}
    \     Append To List     ${append}      ${signal_loss_alarm_clear}
    \     Log     ${append}

    ${match}      Get Match Count      ${append}      regexp=loss-of-signal
    Should Not Be Equal As Integers      ${match}    0
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    Should Be True     ${match} >= 1
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    Should Be True     ${match} >= 1

SNMP_trap_verifications
    [Arguments]    ${device}    ${result}     ${name}     ${raise_time}=    ${clear_time}=
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}    
    @{append}    Create List
    ${len_raise}    Get Length      ${raise_time}
    ${len_clear}     Get Length      ${clear_time}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}        Get Dictionary Values     ${list}
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${alarm_name}    Get Matches     ${dictionary_value}    regexp=${name}
    \     ${alarm_raise}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    \     ${alarm_clear}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    \     ${time}            Get Matches     ${dictionary_value}    regexp=\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}-\\d{2}:\\d{2}


    \     ${len}    Get Length     ${alarm_name}
    \     ${alarm_raise_len}     Get Length     ${alarm_raise}
    \     ${alarm_clear_len}     Get Length     ${alarm_clear}
    \     ${alarm_time_len}      Get Length     ${time}

    \     ${gen_alarm}      Run Keyword If    ${len} != 0       Get From List    ${alarm_name}     0
    \     ${gen_alarm_raise}      Run Keyword If    (${len} != 0 and ${alarm_raise_len} != 0)    Get From List     ${alarm_raise}     0
    \     ${gen_alarm_clear}      Run Keyword If    (${len} != 0 and ${alarm_clear_len} != 0)    Get From List     ${alarm_clear}     0
    \     ${gen_alarm_time}      Run Keyword If    (${len} != 0 and ${alarm_time_len} != 0)    Get From List     ${time}     0
    \     ${gen_alarm_time}     Run Keyword If   (${len} != 0 and ${alarm_time_len} != 0)    Get Regexp Matches     ${gen_alarm_time}   .*T(\\d{2}:\\d{2}:\\d{2})     1
    \     ${gen_alarm_time}     Run Keyword If   (${len} != 0 and ${alarm_time_len} != 0)    Get From List     ${gen_alarm_time}    0

    \     Append To List     ${append}       ${gen_alarm} 
    \     Append To List     ${append}       ${gen_alarm_raise}
    \     Append To List     ${append}       ${gen_alarm_clear}
    \     Append To List     ${append}       ${gen_alarm_time} 
    \     Log     ${append}

    ${match_name}      Get Match Count      ${append}      regexp=${name}
    Should Not Be Equal As Integers      ${match_name}    0
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    Should Be True     ${match} >= 1
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    Should Be True     ${match} >= 1
    Run Keyword If    ${len_raise} != 0     Verifying time sync     ${append}     ${raise_time}
    Run Keyword If    ${len_clear} != 0     Verifying time sync     ${append}     ${clear_time}
    [Return]     ${match_name}

SNMP_trap_verifications_for_events
    [Arguments]    ${device}    ${result}     ${name}
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}
    @{append}    Create List
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}        Get Dictionary Values     ${list}
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${event_name}    Get Matches     ${dictionary_value}    regexp=${name}

    \     ${len}    Get Length     ${event_name}

    \     ${gen_event}      Run Keyword If    ${len} != 0       Get From List    ${event_name}     0

    \     Append To List     ${append}       ${gen_event}
    \     Log     ${append}

    ${match}      Get Match Count      ${append}      regexp=${name}
    ${result}    Should Not Be Equal As Integers      ${match}    0
    Log    ${result}   

SNMP_trap_verification_for_ntpd_down_alarm
    [Arguments]    ${device}    ${result}      ${instance-id}=None     ${parameter}=None      ${raise_time}=      ${clear_time}=
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}
    ${len_raise}    Get Length      ${raise_time}
    ${len_clear}     Get Length      ${clear_time}
    @{append}    Create List
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}        Get Dictionary Values     ${list}
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${ntpd_con}         Get Matches     ${dictionary_value}    regexp=ntpd-down
    \     ${ntpd_alarm_raise}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    \     ${ntpd_alarm_clear}        Get Matches     ${dictionary_value}    regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    \     ${ntpd_instance_id}        Get Matches     ${dictionary_value}    regexp=${instance-id}
    \     ${time}            Get Matches     ${dictionary_value}    regexp=\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}-\\d{2}:\\d{2}

    \     ${ntpd_length}    Get Length     ${ntpd_con}
    \     ${ntpd_alarm_raise_length}       Get Length    ${ntpd_alarm_raise}
    \     ${ntpd_alarm_clear_length}       Get Length    ${ntpd_alarm_clear}
    \     ${ntpd_instance_id_length}       Get Length    ${ntpd_instance_id}
    \     ${alarm_time_len}      Get Length     ${time}
   
    \     ${ntpd_con_alarm_raise}      Run Keyword If    (${ntpd_length} != 0 and ${ntpd_alarm_raise_length} != 0)    Get From List      ${ntpd_alarm_raise}     0
    \     ${ntpd_con_alarm_clear}      Run Keyword If     (${ntpd_length} != 0 and ${ntpd_alarm_clear_length} != 0)    Get From List          ${ntpd_alarm_clear}    0
    \     ${ntpd_con_alarm_instance_id}     Run Keyword If     (${ntpd_length} != 0 and ${ntpd_instance_id_length} != 0)       Get From List       ${ntpd_instance_id}     0
    \     ${ntpd_con_name}      Run Keyword If      ${ntpd_length} != 0     Get From List    ${ntpd_con}     0
    \     ${gen_alarm_time}      Run Keyword If    (${len} != 0 and ${alarm_time_len} != 0)    Get From List     ${time}     0
    \     ${gen_alarm_time}     Run Keyword If   (${len} != 0 and ${alarm_time_len} != 0)    Get Regexp Matches     ${gen_alarm_time}   .*T(\\d{2}:\\d{2}:\\d{2})     1
    \     ${gen_alarm_time}     Run Keyword If   (${len} != 0 and ${alarm_time_len} != 0)    Get From List     ${gen_alarm_time}    0

    \     Append To List     ${append}      ${ntpd_con_name}
    \     Append To List     ${append}      ${ntpd_con_alarm_raise}
    \     Append To List     ${append}      ${ntpd_con_alarm_clear}
    \     Append To List     ${append}      ${ntpd_con_alarm_instance_id}
    \     Append To List     ${append}       ${gen_alarm_time}
    \     Log     ${append}

    ${match}      Get Match Count      ${append}      regexp=ntpd-down
    Should Not Be Equal As Integers      ${match}    0
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmCleared
    Should Be True     ${match} >= 1
    ${match}     Get Match Count      ${append}      regexp=Axos-Trap-MIB::axosTrapAlarmRaised
    Should Be True     ${match} >= 1
    ${match}     Get Match Count      ${append}      regexp=${instance-id}
    Should Not Be Equal As Integers      ${match}    0
    Run Keyword If    ${len_raise} != 0     Verifying time sync     ${append}     ${raise_time}
    Run Keyword If    ${len_clear} != 0     Verifying time sync     ${append}     ${clear_time}

SNMP_trap_verification_for_config-file-copied
    [Arguments]    ${device}    ${result}  
    [Documentation]        Verifying SNMP traps got received
    [Tags]        @author=ssekar
    ${len}      Get Length     ${result}
    @{append}    Create List
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \     ${list}    Get From List      ${result}     ${INDEX}
    \     ${dictionary_value}        Get Dictionary Values     ${list}
    \     ${dictionary_keys}        Get Dictionary Keys      ${list}
    \     ${run_con}         Get Matches     ${dictionary_value}    regexp=config-file-copied

    \     ${run_length}    Get Length     ${run_con}

    \     ${run_con_name}      Run Keyword If      ${run_length} != 0     Get From List    ${run_con}     0

    \     Append To List     ${append}      ${run_con_name}
    \     Log     ${append}
    ${match}      Get Match Count      ${append}      regexp=config-file-copied
    Should Not Be Equal As Integers      ${match}     0

SNMP_port_redirect_on_localpc
    [Arguments]    ${device}         ${user_password}
    [Documentation]        SNMP port redirection
    [Tags]        @author=ssekar
   
    Wait Until Keyword Succeeds      2 min     10 sec         Disconnect     ${device}
    cli    ${device}      cd /home        timeout_exception=0         timeout=90
    cli    ${device}      sudo iptables -t nat -A PREROUTING -p udp --dport 162 -j REDIRECT --to-port 1620       timeout_exception=0       prompt=[sudo]     timeout=300
    cli    ${device}      ${user_password}         timeout_exception=0         timeout=90          prompt=home
    Wait Until Keyword Succeeds      2 min     10 sec         cli    ${device}      sudo iptables -t nat -A PREROUTING -p tcp --dport 162 -j REDIRECT --to-port 1620       timeout_exception=0        timeout=300        prompt=home
    ${result}     Wait Until Keyword Succeeds      2 min     10 sec         cli    ${device}      sudo iptables -t nat -n -L      timeout_exception=0        timeout=300     prompt=home
    Should Contain      ${result}       udp dpt:162 redir ports 1620
    Should Contain      ${result}       tcp dpt:162 redir ports 1620
    cli    ${device}       sudo service snmpd stop       timeout_exception=0         timeout=90      prompt=home
    cli    ${device}       sudo service snmptrapd stop     timeout_exception=0         timeout=90      prompt=home

SNMP_port_redirect_removal_on_localpc
    [Arguments]    ${device}       ${user_password}
    [Documentation]        SNMP port redirection removal
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec         Disconnect     ${device}
    cli    ${device}      cd /home        timeout_exception=0         timeout=90
    cli    ${device}      sudo iptables -t nat -D PREROUTING -p udp --dport 162 -j REDIRECT --to-port 1620       timeout_exception=0       prompt=[sudo]     timeout=300
    cli    ${device}      ${user_password}         timeout_exception=0         timeout=90          prompt=home
    Wait Until Keyword Succeeds      2 min     10 sec         cli    ${device}      sudo iptables -t nat -D PREROUTING -p tcp --dport 162 -j REDIRECT --to-port 1620       timeout_exception=0        timeout=300        prompt=home
   

Unconfigure SYSLOG server on DUT
    [Arguments]    ${device}    ${syslog_server_ip}
    [Documentation]        Unconfigure SYSLOG server
    [Tags]        @author=ssekar
    cli    ${device}      configure      timeout=90
    cli    ${device}      no logging host ${syslog_server_ip}     timeout=90
    cli    ${device}      end    timeout=90
    ${result}     cli    ${device}      show running-config logging host    timeout=90
    Result Should Not Contain       logging host ${syslog_server_ip}

Unconfigure SYSLOG server on DUT using netconf
    [Arguments]    ${device}    ${syslog_server_ip}
    [Documentation]        Unconfigure SYSLOG server
    [Tags]        @author=ssekar
    ${result}      Netconf Raw     ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><logging><host xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" nc:operation="delete"><name>${syslog_server_ip}</name></host></logging></system></config></config></edit-config></rpc>]]>]]> 
    Should Contain     ${result.xml}       <ok/>

Syslog_server_configure_on_local_PC
    [Arguments]    ${device}   ${syslog_server_ip}     ${user_password}
    [Documentation]        syslog server configuration in local PC
    [Tags]        @author=ssekar
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}     
    Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}
    cli    ${device}      sudo service rsyslog start    timeout_exception=0       prompt=[sudo]      timeout=300
    ${result}     cli    ${device}      ${user_password}         timeout_exception=0         timeout=90
    ${result}     Get Lines Containing String       ${result}        rsyslog: unrecognized service
    Run Keyword If   '${result}' == 'rsyslog: unrecognized service'    Run Keywords     cli    ${device}     sudo yum install rsyslog      prompt=(\[y/N\]):    timeout_exception=0        timeout=90
    ...      AND      cli    ${device}     y       timeout_exception=0      timeout=90
    ...      AND      cli    ${device}      ${user_password}         timeout_exception=0      timeout=90
    cli    ${device}      sudo chmod 777 /etc/rsyslog.conf     timeout_exception=0       timeout=90
    cli    ${device}        cd /etc/      timeout_exception=0
    cli    ${device}        ex -sc '%s/#$ModLoad imudp/$ModLoad imudp/g|x' rsyslog.conf      timeout_exception=0
    cli    ${device}        ex -sc '%s/#$UDPServerRun/$UDPServerRun/g|x' rsyslog.conf       timeout_exception=0
    cli    ${device}        ex -sc '%s/#$ModLoad imtcp/$ModLoad imtcp/g|x' rsyslog.conf      timeout_exception=0
    cli    ${device}        ex -sc '%s/#$InputTCPServerRun/$InputTCPServerRun/g|x' rsyslog.conf      timeout_exception=0
  
    cli    ${device}      sudo chmod 777 /var/run/syslogd.pid    timeout_exception=0     timeout=120
    cli    ${device}        cd /var/log      timeout=20     timeout_exception=0
    cli    ${device}        sudo mkdir syslog      timeout=20      timeout_exception=0
    cli    ${device}        sudo chmod 777 syslog/       timeout=20       timeout_exception=0

    : FOR    ${INDEX}    IN RANGE    1    3
    \    ${match_pri}     OperatingSystem.Get File    /etc/rsyslog.conf    
    \    ${match_pri}    Run Keyword And Return Status      Run Keywords       Should Contain     ${match_pri}       pri-text
    \    ...      AND      Should Contain     ${match_pri}       $ActionFileDefaultTemplate precise
    \    ...      AND      Should Contain     ${match_pri}       ?RemoteLogs
    \    ...      AND      Should Contain     ${match_pri}       & ~
    \    Log     ${match_pri}
    \    Run Keyword If     '${match_pri}' == 'False'      Configuring rsyslog file on local pc       ${device}      ${user_password}
    \    Exit For Loop If    '${match_pri}' == 'True'

    Log    *** Deleting Syslog file and restarting syslog server ***
    cli    ${device}        sudo rm /var/log/syslog/syslog.log      timeout=120
    ${result}      cli    ${device}      sudo service rsyslog restart    timeout_exception=0     prompt=Starting system logger:    timeout=120
    #sleep for 10s
    Sleep    10s

Configuring rsyslog file on local pc
    [Arguments]    ${device}     ${user_password}
    [Documentation]        syslog server configuration in local PC
    [Tags]        @author=ssekar

    # Commenting out existing $ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
    cli    ${device}    ex -sc '%s/$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat/#$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat/g|x' /etc/rsyslog.conf      timeout_exception=0       timeout=90

    # Adding template for syslog message
    cli    ${device}    sudo chown -R 777 /tmp/       timeout=90     timeout_exception=0   
    cli    ${device}    sudo cp /etc/rsyslog.conf /tmp/rsyslog.conf    timeout=90     timeout_exception=0    

    cli    ${device}    awk '/GLOBAL DIRECTIVES/{print;print "cygwin";next}1' /tmp/rsyslog.conf > /etc/rsyslog.conf     timeout=90   
    cli    ${device}    ex -sc '%s/cygwin/$template precise,"Priority:%pri-text%(%pri%),Severity:%syslogseverity%,Facility:%syslogfacility%,Host_ip:%fromhost-ip%,Msg:%rawmsg%\\\\n"/g|x' /etc/rsyslog.conf     timeout=90   
    cli    ${device}    sudo cp /etc/rsyslog.conf /tmp/rsyslog.conf    timeout=90     
    cli    ${device}    awk '/pri-text/{print;print "cygwin1";next}1' /tmp/rsyslog.conf > /etc/rsyslog.conf     timeout=90     
    cli    ${device}    ex -sc '%s/cygwin1/$ActionFileDefaultTemplate precise/g|x' /etc/rsyslog.conf     timeout=90    timeout_exception=0    prompt=etc
   
    # Adding $template RemoteLogs,"/var/log/syslog/syslog.log" *  
    cli    ${device}    sudo cp /etc/rsyslog.conf /tmp/rsyslog.conf    timeout=90     
    cli    ${device}     awk '/ActionFileDefaultTemplate precise/{print;print "cygwin2";next}1' /tmp/rsyslog.conf > /etc/rsyslog.conf
    ...         timeout=90     timeout_exception=0    
    cli    ${device}    ex -sc '%s@cygwin2@$template RemoteLogs,"/var/log/syslog/syslog.log" *@g|x' /etc/rsyslog.conf     timeout=90     timeout_exception=0   
  
    # Adding *.*  ?RemoteLogs
    cli    ${device}    sudo cp /etc/rsyslog.conf /tmp/rsyslog.conf    timeout=90     
    cli    ${device}    awk '/syslog.log/{print;print "*.*\ \ \?RemoteLogs";next}1' /tmp/rsyslog.conf > /etc/rsyslog.conf     timeout=90     

    # Adding & ~    
    cli    ${device}    sudo cp /etc/rsyslog.conf /tmp/rsyslog.conf    timeout=90    
    cli    ${device}    awk '/\?RemoteLogs/{print;print "\&\ \~";next}1' /tmp/rsyslog.conf > /etc/rsyslog.conf     timeout=90     timeout_exception=0    

    Run Keywords     Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    ...     AND      Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}
    ...     AND      cli    ${device}      sudo service rsyslog start    timeout_exception=0       prompt=[sudo]      timeout=120
    ...     AND      cli    ${device}      ${user_password}         timeout_exception=0         timeout=90
    ...     AND      cli    ${device}      sudo rm /tmp/rsyslog.conf    timeout=90     timeout_exception=0      

Restarting syslog server on local pc
    [Arguments]    ${device}   ${syslog_server_ip}     ${user_password}
    [Documentation]        Restarting syslog server on local pc
    [Tags]        @author=ssekar
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}
    Wait Until Keyword Succeeds      2 min     10 sec            cli      ${device}        cd /var/log      timeout=50
    cli      ${device}      sudo rm messages      timeout_exception=0          prompt=password       timeout=120      
    cli      ${device}      ${user_password}         timeout_exception=0         timeout=90
    cli      ${device}      sudo service rsyslog restart    timeout_exception=0     prompt=Starting system logger:    timeout=120
    ${result}     cli    ${device}       sudo service rsyslog status      timeout_exception=0     timeout=120
    Should Contain    ${result}     is running
    #sleep for 10s
    sleep     10s
 
Clearing history log captured in syslog server
    [Arguments]    ${device}   ${syslog_server_ip}     ${user_password}     
    [Documentation]        Clearing history log captured in syslog server
    [Tags]        @author=ssekar
    Wait Until Keyword Succeeds      2 min     10 sec         Disconnect     ${device}      
    #cli    ${device}     cd /var/log       timeout=120 
    #cli    ${device}     sudo cat /var/log/messages       timeout_exception=0       retry=4      prompt=password    timeout=120
    #${get_file}=      cli    ${device}      ${user_password}         timeout_exception=0      prompt=Details:Alarm-log     timeout=150
    ${get_file}     OperatingSystem.Get File    /var/log/syslog/syslog.log
    Log     ${get_file}
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    ${count1}    Get Line Count    ${get_file}
    Should Contain     ${get_file}          /exec/active-alarm-log
    Should Contain     ${get_file}          clear active_alarm_log
    Should Contain     ${get_file}                Name:log-clear, Category:GENERAL Cause:User has chosen to clear the log

Configuring location in DUT
    [Arguments]     ${device}     ${user_interface}
    [Documentation]         Configuring location in DUT
    [Tags]        @author=ssekar

    Run Keyword If     '${user_interface}' == 'cli'      Run Keywords         cli     ${device}     configure        timeout_exception=0     timeout=60
    ...    AND     cli     ${device}     no location     timeout_exception=0     timeout=60
    ...    AND     cli     ${device}     location gallantgriffins      timeout_exception=0     timeout=60
    ...    AND     cli     ${device}     no location     timeout_exception=0     timeout=60
    ...    AND     cli     ${device}     end     timeout=60
   
    Run Keyword If     '${user_interface}' == 'netconf'    Run Keywords     Netconf Raw      ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><location></location></system></config></config></edit-config></rpc>]]>]]>
    ...   AND     Netconf Raw      ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><location>gallantgriffins</location></system></config></config></edit-config></rpc>]]>]]>
    ...   AND     Netconf Raw      ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><location></location></system></config></config></edit-config></rpc>]]>]]>         

Alarm_messages_in_syslog_server
    [Arguments]     ${DUT}     ${device}      ${syslog_server_ip}     ${user_password}     ${user_interface}=cli     ${alarm}=None    ${env}=false   ${raise_time}=None
    ...             ${clear_time}=None
    [Documentation]        Alarm messages recorded in syslog server
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Configuring location in DUT      ${DUT}     ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${device}
    #sleep for 10s
    Sleep     10s
    cli    ${device}     cd /var/log/syslog      timeout=120     retry=4
    #cli    ${device}     sudo cat /var/log/syslog/syslog.log       timeout_exception=0        retry=4        prompt=password     timeout=120
    #${get_file}=      cli    ${device}      ${user_password}         timeout_exception=0      prompt=gallantgriffins    timeout=150      retry=4
    ${get_file}     OperatingSystem.Get File    /var/log/syslog/syslog.log
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    Log    ${get_file}
    ${result}       Run Keyword If    '${alarm}' == 'module-fault'    Get Lines Containing String       ${get_file}      Id:1204, Name:module-fault
    Run Keyword If    '${alarm}' == 'module-fault'    Log    ${result}
    ${count1}    Run Keyword If    '${alarm}' == 'module-fault'    Get Line Count    ${result}
    Run Keyword If    '${alarm}' == 'module-fault'    Should Be True    ${count1} >= 2
    
    ${result}       Run Keyword If    '${alarm}' == 'unsupported-equipment'     Get Lines Containing String       ${get_file}      Id:1225, Name:unsupported-equipment
    Run Keyword If    '${alarm}' == 'unsupported-equipment'     Log    ${result}
    ${count1}    Run Keyword If    '${alarm}' == 'unsupported-equipment'    Get Line Count    ${result}
    Run Keyword If    '${alarm}' == 'unsupported-equipment'    Should Be True    ${count1} >= 2 

    ${result}       Run Keyword If    '${alarm}' == 'dhcp-server-detected'     Get Lines Containing String       ${get_file}      Id:1917, Name:dhcp-server-detected
    Run Keyword If    '${alarm}' == 'dhcp-server-detected'     Log    ${result}

    Log    ****** dhcp-server-detected:Verifying syslog message time sync with DUT ********
    @{loc_list}    Run Keyword If    '${alarm}' == 'dhcp-server-detected'     Get Regexp Matches    ${result}     (\\d{2}:\\d{2}:\\d{2})   1
    Run Keyword If    '${alarm}' == 'dhcp-server-detected'     Run Keywords      Verifying time sync      ${loc_list}      ${raise_time}
    ...     AND     Verifying time sync      ${loc_list}      ${clear_time}
    ${count1}    Run Keyword If    '${alarm}' == 'dhcp-server-detected'     Get Line Count    ${result}
    Run Keyword If    '${alarm}' == 'dhcp-server-detected'     Should Be True    ${count1} >= 2

    ${result}       Run Keyword If    '${alarm}' == 'improper-removal'     Get Lines Containing String       ${get_file}      Id:1203, Name:improper-removal
    Run Keyword If    '${alarm}' == 'improper-removal'     Log    ${result}
    Log    ****** improper-removal:Verifying syslog message time sync with DUT ********
    @{loc_list}    Run Keyword If    '${alarm}' == 'improper-removal'     Get Regexp Matches    ${result}     (\\d{2}:\\d{2}:\\d{2})   1
    Run Keyword If    '${alarm}' == 'improper-removal'     Run Keywords      Verifying time sync      ${loc_list}      ${raise_time}
    ...     AND     Verifying time sync      ${loc_list}      ${clear_time}
    ${count1}    Run Keyword If    '${alarm}' == 'improper-removal'     Get Line Count    ${result}
    Run Keyword If    '${alarm}' == 'improper-removal'     Should Be True    ${count1} >= 2

    ${result}       Run Keyword If    '${alarm}' == 'source-verify-resources-limited'     Get Lines Containing String       ${get_file}      Id:2302, Name:source-verify-resources-limited
    Run Keyword If    '${alarm}' == 'source-verify-resources-limited'     Log    ${result}
    ${count1}    Run Keyword If    '${alarm}' == 'source-verify-resources-limited'     Get Line Count    ${result}
    Run Keyword If    '${alarm}' == 'source-verify-resources-limited'     Should Be True    ${count1} >= 2

    #Alarm lacp-fault-on-port
    ${result}       Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Get Lines Containing String       ${get_file}      Id:2101, Name:lacp-fault-on-port
    Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Log    ${result}

    Log    ****** Checking Syslog level, priority, and Facility *******
    ${syslog_level}   Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Get Regexp Matches     ${result} 
    ...       (Priority:local7.emerg.184.,Severity:0,Facility:23.*Msg:<184>)    1
    ${len_syslog_level}   Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Get Length      ${syslog_level}
    Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Should Be True    ${len_syslog_level} >= 2 
    
    Log    ****** Verifying syslog message time sync with DUT ********
    @{loc_list}    Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Get Regexp Matches    ${result}     (\\d{2}:\\d{2}:\\d{2})   1
    Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Run Keywords      Verifying time sync      ${loc_list}      ${raise_time}   
    ...     AND     Verifying time sync      ${loc_list}      ${clear_time}
    
    ${count1}    Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Get Line Count    ${result}
    Run Keyword If    '${alarm}' == 'lacp-fault-on-port'     Should Be True    ${count1} >= 2

    ${result}       Run Keyword If    '${env}' == 'true'     Get Lines Containing String       ${get_file}      Name:${alarm}
    Run Keyword If    '${env}' == 'true'     Log    ${result}
    ${count1}    Run Keyword If    '${env}' == 'true'     Get Line Count    ${result}  
    Run Keyword If    '${env}' == 'true'     Should Be True    ${count1} >= 2

Verifying time sync
    [Arguments]     ${loc_list}      ${time}
    [Documentation]        Verifying time sync
    [Tags]        @author=ssekar

    ${len_loc_list}     Get Length     ${loc_list}
    ${len_time}     Get Length     ${time}
    : FOR    ${INDEX}    IN RANGE    0    ${len_time}
    \      ${list}     Get From List    ${time}    ${INDEX}
    \      ${mat}     Run Keyword And Return Status     List Should Contain Value      ${loc_list}      ${list}
    \      Exit For Loop If     '${mat}' == 'True' 
    Run Keyword If   '${mat}' == 'False'      Fail     


Alarms_acknowledge_copy_registered_in_syslog_server
    [Arguments]     ${DUT}     ${device}      ${syslog_server_ip}     ${user_password}     ${instance-id}     ${user}=sysadmin         ${ack_time}=None    
    ...             ${user_interface}=cli    
    [Documentation]        Alarm acknowledged message is collected in syslog server
    [Tags]        @author=ssekar

    #sleep for 10s
    Sleep     10s
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring location in DUT      ${DUT}     ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${device}      
    Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}
    cli    ${device}     cd /var/log/syslog      timeout=120      retry=4
    #cli    ${device}     sudo cat /var/log/syslog/syslog.log       timeout_exception=0        retry=4        prompt=password     timeout=120

    ${get_file}     OperatingSystem.Get File    /var/log/syslog/syslog.log
    #${get_file}=      cli    ${device}      ${user_password}         timeout_exception=0      prompt=gallantgriffins    timeout=150      retry=4
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    ${count1}    Get Line Count    ${get_file}
    ${result}       Get Lines Containing String       ${get_file}      ${instance-id}
    Log     ${result}
    
    Log    ****** Checking Syslog level, priority, and Facility *******
    ${syslog_level}     Get Regexp Matches     ${result}      (Priority:local7.info.190.,Severity:6,Facility:23.*Msg:<190>)     1
    ${len_syslog_level}        Get Length      ${syslog_level}
    Should Be True    ${len_syslog_level} >= 2

    Log    ****** Verifying syslog message time sync with DUT ********
    @{list_time}      Get Regexp Matches     ${result}       (\\d{2}:\\d{2}:\\d{2})   1
    Wait Until Keyword Succeeds      30 sec     10 sec      Verifying time sync     ${list_time}      ${ack_time}

    Should Contain     ${get_file}                /exec/manual-acknowledge[instance-id='${instance-id}']
    Should Match Regexp        ${get_file}         set ackalarm ${instance-id}.*${user},cli

Alarm_application_suspended_recorded_on_syslog_server
    [Arguments]     ${DUT}     ${device}      ${syslog_server_ip}     ${user_password}     ${parameter}=None     ${user_interface}=cli
    [Documentation]        Verifying application suspended alarm triggered and cleared messages registered on syslog server
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Configuring location in DUT      ${DUT}      ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${device}
    Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}
    cli    ${device}     cd /var/log/syslog      timeout=120     timeout_exception=0
    #cli    ${device}     sudo cat /var/log/syslog/syslog.log       timeout_exception=0        retry=4        prompt=password     timeout=120
    #${get_file}=      cli    ${device}      ${user_password}         timeout_exception=0      prompt=gallantgriffins    timeout=150
    ${get_file}     OperatingSystem.Get File    /var/log/syslog/syslog.log
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    ${count1}    Get Line Count    ${get_file}
    Log     ${get_file}
    ${result}     Run Keyword If    '${parameter}' == 'alarm_raise'      Should Contain     ${get_file}      Id:1702, Name:application-suspended, Category:ARC Cause:Application crashed or locked up more than three times in 5 minutes, Details:loam

Alarm_running_config_unsaved_registered_on_syslog_server
    [Arguments]     ${DUT}     ${device}      ${syslog_server_ip}     ${user_password}     ${parameter}     ${user_interface}=cli
    [Documentation]        Verifying running config unsaved alarm triggered and cleared messages registered on syslog server
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Configuring location in DUT      ${DUT}      ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${device}
    Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}
    cli    ${device}     cd /var/log/syslog      timeout=120       timeout_exception=0
    #cli    ${device}     sudo cat /var/log/syslog/syslog.log       timeout_exception=0        retry=4        prompt=password     timeout=120
    #${get_file}=      cli    ${device}      ${user_password}         timeout_exception=0      prompt=gallantgriffins    timeout=150
    ${get_file}     OperatingSystem.Get File    /var/log/syslog/syslog.log
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    ${count1}    Get Line Count    ${get_file}
    ${result}     Run Keyword If    '${parameter}' == 'shelved_alarm_clear'    Should Contain     ${get_file}      alarm was cleared due to copy of running-config into startup-config
    ${result}     Run Keyword If    '${parameter}' == 'raise_alarm'     Should Contain     ${get_file}     Details:alarm was set due to configuration update
    ${result}     Run Keyword If    '${parameter}' == 'clear_alarm'     Should Contain     ${get_file}     Details:alarm was cleared due to copy of running-config into startup-config
   

Alarm_shelved_unshelved_message_recorded_on_syslog_Server
    [Arguments]    ${DUT}    ${device}    ${syslog_server_ip}     ${user_password}     ${instance-id}    ${shelved_time}=None     ${un_shelved_time}=None    ${user_interface}=cli
    [Documentation]         Alarm shelved and unshelved message is collected in syslog server
    [Tags]        @author=ssekar
  
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring location in DUT      ${DUT}      ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${device}
    Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}
    cli    ${device}     cd /var/log      timeout=120
    #cli    ${device}     sudo cat /var/log/messages    timeout_exception=0     retry=4    prompt=password     timeout=300
    #${get_file}       cli    ${device}      ${user_password}         timeout_exception=0     retry=3     prompt=gallantgriffins      timeout=150
    ${get_file}     OperatingSystem.Get File    /var/log/syslog/syslog.log
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${device}
    ${count1}    Get Line Count    ${get_file}
    ${result}       Run Keyword If    '${shelved_time}' != 'None'    Get Lines Containing String       ${get_file}     /exec/manual-shelve[instance-id='${instance-id}']
    ${syslog_shelved_time}       Run Keyword If    '${shelved_time}' != 'None'     Get Regexp Matches     ${result}        (\\d{2}:\\d{2}:\\d{2})    1
    ${syslog_shelved_time}      Run Keyword If    '${shelved_time}' != 'None'    Get From List    ${syslog_shelved_time}     0
    ${syslog_shelved_time}      Run Keyword If    '${shelved_time}' != 'None'    Convert Time     ${syslog_shelved_time}
    Run Keyword If    '${shelved_time}' != 'None'    Should Contain     ${get_file}        set clralarm ${instance-id}
    ${result}       Run Keyword If    '${un_shelved_time}' != 'None'    Get Lines Containing String       ${get_file}     /exec/manual-un-shelve[instance-id='${instance-id}']
    ${syslog_unshelved_time}      Run Keyword If    '${un_shelved_time}' != 'None'    Get Regexp Matches     ${result}        (\\d{2}:\\d{2}:\\d{2})    1
    ${syslog_unshelved_time}      Run Keyword If    '${un_shelved_time}' != 'None'    Get From List     ${syslog_unshelved_time}     0
    ${syslog_unshelved_time}      Run Keyword If    '${un_shelved_time}' != 'None'     Convert Time     ${syslog_unshelved_time}
    Run Keyword If    '${un_shelved_time}' != 'None'     Should Contain     ${get_file}        set un-clralarm ${instance-id}
    Run Keyword If    '${shelved_time}' != 'None'    Should Be True    ${shelved_time} >= ${syslog_shelved_time}
    Run Keyword If    '${un_shelved_time}' != 'None'    Should Be True    ${un_shelved_time} >= ${syslog_unshelved_time} 
    Run Keyword If    '${shelved_time}' != 'None'    Should Contain     ${get_file}                /exec/manual-shelve[instance-id='${instance-id}']
    Run Keyword If    '${un_shelved_time}' != 'None'    Should Contain     ${get_file}                /exec/manual-un-shelve[instance-id='${instance-id}']

Tcpdump_status
    [Arguments]    ${device}   ${device_ip}    ${user_password}    
    [Documentation]       Installing Tcpdump if not installed in Local PC
    [Tags]        @author=ssekar
    ${result}       cli    ${device}     sudo tcpdump
    cli    ${device}      ${user_password}      timeout_exception=0
    ${result}     Get Lines Containing String       ${result}        command not found  
    Run Keyword If   '${result}' == 'command not found'    Run Keywords     cli    ${device}     sudo yum install tcpdump      prompt=(\[y/N\]):    timeout_exception=0
    ...      AND      cli    ${device}     y       timeout_exception=0
    ...      AND      cli    ${device}     ${user_password}

SNMP_traps_captured_using_tcpdump
    [Arguments]    ${device}   ${device_ip}    ${user_password}
    [Documentation]       SNMP traps captured using tcpdump
    [Tags]        @author=ssekar
    cli        ${device}      sudo tcpdump -s 0 "(dst port 162) or (src port 161) or (dst port 161)" -nnvXSs 0 -w /home/ssekar/snmp.pcap    timeout_exception=0    timeout=30      prompt=Got 0
    cli     ${device}     ${user_password}     prompt=Got 0    timeout_exception=0
   # cli    ${device}      sudo tcpdump -s 0 "(dst port 162) or (src port 161) or (dst port 161)" -w /home/ssekar/file.pcap      timeout=30      timeout_exception=0    prompt=$
   # cli    ${device}      ${user_password}      timeout_exception=0

Alarm_shelved_unshelved_message_on_tcpdump
    [Arguments]    ${device}    ${device_ip}    ${user_password}      ${instance-id}=None    ${shelved_time}=None     ${alarm_clear_time}=None       ${un_shelved_time}=None
    [Documentation]         Alarm shelved and unshelved message is collected in tcpdump
    [Tags]        @author=ssekar
    # Sleep for 20s for the SNMP trap process
    BuiltIn.Sleep    20s
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${device} 
    cli    ${device}      cd /home/ssekar
    ${snmp}    cli    ${device}      sudo tcpdump -xtr snmp.pcap > textfile.txt      timeout_exception=0   
    cli    ${device}      ${user_password}      timeout_exception=0        prompt=reading from file snmp.pcap
    ${result}     Get File    /home/ssekar/textfile.txt
    ${snmp_trap_shelved_time}     Get Lines Containing String       ${result}       running-config-unsaved
    ${snmp_trap_shelved_time}     Get Regexp Matches     ${snmp_trap_shelved_time}    (\\d{2}:\\d{2}:\\d{2})    1
    ${snmp_trap_shelved_time}     Get From List      ${snmp_trap_shelved_time}    0
    ${snmp_trap_shelved_time}     Convert Time     ${snmp_trap_shelved_time}     
    Should Be True    ${shelved_time} >= ${snmp_trap_shelved_time}
    ${snmp_trap_alarm_clear_time}      Get Lines Containing String       ${result}       Configuration file was copied
    ${snmp_trap_alarm_clear_time}      Get Regexp Matches     ${snmp_trap_alarm_clear_time}     (\\d{2}:\\d{2}:\\d{2})    1
    ${snmp_trap_alarm_clear_time}      Get From List      ${snmp_trap_alarm_clear_time}     0
    ${snmp_trap_alarm_clear_time}       Convert Time     ${snmp_trap_alarm_clear_time}
    Should Be True    ${alarm_clear_time} >= ${snmp_trap_alarm_clear_time}
    
Get cleared alarm time
    [Arguments]    ${device}     ${alarm}      ${instance-id}
    [Documentation]        Get cleared alarm time
    [Tags]        @author=ssekar
    ${command}   Set Variable If     '${alarm}' == 'running_config_unsaved'      show alarm history subscope instance-id ${instance-id}
    ${result}       cli    ${device}      ${command}        timeout=90
    ${alarm_cleared_time}     Get Regexp Matches      ${result}       (\\d{2}:\\d{2}:\\d{2})    1
    ${alarm_cleared_time}     Get From List      ${alarm_cleared_time}     0
    ${alarm_cleared_time}     Convert Time    ${alarm_cleared_time}
    [Return]     ${alarm_cleared_time}  
 

Get DUT current time
    [Arguments]     ${device}
    [Documentation]         Get DUT current time
    [Tags]        @author=ssekar
    ${result}     cli    ${device}     show clock      timeout=90
    ${DUT_time}   Get Regexp Matches    ${result}      (\\d{2}:\\d{2}:\\d{2})    1
    ${DUT_time}   Get From List    ${DUT_time}    0
    ${DUT_time}    Convert Time    ${DUT_time}
    [Return]    ${DUT_time} 

Get DUT current time using netconf
    [Arguments]     ${device}     
    [Documentation]         Get DUT current time
    [Tags]        @author=ssekar
    ${result}=     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/clock"/></get></rpc>]]>]]>
    ${str}      Convert to string     ${result}
    ${DUT_time}   Get Regexp Matches    ${str}      (\\d{2}:\\d{2}:\\d{2})    1
    ${DUT_time}   Get From List    ${DUT_time}    0
    ${DUT_time}    Convert Time    ${DUT_time}
    [Return]    ${DUT_time} 

Verify Alarms Get Acknowledged
    [Arguments]    ${device}    ${parameter}=None    ${command_execution}=None
    [Documentation]    Alarms Get Acknowledged
    [Tags]        @author=ssekar

    ${command}   Set Variable If     '${command_execution}' == 'shelved_ntp_prov'    show alarm active subscope name ntp-prov    show alarm active subscope name running-config-unsaved

    Wait Until Keyword Succeeds      2 min     10 sec         Disconnect     ${device}
    Log    *** Getting instance-id from triggered active alarm ***    
    ${result}    Wait Until Keyword Succeeds      3 min     10 sec       cli    ${device}    ${command}      timeout=90       prompt=\\#
    @{result}    Get Regexp Matches    ${result}    instance-id ([0-9.]+)    1
    ${instance1}    Get From List    ${result}    0
    Log    *** Manually acknowledging alarm based on instance-id and verifying it ***
    cli    ${device}    manual acknowledge instance-id ${instance1}    timeout=90
    ${result}    cli    ${device}    show alarm acknowledged      timeout=90
    Result Should Contain    instance-id    ${instance1}
    Result Should Contain    manual-acknowledge    TRUE
    Run Keyword If   '${parameter}' == 'description'    Acknowledging_and_Shelving_alarm_description  ${result}
    Run Keyword If   '${parameter}' == 'name'    Acknowledging_and_Shelving_alarm_name    ${result}
    Run Keyword If   '${parameter}' == 'alarm_type'    Acknowledging_and_Shelving_alarm_type     ${result}
    Run Keyword If    '${parameter}' == 'probable_cause' and '${command_execution}' == 'shelved_ntp_prov'    Should Contain    ${result}     probable-cause             "NTP is not provisioned"
    Run Keyword If   '${parameter}' == 'repair_action'   Acknowledging_and_Shelving_alarm_repair_action    ${result}
    Run Keyword If   '${parameter}' == 'severity'     Acknowledging_and_Shelving_alarm_severity    ${result}
    Run Keyword If   '${parameter}' == 'category'     Should Contain      ${result}      category                   CONFIGURATION
    Run Keyword If   '${parameter}' == 'service_impact'     Should Contain      ${result}      service-impacting          TRUE
    Run Keyword If   '${parameter}' == 'service_affect'     Should Contain      ${result}      service-affecting          TRUE
    Run Keyword If   '${parameter}' == 'instance-id'          Should Contain    ${result}    instance-id                ${instance1}
    Run Keyword If   '${parameter}' == 'address'          Should Contain    ${result}      address                    /config/system
    [Return]     ${instance1}

Getting Alarm or event time from DUT
    [Arguments]    ${device}    ${instance-id}
    [Documentation]    Getting Alarm or event time from DUT
    [Tags]        @author=ssekar

    ${result}     cli     ${device}        show alarm history subscope instance-id ${instance-id}        timeout=120     
    ${raise_time}     Get Lines Containing String     ${result}     ne-event-time
    @{raise_time}     Get Regexp Matches    ${raise_time}      ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    #${raise_time}     Convert To String     ${raise_time}
    Log    ${raise_time}
    [Return]     ${raise_time}

Verify Alarms Get Acknowledged using netconf
    [Arguments]    ${device}    ${parameter}=None    ${alarm}=None
    [Documentation]    Alarms Get Acknowledged
    [Tags]        @author=ssekar

    ${command}   Set Variable If     '${alarm}' == 'ack_alarm_application_suspended'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1702</id></show-alarm-instances-active-subscope></rpc>]]>]]>         <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>702</id></show-alarm-instances-active-subscope></rpc>]]>]]>

    Log    *** Getting instance-id from triggered active alarm ***
    ${show_alarm}=    Netconf Raw    n1_netconf    xml=${command}
    Run Keyword If    '${alarm}' != 'ack_alarm_application_suspended'    Should contain    ${show_alarm.xml}    702
    Run Keyword If    '${alarm}' == 'ack_alarm_application_suspended'    Should contain    ${show_alarm.xml}    1702
    ${str}=    Convert to string    ${show_alarm}
    ${instanceid}=    Get Lines Containing String    ${str}    instance-id
    ${first}=    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0
    Log    *** Manually acknowledging alarm based on instance-id ***
    ${manual_acknowledge} =    XML.Parse XML    <manual-acknowledge xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></manual-acknowledge>
    XML.Element To String    ${manual_acknowledge}
    ${alarm_ack} =    Netconf dispatch    n1_netconf    ${manual_acknowledge}
    Should Be True    ${alarm_ack.ok}
    ${manual_ack} =    Netconf Raw    n1_netconf    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/acknowledged"/></get></rpc>]]>]]>
    Should contain    ${manual_ack.xml}    <manual-acknowledge>TRUE
    Run Keyword If   '${parameter}' == 'severity'      Should Contain     ${manual_ack.xml}           <perceived-severity>INFO</perceived-severity>
    Run Keyword If   '${parameter}' == 'name'     Should Contain     ${manual_ack.xml}           <name>running-config-unsaved</name>
    Run Keyword If    '${parameter}' == 'description'      Should Contain     ${manual_ack.xml}     <description>Configuration data has changes that have not been saved to the startup-config.  Rebooting the system without saving, will result in the unsaved changes being lost</description>
    Run Keyword If    '${parameter}' == 'alarm_type'      Should Contain     ${manual_ack.xml}     <alarm-type>PROCESSING-ERROR</alarm-type>
    Run Keyword If    '${parameter}' == 'probable_cause'      Should Contain     ${manual_ack.xml}           <probable-cause>Application crashed or locked up more than three times in 5 minutes</probable-cause>
    Run Keyword If    '${parameter}' == 'repair_action'      Should Contain     ${manual_ack.xml}           <repair-action>copy running-configuration to startup-configuration</repair-action>
    Run Keyword If    '${parameter}' == 'category'     Should Contain     ${manual_ack.xml}       <category>CONFIGURATION</category>
    Run Keyword If    '${parameter}' == 'instance-id'    Should Contain     ${manual_ack.xml}       <instance-id>${instance_id}</instance-id>
    Run Keyword If    '${parameter}' == 'service_impact'    Should Contain     ${manual_ack.xml}      <service-impacting>TRUE</service-impacting>
    Run Keyword If    '${parameter}' == 'service_affect'    Should Contain     ${manual_ack.xml}      <service-affecting>TRUE</service-affecting>
    Run Keyword If    '${parameter}' == 'address'    Should Contain     ${manual_ack.xml}      <address>/config/system</address>

Verify Alarm definitions get paginated
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Alarm definitions get paginated
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm definitions    timeout=120    prompt=--More--
    Result Should Not Contain    alarm ${total_count}
    cli    ${device}    paginate true      timeout=120
    ${result}    cli    ${device}    show alarm definitions    timeout=120    prompt=--More--
    Result Should Not Contain    alarm ${total_count}

Verify Alarm definitions does not get paginated
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Alarm definitions doesnot get paginated
    [Tags]        @author=ssekar
    cli    ${device}    paginate false      timeout=120
    ${result}    cli    ${device}    show alarm definitions    timeout=120           prompt=${prompt}
    Result Should Contain    alarm ${total_count}
    Result Should Not Contain    --More--
    Log    *** Resetting paginate to true by default ***
    cli    ${device}    paginate true      timeout=120

Getting Event definition total count
    [Arguments]    ${device}
    [Documentation]    Getting value for Event definition total count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show event definitions | include total-count    timeout=30
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    [Return]    ${total_count}

Getting Event definition total count using netconf
    [Arguments]    ${device}
    [Documentation]    Getting value for Event definition total count
    [Tags]        @author=ssekar
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/instances/event/definitions"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    [Return]    ${total_count}

Getting Active alarms total count
    [Arguments]    ${device}
    [Documentation]    Getting value for Active alarms total count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm active | include total-count    timeout=30
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Getting Active alarms total count using netconf
    [Arguments]    ${device}
    [Documentation]    Getting value for Active alarms total count using netconf
    [Tags]        @author=ssekar
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/active"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Getting Archived Alarm total count
    [Arguments]    ${device}
    [Documentation]    Getting Archived Alarm total count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm archive | include total-count      timeout=120
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Getting Archived Alarm total count using netconf
    [Arguments]    ${device}
    [Documentation]    Getting Archived Alarm total count
    [Tags]        @author=ssekar
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/archive"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Getting Alarm history total count
    [Arguments]    ${device}
    [Documentation]    Getting value for Alarm history total count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history detail | include total-count    timeout=120
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Getting Alarm history total count using netconf
    [Arguments]    ${device}
    [Documentation]    Getting value for Alarm history total count
    [Tags]        @author=ssekar
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/history"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Getting Active events total count
    [Arguments]    ${device}
    [Documentation]    Getting Active events total count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show event | include total-count    timeout=30
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    [Return]    ${total_count}

Getting Active events total count using netconf
    [Arguments]    ${device}
    [Documentation]    Getting Active events total count using netconf
    [Tags]       @author=ssekar
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/event"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    [Return]    ${total_count}

Verify Events are displayed as per count
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Events displayed as per count
    [Tags]        @author=ssekar
    ${total_count}    Set Variable If    ${total_count} >= 400    400    ${total_count}
    ${result}    cli    ${device}    show event subscope count ${total_count}    timeout=30
    Result Should Contain    total-count ${total_count}
    Result Should Contain    index ${total_count}
    ${tot_chk}    Evaluate    ($total_count >= 2 )
    ${tty}    Evaluate    ($tot_chk == True)
    ${end}    Set Variable If    ${tty} == True    2
    ${to_count}=    Evaluate    ${total_count}-1
    : FOR    ${INDEX}    IN RANGE    1    ${end}+1
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${to_count})    modules=random
    \    cli    ${device}    show event subscope count ${start}    timeout=30
    \    Result Should Contain    total-count ${start}
    ${result}    cli    ${device}    show event subscope count 0
    Result Should Contain    total-count 0

Verify Events are displayed as per count using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Events displayed as per count using netconf
    [Tags]    @author=ssekar
    ${total_count}    Set Variable If    ${total_count} >= 400    400    ${total_count}
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-event-instances-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should contain    ${result.xml}     <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    Should contain    ${result.xml}     <index>${total_count}</index>
    ${to_count}=    Evaluate    ${total_count}-1
    : FOR    ${INDEX}    IN RANGE    1    3
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${to_count})    modules=random
    \    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${start}</count></show-event-instances-subscope></rpc>]]>]]>
    \    Should contain    ${result.xml}     <total-count xmlns='http://www.calix.com/ns/exa/base'>${start}</total-count>
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-subscope xmlns="http://www.calix.com/ns/exa/base"><count>0</count></show-event-instances-subscope></rpc>]]>]]>
    Should contain    ${result.xml}     <total-count xmlns='http://www.calix.com/ns/exa/base'>0</total-count>


Verify Event definition displayed as per count
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Event definition displayed as per count
    [Tags]        @author=ssekar
    ${result}    command    ${device}    show event definitions subscope count ${total_count}        timeout=120      prompt=index ${total_count}
    Result Should Contain    total-count ${total_count}
    ${t_count}    Evaluate      ${total_count}-1
    Result Should Contain    index ${t_count}
    ${to_count}=    Evaluate    ${total_count}/2
    : FOR    ${INDEX}    IN RANGE    1    ${to_count}
    \    Log    ${INDEX}
    \    command    ${device}    show event definitions subscope count ${INDEX}        timeout=120      timeout_exception=0
    \    Result Should Contain    total-count ${INDEX}

Verify Event definition displayed as per count using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Event definition displayed as per count
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-event-definitions-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    Should contain    ${result.xml}    <index>${total_count}</index>
    : FOR    ${INDEX}    IN RANGE    1    ${total_count}
    \    Log    ${INDEX}
    \    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${INDEX}</count></show-event-definitions-subscope></rpc>]]>]]>
    \    Should contain    ${result.xml}     <total-count xmlns='http://www.calix.com/ns/exa/base'>${INDEX}</total-count>



Verify Active alarms filter by range
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Active alarms filter by range
    [Tags]        @author=ssekar
    ${start_value}    Set Variable    1
    ${result}    cli    ${device}    show alarm active range start-value ${start_value} end-value ${total_count}    timeout=130
    Result Should Contain    total-count ${total_count}
    Result Should Contain    index ${total_count}
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    cli    ${device}    show alarm active range start-value ${start} end-value ${end}    timeout=130
    ${count}=    Evaluate    ${end}-${start}+1
    Result Should Contain    total-count ${count}

Verify Active alarms filter by range using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Active alarms filter by range using netconf
    [Tags]        @author=ssekar
    ${start_value}    Set Variable    1
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-range xmlns="http://www.calix.com/ns/exa/base"><start-value>${start_value}</start-value><end-value>${total_count}</end-value></show-alarm-instances-active-range></rpc>]]>]]>
    Should contain     ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    Should contain     ${result.xml}      <index>${total_count}</index>
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-range xmlns="http://www.calix.com/ns/exa/base"><start-value>${start}</start-value><end-value>${end}</end-value></show-alarm-instances-active-range></rpc>]]>]]>
    ${count}=    Evaluate    ${end}-${start}+1
    Should contain     ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>${count}</total-count>


Verify events filter by range
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Events filter by range
    [Tags]        @author=ssekar
    ${start_value}    Set Variable    1
    ${total_count}    Set Variable If    ${total_count} >= 400    400    ${total_count}
    ${result}    cli    ${device}    show event range start-value ${start_value} end-value ${total_count}    timeout=130
    Result Should Contain    total-count ${total_count}
    Result Should Contain    index ${total_count}
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    cli    ${device}    show event range start-value ${start} end-value ${end}    timeout=130
    ${count}=    Evaluate    ${end}-${start}+1
    Result Should Contain    total-count ${count}

Verify events filter by range using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Events filter by range using netconf
    [Tags]      @author=ssekar
    ${start_value}    Set Variable    1
    ${total_count}    Set Variable If    ${total_count} >= 400    400    ${total_count}
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-range xmlns="http://www.calix.com/ns/exa/base"><start-value>${start_value}</start-value><end-value>${total_count}</end-value></show-event-instances-range></rpc>]]>]]>
    Should Contain    ${result.xml}     <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    Should Contain    ${result.xml}     <index>${total_count}</index>
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-range xmlns="http://www.calix.com/ns/exa/base"><start-value>${start}</start-value><end-value>${end}</end-value></show-event-instances-range></rpc>]]>]]>
    ${count}=    Evaluate    ${end}-${start}+1
    Should Contain    ${result.xml}     <total-count xmlns='http://www.calix.com/ns/exa/base'>${count}</total-count>


Trigerring event
    [Arguments]    ${device}
    [Documentation]    Triggering event
    [Tags]        @author=ssekar
    cli    ${device}    clear active event-log       timeout=120
    ${result}    cli    ${device}    show event filter id 705       timeout=120
    Result Should Contain    total-count 0
    cli    ${device}    configure         timeout=120
    : FOR    ${INDEX}    IN RANGE    1    3
    \    Log    ${INDEX}
    \    cli    ${device}    no contact       timeout=120
    \    cli    ${device}    contact ttyz     timeout=120
    cli    ${device}    end       timeout=50

Locking and Unlocking the config
    [Arguments]      ${device}       ${lock}=False
    [Documentation]      Locking and Unlocking the configuration
    [Tags]        @author=ssekar

    Run Keyword If     '${lock}' == 'True'      cli    ${device}      lock datastore running
    Run Keyword If     '${lock}' == 'False'     cli    ${device}      unlock datastore running

Locking and Unlocking the config using netconf
    [Arguments]      ${device}       ${lock}=False
    [Documentation]      Locking and Unlocking the configuration
    [Tags]        @author=ssekar

    Run Keyword If     '${lock}' == 'True'      Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="UTF-8"?><rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><lock><target><running/></target></lock></rpc>]]>]]>
    Run Keyword If     '${lock}' == 'False'     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="UTF-8"?><rpc message-id="110" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><unlock><target><running/></target></unlock></rpc>]]>]]>

Getting latest instance-id for event
    [Arguments]    ${device}      ${ins}=none
    [Documentation]    Getting latest instance-id for event
    [Tags]        @author=ssekar
 
    ${result}       cli    ${device}     show event      timeout=120
    ${instance-id}     Get Lines Containing String    ${result}      instance-id
    @{instance-id}     Get Regexp Matches    ${instance-id}       instance-id ([0-9.]+)     1
    ${instance_id}    Run Keyword If    '${ins}' == 'none'    Get From List      ${instance-id}     0
    ...     ELSE IF      '${ins}' == 'logout'     Get From List      ${instance-id}     1
    [Return]      ${instance_id}

Getting latest instance-id for event using netconf
    [Arguments]    ${device}      ${ins}=none
    [Documentation]    Getting latest instance-id for event using netconf
    [Tags]        @author=ssekar

    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/event"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    @{instance-id}     Get Regexp Matches    ${str}      <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Run Keyword If    '${ins}' == 'none'    Get From List      ${instance-id}     0
    ...     ELSE IF      '${ins}' == 'logout'     Get From List      ${instance-id}     1
    [Return]      ${instance_id}

Verifying older events are dropped down to add new events using netconf
    [Arguments]    ${device}     
    [Documentation]      Verifying older events are dropped down to add new events using netconf
    [Tags]        @author=ssekar

    Log      *** Locking the running configuration ***
    #Wait Until Keyword Succeeds    30 sec     10 sec        Locking and Unlocking the config using netconf        ${device}       lock=True

    Log       *** Configuring system contact info ***
    Wait Until Keyword Succeeds      2 min     10 sec       Triggering any one alarm for severity INFO       ${device}      user_interface=netconf

    Log         *** Clearing Active events ***
    Wait Until Keyword Succeeds      2 min     10 sec       Clearing active events using netconf        ${device}

    @{append}    Create List   
    ${first_instance_id}     Getting latest instance-id for event using netconf       ${device}
    Append To List     ${append}       ${first_instance_id}
    ${result}    Netconf Raw      ${device}      xml=<rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><close-session/></rpc>]]>]]>
    Should Contain      ${result.xml}      <ok/>
    #sleep for 10s
    Sleep    10s
    ${second_instance_id}     Getting latest instance-id for event using netconf       ${device}        logout
    ${third_instance_id}     Getting latest instance-id for event using netconf        ${device}

    Append To List     ${append}       ${second_instance_id}
    Append To List     ${append}       ${third_instance_id}

    : FOR    ${INDEX}    IN RANGE    1    15
    \    Log    ${INDEX}
    \    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact></contact></system></config></config></edit-config></rpc>]]>]]>
    #sleep for 6s
    \    Sleep    6s
    \    ${ins-id}     Getting latest instance-id for event using netconf        ${device}
    \    Append To List     ${append}      ${ins-id}
    \    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact>ttyz</contact></system></config></config></edit-config></rpc>]]>]]>
    #sleep for 6s
    \    Sleep    6s
    \    ${ins-id}     Getting latest instance-id for event using netconf        ${device}
    \    Append To List     ${append}      ${ins-id}

    Log    ${append}
    ${len}     Get Length    ${append}

    ${total_count}      Getting Active events total count using netconf       ${device}
    : FOR    ${INDEX}    IN RANGE    0    10
    \    ${result}      Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-log xmlns="http://www.calix.com/ns/exa/base"><start-value>${total_count}</start-value><end-value>${total_count}</end-value></show-event-instances-log></rpc>]]>]]>
    \    ${str}      Convert to string     ${result}
    \    ${id}     Get From List      ${append}     ${INDEX}
    \    @{ins_id}      Get Regexp Matches    ${str}      <instance-id>([0-9.]+)</instance-id>     1
    \    ${ins_id}      Get From List     ${ins_id}     0
    \    Should Be True      ${id} >= ${ins_id}
    \    ${total_count}    Evaluate    ${total_count} - 1

    Log      *** Unlocking the running configuration ***
    #Wait Until Keyword Succeeds    30 sec     10 sec        Locking and Unlocking the config using netconf       ${device}       lock=False

Verifying older events are dropped down to add new events
    [Arguments]    ${device}
    [Documentation]        Verifying older events are dropped down to add new events
    [Tags]        @author=ssekar

    Log      *** Locking the running configuration ***
    #Wait Until Keyword Succeeds    30 sec     10 sec        Locking and Unlocking the config        ${device}       lock=True

    Log       *** Configuring system contact info ***
    Wait Until Keyword Succeeds      2 min     10 sec       Triggering any one alarm for severity INFO       ${device}      user_interface=cli

    Log         *** Clearing Active events ***
    Wait Until Keyword Succeeds      2 min     10 sec       Clearing active events       ${device}

    @{append}    Create List
    ${first_instance_id}     Getting latest instance-id for event        ${device}
    Append To List     ${append}       ${first_instance_id}
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${device}
    # Sleep for 5 secs for connection to come UP
    Sleep    5s
    ${second_instance_id}     Getting latest instance-id for event        ${device}     logout
    ${third_instance_id}     Getting latest instance-id for event        ${device}
    Append To List     ${append}       ${second_instance_id}
    Append To List     ${append}       ${third_instance_id}
    #${total_count}    Getting Active events total count      ${device}
    
    : FOR    ${INDEX}    IN RANGE    1    15
    \    Log    ${INDEX}
    \    cli    ${device}    configure       timeout=120
    \    cli    ${device}    no contact      timeout=120
    \    cli    ${device}    end      timeout=120
    \    ${ins-id}     Getting latest instance-id for event        ${device}
    \    Append To List     ${append}      ${ins-id}
    \    cli    ${device}    configure       timeout=120
    \    cli    ${device}    contact ttyz     timeout=120
    \    cli    ${device}    end      timeout=120
    \    ${ins-id}     Getting latest instance-id for event        ${device}
    \    Append To List     ${append}      ${ins-id}
    #sleep for 10s
    Sleep     10s    
    
    Log    ${append}
    ${len}     Get Length    ${append}

    ${total_count}    Getting Active events total count      ${device}
    : FOR    ${INDEX}    IN RANGE    0    10
    \    ${result}      cli    ${device}       show event log start-value ${total_count} end-value ${total_count}     timeout=120
    \    ${id}     Get From List      ${append}     ${INDEX}
    \    @{ins_id}      Get Regexp Matches    ${result}      instance-id ([0-9.]+)     1
    \    ${ins_id}      Get From List     ${ins_id}     0
    \    Should Be True      ${id} >= ${ins_id}
    \    ${total_count}    Evaluate    ${total_count} - 1
  
    Log      *** Unlocking the running configuration ***
    #Wait Until Keyword Succeeds    30 sec     10 sec        Locking and Unlocking the config        ${device}       lock=False

Trigerring multiple events using dcli
    [Arguments]    ${device}     ${linux}
    [Documentation]    Trigerring multiple events using dcli
    [Tags]    @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux} 
    # Sleep for 5 secs for connection to come UP
    Sleep    5s
    : FOR    ${INDEX}    IN RANGE    1    510
    \    Log    ${INDEX}
    \    Wait Until Keyword Succeeds      2 min     10 sec     cli    ${linux}     dcli evtmgrd evtpost user-login INFO         timeout=120
    \    Wait Until Keyword Succeeds      2 min     10 sec     cli    ${linux}     dcli evtmgrd evtpost user-logout INFO         timeout=120
    ${result}      cli     ${device}     show event | include total       timeout=300
    ${count}    Get Regexp Matches    ${result}    total-count ([0-9]+)       1
    ${count}    Get From List     ${count}     0
    Log      ${count}
    Should Be True     ${count} > 500

Clearing active events using netconf
    [Arguments]    ${device}
    [Documentation]    Clearing active events using netconf
    [Tags]    @author=ssekar

    ${result}     Netconf Raw    ${device}    xml=<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><active-event-log xmlns="http://www.calix.com/ns/exa/base"/></rpc>]]>]]>
    Should Contain      ${result.xml}       <ok/>

Clearing and Trigerring event using netconf
    [Arguments]    ${device}
    [Documentation]    Clearing and Trigerring event using netconf
    [Tags]    @author=ssekar
    Netconf Raw    ${device}    xml=<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><active-event-log xmlns="http://www.calix.com/ns/exa/base"/></rpc>]]>]]>
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-filter xmlns="http://www.calix.com/ns/exa/base"><id>705</id></show-event-instances-filter></rpc>]]>]]>
    Should Contain      ${result.xml}     <total-count xmlns='http://www.calix.com/ns/exa/base'>0</total-count>
    : FOR    ${INDEX}    IN RANGE    1    3
    \    Log    ${INDEX}
    \    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact></contact></system></config></config></edit-config></rpc>]]>]]>
    \    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact>Ero34</contact></system></config></config></edit-config></rpc>]]>]]>

Triggering_event_for_user_login_logout_netconf
    [Arguments]    ${device}    
    [Documentation]    Triggering event for user login and logout
    [Tags]    @author=ssekar
    Netconf Raw    ${device}    xml=<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><active-event-log xmlns="http://www.calix.com/ns/exa/base"/></rpc>]]>]]>
    Netconf Raw    ${device}    xml=<rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><close-session/></rpc>]]>]]>
    # Sleep for 5 secs for connection to come UP
    Sleep    5s
    ${total_count}    Getting Active events total count using netconf      ${device}

Events_filter_by_source_using_netconf
    [Arguments]    ${device}      ${netconf_username}
    [Documentation]    Verify Events can be filtered by source
    [Tags]    @author=ssekar
    ${result}    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-address xmlns="http://www.calix.com/ns/exa/base"><key>name</key><value>${netconf_username}</value></show-event-instances-address></rpc>]]>]]>
    Should Contain      ${result.xml}     <address>/config/system/aaa/user[name='${netconf_username}']</address>
    Should Contain      ${result.xml}     <name>user-logout</name>
    Should Contain      ${result.xml}     <name>user-login</name>

Triggering_event_for_user_login_logout
    [Arguments]    ${device}
    [Documentation]    Triggering event for user login and logout
    [Tags]    @author=ssekar
    cli     ${device}      clear active event-log        timeout=60        prompt=\\#       timeout_exception=0
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${device}
    # Sleep for 5 secs for connection to come UP
    Sleep    5s
    ${total_count}    Getting Active events total count      ${device}

Clearing active events
    [Arguments]    ${device}
    [Documentation]    Clearing active events
    [Tags]    @author=ssekar
    cli     ${device}      clear active event-log        timeout=60      prompt=\\#      timeout_exception=0

Events_filter_by_source
    [Arguments]    ${device}      ${cli_username}
    [Documentation]    Verify Events can be filtered by source
    [Tags]    @author=ssekar
    ${result}    cli     ${device}      show event address key name value ${cli_username}       timeout=60
    Should Contain      ${result}      name user-login
    Should Contain      ${result}      name user-logout
    Should Contain      ${result}      address /config/system/aaa/user[name='${cli_username}']
    
Verifying event definition filter by id
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying event definition filter by id
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show event definitions subscope count ${total_count} | include id | exclude "id 0" | exclude name | exclude details | exclude probable-cause | exclude additional-text | exclude description | exclude repair-action | exclude address | exclude session-id    timeout=120
    @{match}    GetRegexp Matches    ${result}    id ([0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    1    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show event definitions subscope id ${list}    timeout=120
    \    Result Should Contain    id ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    id ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying event definition filter by id using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying event definition filter by id
    [Tags]        @author=ssekar
    ${result}     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-event-definitions-subscope></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    @{match}    GetRegexp Matches    ${str}      <id>([0-9]+)</id>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><id>${list}</id></show-event-definitions-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}      <id>${list}</id>
    \    ${str1}=    Convert to string    ${result}
    \    @{res1}    Get Regexp Matches    ${str1}      <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>      1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    @{match1}    GetRegexp Matches    ${str1}      <id>([0-9]+)</id>     1
    \    ${len1}    Get Length    ${match1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${len1}

Verifying event definition filter by name
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying event definition filter by name
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show event definitions subscope count ${total_count} | include name | exclude details | exclude probable-cause | exclude additional-text | exclude description | exclude repair-action | exclude address    timeout=120
    @{match}    GetRegexp Matches    ${result}    name ([a-zA-Z0-9\-\_]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show event definitions subscope name ${list}    timeout=120
    \    Result Should Contain    name ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    name ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying event definition filter by name using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying event definition filter by name
    [Tags]        @author=ssekar
    ${result}     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-event-definitions-subscope></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    @{match}    GetRegexp Matches    ${str}      <name>([a-zA-Z0-9\-\_]+)</name>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><name>${list}</name></show-event-definitions-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}      <name>${list}</name>
    \    ${str1}=    Convert to string    ${result}
    \    @{res1}    Get Regexp Matches    ${str1}      <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>      1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    @{match1}    GetRegexp Matches    ${str1}      <name>([a-zA-Z0-9\-\_]+)</name>     1
    \    ${len1}    Get Length    ${match1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${len1}

Verifying event definition filter by category
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying event definition filter by category
    [Tags]        @author=ssekar
    ${hostname}   Wait Until Keyword Succeeds    30 seconds    5 seconds         Getting hostname     ${device} 
    ${result}    cli    ${device}    show event definitions subscope count ${total_count} | include category      timeout=120
    @{match}    GetRegexp Matches    ${result}    category ([A-Z0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show event definitions subscope category ${list}    timeout=120     prompt=${hostname}#     timeout_exception=0
    \    Result Should Contain    category ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    category ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying event definition filter by category using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying event definition filter by category
    [Tags]        @author=ssekar
    ${result}     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-event-definitions-subscope></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    @{match}    GetRegexp Matches    ${str}      <category>([A-Z0-9]+)</category>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${list}</category></show-event-definitions-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}      <category>${list}</category>
    \    ${str1}=    Convert to string    ${result}
    \    @{res1}    Get Regexp Matches    ${str1}      <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>      1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    @{match1}    GetRegexp Matches    ${str1}      <category>([A-Z0-9]+)</category>      1
    \    ${len1}    Get Length    ${match1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${len1} 

Verifying event definition filter by address
    [Arguments]    ${device}
    [Documentation]    Verifying event definition filter by address
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show event definitions subscope count ${total_count} | include address      timeout=120
    @{match}    GetRegexp Matches    ${result}    (address.*)     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    1    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${match1}    GetRegexp Matches    ${list}      address.*\\[([a-zA-Z0-9\-\_]+)\\=([\'a-zA-Z0-9\-\_\\\(\)]+|\'\')\\]    1    2
    \    ${tuple}   Run Keyword If     ${match1} != [ ]    Get From List    ${match1}    0
    \    @{list1}   Run Keyword If     ${match1} != [ ]    Convert To List    ${tuple}
    \    ${key}   Run Keyword If     ${match1} != [ ]    Get From List    ${list1}    0
    \    ${value}    Run Keyword If     ${match1} != [ ]     Get From List     ${list1}    1
    \    ${value1}     Run Keyword If     ${match1} != [ ] and ${value} != ''    Remove String    ${value}   '
    \    ${command}     Run Keyword If     ${match1} != [ ] and ${value} == ''     Set Variable     show event definitions address key ${key}
    \    ...   ELSE IF      ${match1} != [ ] and ${value} != ''      Set Variable     show event definitions address key ${key} value ${value1}
    \    ${result}     Run Keyword If     ${match1} != [ ]    cli    ${device}     ${command}       timeout=120
    \    Run Keyword If     ${match1} != [ ]    Run Keyword And Continue On Failure     Should Contain      ${result}     [${key}=
    \    Run Keyword If     ${match1} != [ ]    Run Keyword And Continue On Failure     Should Not Contain      ${result}     total-count 0

Verifying event definition filter by address using netconf
    [Arguments]    ${device}
    [Documentation]    Verifying event definition filter by address
    [Tags]        @author=ssekar
    ${result}     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-event-definitions-subscope></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    @{match}    GetRegexp Matches    ${str}        (<address>.*</address>)      1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${match1}    GetRegexp Matches    ${list}      <address>.*\\[([a-zA-Z0-9\-\_]+)\\=([\'a-zA-Z0-9\-\_\\\(\)]+|\'\')\\]</address>     1    2
    \    ${tuple}   Run Keyword If     ${match1} != [ ]    Get From List    ${match1}    0
    \    @{list1}   Run Keyword If     ${match1} != [ ]    Convert To List    ${tuple}
    \    ${key}   Run Keyword If     ${match1} != [ ]    Get From List    ${list1}    0
    \    ${value}    Run Keyword If     ${match1} != [ ]     Get From List     ${list1}    1
    \    ${value1}     Run Keyword If     ${match1} != [ ] and ${value} != ''    Remove String    ${value}   '
    \    ${command}     Run Keyword If     ${match1} != [ ] and ${value} == ''     Set Variable     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-address xmlns="http://www.calix.com/ns/exa/base"><key>${key}</key></show-event-definitions-address></rpc>]]>]]>
    \    ...   ELSE IF      ${match1} != [ ] and ${value} != ''      Set Variable     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-definitions-address xmlns="http://www.calix.com/ns/exa/base"><key>${key}</key><value>${value1}</value></show-event-definitions-address></rpc>]]>]]>
    \    ${result}     Run Keyword If     ${match1} != [ ]    Netconf Raw      ${device}      xml=${command}
    \    Run Keyword If     ${match1} != [ ]    Run Keyword And Continue On Failure     Should Contain      ${result.xml}    [${key}=
    \    Run Keyword If     ${match1} != [ ]    Run Keyword And Continue On Failure     Should Not Contain      ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>0</total-count>

Verifying event filter list
    [Arguments]    ${device}
    [Documentation]    Verifying event filter list
    [Tags]        @author=ssekar
    Log    *** Verifying event filter by id ***
    ${result}    cli    ${device}    show event filter id 705    timeout=90
    Result Should Contain    address /config/system/contact
    Result Should Contain    id 705
    ${line}    Get Lines Containing String    ${result}    id 705
    ${count}    Get Line Count    ${line}
    ${count}=    Evaluate    ${count}-1
    @{res}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${res}    0
    ${total_count}    Convert To Integer    ${total_count}
    ${equal}    Should Be Equal    ${total_count}    ${count}
    Log    *** Verifying event filter by instance-id ***
    ${instance}    cli    ${device}    show event filter id 705 | include instance-id | linnum | until 1:     timeout=90
    @{instance}    Get Regexp Matches    ${instance}    instance-id ([0-9.]+)    1
    ${instance1}    Get From List    ${instance}    0
    ${result}    cli    ${device}    show event filter instance-id ${instance1}    timeout=90
    Result Should Contain    instance-id ${instance1}
    Result Should Contain    address /config/system/contact
    Result Should Contain    id 705
    @{time}    Get Regexp Matches    ${result}    ne-event-time ([0-9A-Z:+\-]+)    1
    ${time}    Get From List    ${time}    0
    Log    *** Verifying event filter by name ***
    ${result}    cli    ${device}    show event filter name db-change      timeout=90
    Result Should Contain    address /config/system/contact
    Result Should Contain    id 705
    Result Should Contain    name db-change
    ${line1}    Get Lines Containing String    ${result}    name db-change
    ${count1}    Get Line Count    ${line1}
    ${count1}=    Evaluate    ${count1}-1
    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count1}    Get From List    ${res1}    0
    ${total_count1}    Convert To Integer    ${total_count1}
    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    Log    *** Verifying event filter by time ***
    ${result}    cli    ${device}    show event filter time ${time}     timeout=90
    Result Should Contain    id 705
    Result Should Contain    address /config/system/contact
    Result Should Contain    ne-event-time ${time}

Verifying event filter list using netconf
    [Arguments]    ${device}
    [Documentation]    Verifying event filter list
    [Tags]        @author=ssekar
    Log    *** Verifying event filter by id ***
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-filter xmlns="http://www.calix.com/ns/exa/base"><id>705</id></show-event-instances-filter></rpc>]]>]]>
    Should Contain    ${result.xml}    <id>705</id>
    Should Contain    ${result.xml}    <description>Database entity change</description>
    ${str}      Convert to string     ${result}
    ${first}=    Get Regexp Matches    ${str}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0
    ${event_time}     Get Regexp Matches    ${str}      <ne-event-time>([0-9A-Z:\-]+)</ne-event-time>    1
    ${event_time}    Get From List    ${event_time}     0
    Log    *** Verifying event filter by instance-id ***
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-filter xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-event-instances-filter></rpc>]]>]]>
    Should Contain    ${result.xml}    <instance-id>${instance_id}</instance-id>
    Should Contain    ${result.xml}    <id>705</id>
    Log    *** Verifying event filter by time ***
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-filter xmlns="http://www.calix.com/ns/exa/base"><time>${event_time}</time></show-event-instances-filter></rpc>]]>]]>
    Should Contain    ${result.xml}    <ne-event-time>${event_time}</ne-event-time>
    Should Contain    ${result.xml}    <id>705</id>
    Log    *** Verifying event filter by name ***
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-event-instances-filter xmlns="http://www.calix.com/ns/exa/base"><name>db-change</name></show-event-instances-filter></rpc>]]>]]>
    Should Contain    ${result.xml}    <name>db-change</name>
    Should Contain    ${result.xml}    <id>705</id>
     
Getting Alarm definition total count
    [Arguments]    ${device}
    [Documentation]    Getting value for Alarm definition total count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm definitions | include total-count    timeout=120
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    [Return]    ${total_count}

Getting Alarm definition total count using netconf
    [Arguments]    ${device}
    [Documentation]    Getting value for Alarm definition total count
    [Tags]        @author=ssekar
    ${result}    Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/definitions"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <definitions><total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Verifying Alarm definition subscope gets filtered using count
    [Arguments]    ${device}    ${count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using count
    [Tags]        @author=ssekar
    : FOR    ${INDEX}    IN RANGE    1    6
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${count})    modules=random
    \    ${result}    cli    ${device}    show alarm definitions subscope count ${start}    timeout=120
    \    Result Should Contain    total-count ${start}
    ${result}    cli    ${device}    show alarm definitions subscope count 0    timeout=90
    Result Should Contain    total-count 0
    ${count1}=    Evaluate    ${count}+1
    ${result}    cli    ${device}    show alarm definitions subscope count ${count1} | include total-count    timeout=90
    Result Should Contain    total-count ${count}

Verifying Alarm definition subscope gets filtered using id
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using id
    [Tags]        @author=ssekar
    ${count}    Set Variable If    ${total_count} >= 5    5    ${total_count}
    ${result}    cli    ${device}    show alarm definitions subscope count ${total_count} | include id | exclude name | exclude details | exclude probable-cause | exclude additional-text | exclude description | exclude repair-action | exclude address | exclude session-id    timeout=90
    @{match}    GetRegexp Matches    ${result}    id ([0-9]+)    1
    ${ret}    Evaluate    random.sample(@{match},${count})    modules=random
    : FOR    ${INDEX}    IN RANGE    0    ${count}
    \    Log    ${INDEX}
    \    ${list}    Get From List    ${ret}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm definitions subscope id ${list}    timeout=90
    \    Result Should Contain    id ${list}

Verifying Alarm definition subscope gets filtered using name
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using name
    [Tags]        @author=ssekar
    ${count}    Set Variable If    ${total_count} >= 5    5    ${total_count}
    ${result}    cli    ${device}    show alarm definitions subscope count ${total_count} | include name | exclude details | exclude probable-cause | exclude additional-text | exclude description | exclude repair-action | exclude address    timeout=90
    @{match}    GetRegexp Matches    ${result}    name ([a-z\-]+)    1
    ${ret}    Evaluate    random.sample(@{match},${count})    modules=random
    : FOR    ${INDEX}    IN RANGE    0    ${count}
    \    Log    ${INDEX}
    \    ${list}    Get From List    ${ret}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm definitions subscope name ${list}    timeout=90
    \    Result Should Contain    name ${list}

Verifying Alarm definition subscope gets filtered using category
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using category
    [Tags]        @author=ssekar
    ${re}    cli    ${device}    show alarm definitions subscope count ${total_count} | include category     timeout=90
    @{match}    GetRegexp Matches    ${re}    category ([A-Z0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm definitions subscope category ${list}    timeout=90
    \    Result Should Contain    category ${list}
    \    Result Should Not Contain       category unknown

Alarm_definition_subscope_category_netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using category
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-definitions-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <category>([A-Z0-9]+)</category>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${list}</category></show-alarm-definitions-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}    <category>${list}</category>

Alarm_definition_subscope_name_netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using name
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-definitions-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <name>([A-Za-z0-9\-\_]+)</name>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><name>${list}</name></show-alarm-definitions-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}      <name>${list}</name>

Alarm_definition_subscope_count_netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using count
    [Tags]        @author=ssekar
    : FOR    ${INDEX}    IN RANGE    1    6
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${total_count})    modules=random
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-definitions-subscope></rpc>]]>]]>
         #Sleep for 2s in total to populate the result
    \    BuiltIn.Sleep    2s
    \    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>0</count></show-alarm-definitions-subscope></rpc>]]>]]>
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>0</total-count>
    ${count1}=    Evaluate    ${total_count}+1
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${count1}</count></show-alarm-definitions-subscope></rpc>]]>]]>
    #Sleep for 7s in total to populate the result
    BuiltIn.Sleep    7s
    Should Contain    ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>

Alarm_definition_subscope_ID_netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm definition subscope gets filtered using id
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-definitions-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}     <id>([0-9]+)</id>    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><id>${list}</id></show-alarm-definitions-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}      <id>${list}</id>

Checking_Alarm_definition_parameters
    [Arguments]    ${device}      ${parameter}
    [Documentation]    Verifying Alarm definition parameters
    [Tags]        @author=ssekar
   
    ${count}    Getting Alarm definition total count     ${device}
    ${result}    cli    ${device}    show alarm definitions subscope count ${count}     timeout=120
    Run Keyword If    '${parameter}' == 'probable-cause'      Should Not Contain    ${result}     probable-cause unknown
    Run Keyword If    '${parameter}' == 'category'           Should Not Contain    ${result}      category UNKNOWN
    Run Keyword If    '${parameter}' == 'description'      Should Not Contain    ${result}        description unknown
    Run Keyword If    '${parameter}' == 'repair_action'     Should Not Contain    ${result}        repair_action unknown

Checking_Alarm_definition_parameters_netconf
    [Arguments]    ${device}      ${parameter}
    [Documentation]    Verifying Alarm definition parameters
    [Tags]        @author=ssekar

    ${count}    Getting Alarm definition total count using netconf       ${device}
    ${result}=     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${count}</count></show-alarm-definitions-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Run Keyword If    '${parameter}' == 'probable-cause'      Should Not Contain    ${result.xml}        <probable-cause>unknown</probable-cause>
    Run Keyword If    '${parameter}' == 'category'           Should Not Contain    ${result.xml}        <category>UNKNOWN</category>
    Run Keyword If    '${parameter}' == 'description'      Should Not Contain    ${result.xml}        <description>unknown</description>
    Run Keyword If    '${parameter}' == 'repair_action'     Should Not Contain    ${result.xml}        <repair_action>unknown<repair_action>

Verify Alarm definition filtered by severity
    [Arguments]    ${device}
    [Documentation]    Alarms definitions filtered by severity
    [Tags]        @author=ssekar
    Log    Checking CRITICAL alarms
    ${result}    cli    ${device}    show alarm definitions subscope perceived-severity CRITICAL | include perceived-severity    timeout=90
    Result Should Not Contain    perceived-severity MINOR
    Result Should Not Contain    perceived-severity MAJOR
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity WARNING
    Result Should Not Contain    perceived-severity INDETERMINATE
    Result Should Contain    perceived-severity CRITICAL
    Log    Checking MAJOR alarms
    ${result}    cli    ${device}    show alarm definitions subscope perceived-severity MAJOR | include perceived-severity       timeout=90
    Result Should Not Contain    perceived-severity MINOR
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity WARNING
    Result Should Not Contain    perceived-severity INDETERMINATE
    Result Should Contain    perceived-severity CRITICAL
    Result Should Contain    perceived-severity MAJOR
    Log    Checking MINOR alarms
    ${result}    cli    ${device}    show alarm definitions subscope perceived-severity MINOR | include perceived-severity      timeout=90
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity WARNING
    Result Should Not Contain    perceived-severity INDETERMINATE
    Result Should Contain    perceived-severity CRITICAL
    Result Should Contain    perceived-severity MAJOR
    Result Should Contain    perceived-severity MINOR
    Log    Checking WARNING alarms
    ${result}    cli    ${device}    show alarm definitions subscope perceived-severity WARNING | include perceived-severity       timeout=90
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity INDETERMINATE
    Result Should Contain    perceived-severity CRITICAL
    Result Should Contain    perceived-severity MAJOR
    Result Should Contain    perceived-severity MINOR
    Result Should Contain    perceived-severity WARNING
    Log    Checking CLEAR alarms
    ${result}    cli    ${device}    show alarm definitions subscope perceived-severity CLEAR | include perceived-severity        timeout=90
    Result Should Not Contain    perceived-severity INDETERMINATE
    Result Should Contain    perceived-severity CRITICAL
    Result Should Contain    perceived-severity MAJOR
    Result Should Contain    perceived-severity MINOR
    Result Should Contain    perceived-severity WARNING
    Result Should Contain    perceived-severity CLEAR
    Result Should Contain    perceived-severity INFO
    Log    Checking INFO alarms
    ${result}    cli    ${device}    show alarm definitions subscope perceived-severity INFO | include perceived-severity        timeout=90
    Result Should Not Contain    perceived-severity INDETERMINATE
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Contain    perceived-severity CRITICAL
    Result Should Contain    perceived-severity MAJOR
    Result Should Contain    perceived-severity MINOR
    Result Should Contain    perceived-severity WARNING
    Result Should Contain    perceived-severity INFO
    Log    Checking INDETERMINATE alarms
    ${result}    cli    ${device}    show alarm definitions subscope perceived-severity INDETERMINATE | include perceived-severity       timeout=90
    Result Should Contain    perceived-severity CRITICAL
    Result Should Contain    perceived-severity MAJOR
    Result Should Contain    perceived-severity MINOR
    Result Should Contain    perceived-severity WARNING
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO

Verifying Active Alarm subscope gets filtered using category
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered using category
    [Tags]        @author=ssekar
    ${re}    cli    ${device}    show alarm active subscope count ${total_count} | include category       timeout=90
    @{match}    GetRegexp Matches    ${re}    category ([A-Z0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm active subscope category ${list}    timeout=90
    \    Result Should Contain    category ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    category ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying Active Alarm subscope gets filtered by category using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered by category using netconf
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <category>([A-Z0-9]+)</category>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${list}</category></show-alarm-instances-active-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}    <category>${list}</category>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${str}      <category>${list}</category>
    \    ${count1}    Get Line Count    ${line1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying Active Alarm subscope gets filtered using count
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered using count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm active subscope count ${total_count}    timeout=30
    Result Should Contain    total-count ${total_count}
    Result Should Contain    index ${total_count}
    ${total_count}    Set Variable If    ${total_count} >= 200    200    ${total_count}
    ${tot_chk}    Evaluate    ($total_count >= 2 )
    ${tty}    Evaluate    ($tot_chk == True)
    ${end}    Set Variable If    ${tty} == True    2
    ${to_count}=    Evaluate    ${total_count}-1
    : FOR    ${INDEX}    IN RANGE    1    ${end}+1
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${to_count})    modules=random
    \    cli    ${device}    show alarm active subscope count ${start}    timeout=30
    \    Result Should Contain    total-count ${start}
    \    Result Should Contain    index ${start}
    ${result}    cli    ${device}    show alarm active subscope count 0
    Result Should Contain    total-count 0

Verifying Active Alarm subscope gets filtered by count using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered by count using netconf
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    Should Contain    ${result.xml}    <index>${total_count}</index>
    ${to_count}=    Evaluate    ${total_count}-1
    : FOR    ${INDEX}    IN RANGE    1    3
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${to_count})    modules=random
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${start}</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    #Sleep for 5sin total to populate the result
    \    BuiltIn.Sleep    5s
    \    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${start}</total-count>
    \    Should Contain    ${result.xml}    <index>${start}</index>
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>0</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>0</total-count>

Verifying Active Alarm subscope gets filtered using instance-id
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered using instance-id
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm active subscope count ${total_count} | include instance-id | exclude address | exclude details    timeout=30
    @{match}    GetRegexp Matches    ${result}    instance-id ([0-9.]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm active subscope instance-id ${list}    timeout=10
    \    Result Should Contain    instance-id ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    instance-id ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying Active Alarm subscope gets filtered by instance-id using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered by instance-id using netconf
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <instance-id>([0-9.]+)</instance-id>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${list}</instance-id></show-alarm-instances-active-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}    <instance-id>${list}</instance-id>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${str}      <instance-id>${list}</instance-id>
    \    ${count1}    Get Line Count    ${line1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying Active Alarm subscope gets filtered using name
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered using name
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm active subscope count ${total_count} | include name | exclude description | exclude probable-cause | exclude repair-action | exclude address | exclude details     timeout=90
    @{match}    GetRegexp Matches    ${result}    name ([A-Za-z0-9\-\_]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm active subscope name ${list}    timeout=90
    \    Result Should Contain    name ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    name ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying Active Alarm subscope gets filtered by name using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered using name by netconf
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <name>([A-Za-z0-9\-\_]+)</name>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>${list}</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}    <name>${list}</name>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${str}      <name>${list}</name>
    \    ${count1}    Get Line Count    ${line1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying Active Alarm subscope gets filtered using ID
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered using ID
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm active subscope count ${total_count} | include id | exclude instance-id | exclude details | exclude description | exclude name | exclude probable-cause | exclude additional-text | exclude repair-action | exclude address | exclude session-id      timeout=90
    ${match}    Get Regexp Matches    ${result}    \s*id ([0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm active subscope id ${list}    timeout=90
    \    Result Should Contain    id ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    id ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Verifying Active Alarm subscope gets filtered by ID using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Active Alarm subscope gets filtered using ID by netconf
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-active-subscope></rpc>]]>]]>
    #Sleep for 10s in total to populate the result
    BuiltIn.Sleep    10s
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <id>([0-9]+)</id>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>${list}</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}    <id>${list}</id>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${str}      <id>${list}</id>
    \    ${count1}    Get Line Count    ${line1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Clearing alarm history logs
    [Arguments]    ${device}
    [Documentation]    Clearing alarm history logs
    [Tags]        @author=ssekar
    cli    ${device}    clear active alarm-log      timeout=90
    # Sleep for 6s
    Sleep    6s

Clearing alarm history logs using netconf
    [Arguments]    ${device}
    [Documentation]    Clearing alarm history logs
    [Tags]        @author=ssekar
    ${result}     Netconf Raw     ${device}     xml=<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><active-alarm-log xmlns="http://www.calix.com/ns/exa/base"/></rpc>]]>]]>
    Should Contain      ${result.xml}     <ok/>
    # Sleep for 6s
    Sleep    6s

Trigger CRITICAL alarm
    [Arguments]    ${linux}=None    ${device}=None     ${user_interface}=None
    [Documentation]    Triggering CRITICAL alarm
    [Tags]        @author=ssekar
    Wait Until Keyword Succeeds    2 min     10 sec         Disconnect     ${linux}
    Wait Until Keyword Succeeds    2 min     10 sec         cli      ${linux}      cd /var         timeout_exception=0       timeout=120      retry=4
    Wait Until Keyword Succeeds    2 min     10 sec        cli      ${linux}    /etc/init.d/loam.sh start       timeout=120     prompt=var      retry=4
    #Sleep for 18s to clear the critical alarm from active alarm table
    BuiltIn.Sleep    20s
    : FOR    ${INDEX}    IN RANGE    0    800
    \     ${result}    Wait Until Keyword Succeeds    2 min     10 sec         cli      ${linux}      ps -ef | grep loamd        timeout=120    prompt=var    retry=4
    \     ${result}     Get Lines Containing String       ${result}        /usr/bin/loamd
    \     ${process_id}     Get Regexp Matches     ${result}        root\\s*([0-9]+)      1
    \     ${len}     Get Length      ${process_id}
    \     ${process_id}     Run Keyword If   ${len} != 0    Get From List    ${process_id}     0
    \     Run Keyword If   ${len} != 0    cli      ${linux}      kill -9 ${process_id}        timeout_exception=0       timeout=120     prompt=var     retry=4
    #Sleep for 8s after killing the process
    \     BuiltIn.Sleep    8s
    \     Wait Until Keyword Succeeds    2 min     10 sec         Disconnect     ${linux}
    \     Wait Until Keyword Succeeds    2 min     10 sec         cli      ${linux}      cd /var         timeout_exception=0       timeout=120      retry=4
    \     ${result}     Wait Until Keyword Succeeds   3 min     10 sec     cli      ${linux}      ps -ef | grep loamd        timeout=120      prompt=var
    \     ${result}     Get Lines Containing String       ${result}        /usr/bin/loamd  
    \     ${line_count}     Get Line Count     ${result}
    \     Exit For Loop If    ${line_count} == 0
    
    #Sleep for 20s to populate the alarm in active alarm table
    BuiltIn.Sleep    20s
    ${result}    Run Keyword If    '${user_interface}' == 'cli'     cli    ${device}    show alarm active subscope id 1702      timeout=90     retry=4
    Run Keyword If    '${user_interface}' == 'cli'      Result Should Contain      name application-suspended
    Run Keyword If    '${user_interface}' == 'cli'      Result Should Contain      perceived-severity CRITICAL
    ${result}    Run Keyword If  '${user_interface}' == 'netconf'     Netconf Raw      ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1702</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'     Run Keywords     Should Contain    ${result.xml}      <id>1702</id>
    ...   AND    Should Contain    ${result.xml}     <perceived-severity>CRITICAL</perceived-severity>

Triggering CRITICAL alarm
    [Arguments]    ${linux}=None    ${device}=None     ${user_interface}=None
    [Documentation]    Triggering CRITICAL alarm
    [Tags]        @author=ssekar

    : FOR    ${INDEX}    IN RANGE    0    3
    \    ${result}    Wait Until Keyword Succeeds      30 sec     10 sec     Run Keyword And Return Status     Trigger CRITICAL alarm     ${linux}    ${device}  
    \    ...          ${user_interface}
    \    Exit For Loop If    '${result}' == 'True'

    Run Keyword If   '${result}' == 'False'      Fail     msg="Triggering CRITICAL alarm failed"

Clearing CRITICAL alarm
    [Arguments]    ${linux}=None    ${device}=None      ${user_interface}=None
    [Documentation]    Clearing CRITICAL alarm
    [Tags]        @author=ssekar
    Wait Until Keyword Succeeds      2 min     10 sec            Disconnect    ${linux}
    #Sleep for 6s
    Sleep    6s
    Wait Until Keyword Succeeds    2 min     10 sec         cli      ${linux}      cd /var         timeout_exception=0       timeout=120
    ${result}      Wait Until Keyword Succeeds    2 min     10 sec     cli      ${linux}    /etc/init.d/loam.sh start       timeout=120     prompt=var
    Result Should Contain      Starting loamd
    #Sleep for 10s to clear the critical alarm from active alarm table
    BuiltIn.Sleep    10s
    ${result}    Run Keyword If    '${user_interface}' == 'cli'    cli    ${device}    show alarm active subscope id 1702      timeout=90      retry=4
    Run Keyword If    '${user_interface}' == 'cli'    Result Should Not Contain      primary-element loamd
    ${result}    Run Keyword If  '${user_interface}' == 'netconf'     Netconf Raw      ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1702</id></show-alarm-instances-active-subscope></rpc>]]>]]>
    Run Keyword If    '${user_interface}' == 'netconf'     Should Not Contain    ${result.xml}       <primary-element>loamd</primary-element>

Alarm history subscope count
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using subscope count
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count}    timeout=90
    Result Should Contain    total-count ${total_count}
    ${total_count}    Set Variable If    ${total_count} >= 200    200    ${total_count}
    ${tot_chk}    Evaluate    ($total_count >= 2)
    ${tty}    Evaluate    ($tot_chk == True)
    ${end}    Set Variable If    ${tty} == True    2      0
    Run Keyword If     ${end} == 0      Log   "Alarm history count must be increased"
    ${to_count}=    Evaluate    ${total_count}-1
    : FOR    ${INDEX}    IN RANGE    1    ${end}+1
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${to_count})    modules=random
    \    ${result}     cli    ${device}    show alarm history subscope count ${start}    timeout=90
    \    Result Should Contain    total-count ${start}
    ${result}    cli    ${device}    show alarm history subscope count 0
    Result Should Contain    total-count 0

Alarm history subscope count using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using subscope count
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    Should Contain    ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${total_count}    Set Variable If    ${total_count} >= 100     100     ${total_count}
    ${tot_chk}    Evaluate    ($total_count >= 2)  
    ${tty}    Evaluate    ($tot_chk == True)
    ${end}    Set Variable If    ${tty} == True    2      0
    Run Keyword If     ${end} == 0      Log   "Alarm history count must be increased"
    ${to_count}=    Evaluate    ${total_count}-1
    : FOR    ${INDEX}    IN RANGE    1    ${end}+1
    \    Log    ${INDEX}
    \    ${start}    Evaluate    random.randint(1, ${to_count})    modules=random
    \    ${result}     Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${start}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>${start}</total-count>
    ${result}     Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>0</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    Should Contain    ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>0</total-count>
 
Alarm history subscope category
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using subscope category
    [Tags]        @author=ssekar
    ${re}    cli    ${device}    show alarm history subscope count ${total_count} | include category    timeout=90
    @{match}    GetRegexp Matches    ${re}    category ([A-Z0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm history subscope category ${list}    timeout=90
    \    Result Should Contain    category ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    category ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history subscope category using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using subscope category
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <category>([A-Z0-9]+)</category>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${list}</category></show-alarm-instances-history-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}    <category>${list}</category>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${str}      <category>${list}</category>
    \    ${count1}    Get Line Count    ${line1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history subscope severity
    [Arguments]    ${device}
    [Documentation]    Alarm history filtered by subscope severity
    [Tags]        @author=ssekar
    Log    Checking CRITICAL alarms
    ${result}    cli    ${device}    show alarm history subscope perceived-severity CRITICAL | include perceived-severity     timeout=90
    Result Should Not Contain    perceived-severity MINOR
    Result Should Not Contain    perceived-severity MAJOR
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity WARNING
    Result Should Not Contain    perceived-severity INDETERMINATE
    Log    Checking MAJOR alarms
    ${result}    cli    ${device}    show alarm history subscope perceived-severity MAJOR | include perceived-severity       timeout=90
    Result Should Not Contain    perceived-severity MINOR
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity WARNING
    Result Should Not Contain    perceived-severity INDETERMINATE
    Log    Checking MINOR alarms
    ${result}    cli    ${device}    show alarm history subscope perceived-severity MINOR | include perceived-severity      timeout=90
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity WARNING
    Result Should Not Contain    perceived-severity INDETERMINATE
    Log    Checking WARNING alarms
    ${result}    cli    ${device}    show alarm history subscope perceived-severity WARNING | include perceived-severity       timeout=90
    Result Should Not Contain    perceived-severity CLEAR
    Result Should Not Contain    perceived-severity INFO
    Result Should Not Contain    perceived-severity INDETERMINATE
    Log    Checking CLEAR alarms
    ${result}    cli    ${device}    show alarm history subscope perceived-severity CLEAR | include perceived-severity      timeout=90
    Result Should Not Contain    perceived-severity INDETERMINATE
    Log    Checking INFO alarms
    ${result}    cli    ${device}    show alarm history subscope perceived-severity INFO | include perceived-severity       timeout=90
    Result Should Not Contain    perceived-severity INDETERMINATE

Alarm history subscope instance-id
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using subscope instance-id
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include instance-id | exclude address | exclude details    timeout=90
    @{match}    GetRegexp Matches    ${result}    instance-id ([0-9.]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm history subscope instance-id ${list}    timeout=90
    \    Result Should Contain    instance-id ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    instance-id ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history subscope instance-id using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using subscope instance-id
    [Tags]        @author=ssekar
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    ${str}      Convert to string     ${result}
    @{match}    GetRegexp Matches    ${str}    <instance-id>([0-9.]+)</instance-id>     1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >=50    50    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${list}</instance-id></show-alarm-instances-history-subscope></rpc>]]>]]>
    \    Should Contain    ${result.xml}    <instance-id>${list}</instance-id>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${str}      <instance-id>${list}</instance-id>
    \    ${count1}    Get Line Count    ${line1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history filter netconf
    [Arguments]    ${device}    ${total_count}     ${parameter}=None
    [Documentation]    Verifying Alarm history filter
    [Tags]        @author=ssekar
    ${result}      Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    ${str}      Convert to string     ${result}
    @{id}       GetRegexp Matches    ${str}    <id>([0-9]+)</id>      1
    @{id}       Remove Duplicates    ${id}
    @{name}      GetRegexp Matches    ${str}    <name>([A-Za-z0-9\-\_]+)</name>     1
    @{name}      Remove Duplicates    ${name}
    @{instance-id}      GetRegexp Matches    ${str}    <instance-id>([0-9.]+)</instance-id>        1 
    @{instance-id}      Remove Duplicates    ${instance-id}
    @{time}     GetRegexp Matches    ${str}        <ne-event-time>([0-9A-Z:\-]+)</ne-event-time>      1
    @{time}     Remove Duplicates    ${time}
    ${len}    Run Keyword If    '${parameter}' == 'id'    Get Length    ${id}
    ...      ELSE IF    '${parameter}' == 'name'     Get Length    ${name}
    ...      ELSE IF    '${parameter}' == 'instance-id'    Get Length    ${instance-id}
    ...      ELSE IF    '${parameter}' == 'time'      Get Length    ${time}
    ${len}    Set Variable If    ${len} >=10    10    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Run Keyword If    '${parameter}' == 'id'    Get From List    ${id}    ${INDEX}
    \    ...     ELSE IF    '${parameter}' == 'name'     Get From List    ${name}     ${INDEX}
    \    ...     ELSE IF    '${parameter}' == 'instance-id'     Get From List    ${instance-id}     ${INDEX}
    \    ...     ELSE IF    '${parameter}' == 'time'    Get From List    ${time}     ${INDEX}
    \    ${result}     Run Keyword If    '${parameter}' == 'id'     Netconf Raw     ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><id>${list}</id></show-alarm-instances-history-filter></rpc>]]>]]>
    \    ...     ELSE IF    '${parameter}' == 'name'      Netconf Raw     ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><name>${list}</name></show-alarm-instances-history-filter></rpc>]]>]]>
    \    ...     ELSE IF    '${parameter}' == 'instance-id'      Netconf Raw     ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><instance-id>${list}</instance-id></show-alarm-instances-history-filter></rpc>]]>]]>
    \    ...     ELSE IF    '${parameter}' == 'time'      Netconf Raw     ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><time>${list}</time></show-alarm-instances-history-filter></rpc>]]>]]>
    \    Run Keyword If    '${parameter}' == 'id'     Should Contain      ${result.xml}       <id>${list}</id>
    \    Run Keyword If    '${parameter}' == 'name'    Should Contain      ${result.xml}       <name>${list}</name>
    \    Run Keyword If    '${parameter}' == 'instance-id'    Should Contain      ${result.xml}       <instance-id>${list}</instance-id>
    \    Run Keyword If    '${parameter}' == 'time'    Should Contain      ${result.xml}       <ne-event-time>${list}</ne-event-time>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0

Alarm_archive_log_range
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Alarm archive filter by range
    [Tags]        @author=ssekar
    ${start_value}    Set Variable    1
    ${result}    cli    ${device}    show alarm archive log start-value ${start_value} end-value ${total_count}    timeout=90
    Result Should Contain    total-count ${total_count}
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    cli    ${device}    show alarm archive log start-value ${start} end-value ${end}    timeout=90
    ${count}=    Evaluate    ${end}-${start}+1
    Result Should Contain    total-count ${count}

Alarm_archive_log_range_using_netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Alarm archive filter by range
    [Tags]        @author=ssekar
    ${start_value}    Set Variable    1
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-log xmlns="http://www.calix.com/ns/exa/base"><start-value>${start_value}</start-value><end-value>${total_count}</end-value></show-alarm-instances-archive-log ></rpc>]]>]]>
    Should Contain    ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${str}      Convert to string     ${result}
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-log xmlns="http://www.calix.com/ns/exa/base"><start-value>${start}</start-value><end-value>${end}</end-value></show-alarm-instances-archive-log ></rpc>]]>]]>
    ${count}=    Evaluate    ${end}-${start}+1
    Should Contain    ${result.xml}      <total-count xmlns='http://www.calix.com/ns/exa/base'>${count}</total-count>
    

Alarm history range
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Alarm history filter by range
    [Tags]        @author=ssekar
    ${start_value}    Set Variable    1
    ${result}    cli    ${device}    show alarm history range start-value ${start_value} end-value ${total_count}    timeout=90
    Result Should Contain    total-count ${total_count}
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    cli    ${device}    show alarm history range start-value ${start} end-value ${end}    timeout=90
    ${count}=    Evaluate    ${end}-${start}+1
    Result Should Contain    total-count ${count}

Alarm history range using netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Alarm history filter by range
    [Tags]        @author=ssekar
    ${start_value}    Set Variable    1
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-range xmlns="http://www.calix.com/ns/exa/base"><start-value>${start_value}</start-value><end-value>${total_count}</end-value></show-alarm-instances-history-range></rpc>]]>]]>
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count}</total-count>
    ${tot_count}=    Evaluate    ${total_count}/2
    ${to_count}=    Evaluate    ${tot_count}+1
    ${start}    Evaluate    random.randint(1, ${tot_count})    modules=random
    ${end}    Evaluate    random.randint(${to_count}, ${total_count})    modules=random
    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-range xmlns="http://www.calix.com/ns/exa/base"><start-value>${start}</start-value><end-value>${end}</end-value></show-alarm-instances-history-range></rpc>]]>]]>
    ${count}=    Evaluate    ${end}-${start}+1
    Should Contain    ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${count}</total-count>

Alarm history time
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verify Alarm history filter by time
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include instance-id | exclude address | exclude details      timeout=90
    @{match}    GetRegexp Matches    ${result}    instance-id ([0-9.]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    ${last_value_in_list}    Evaluate    ${len}-1
    ${last_instance}    Get From List    ${match}    ${last_value_in_list}
    ${first_instance}    Get From List    ${match}    0
    Run Keyword    Filtering alarm history time using instance-id    ${device}    ${first_instance}    ${last_instance}
    ${half_len}    Evaluate    ${len}/2
    ${hal_len}    Evaluate    ${half_len}+1
    ${start}    Evaluate    random.randint(1, ${half_len})    modules=random
    ${end}    Evaluate    random.randint(${hal_len}, ${last_value_in_list})    modules=random
    ${first_instance}    Get From List    ${match}    ${start}
    ${last_instance}    Get From List    ${match}    ${end}
    Run Keyword    Filtering alarm history time using instance-id    ${device}    ${first_instance}    ${last_instance}

Filtering alarm history time using instance-id
    [Arguments]    ${device}    ${first_instance}    ${last_instance}
    [Documentation]    Filtering alarm history time using instance-id
    [Tags]        @author=ssekar
    ${time}    cli    ${device}    show alarm history subscope instance-id ${first_instance}      timeout=90
    @{start_time}    Get Regexp Matches    ${time}    ne-event-time ([0-9A-Z:\-]+)    1
    ${start_time}    Get From List    ${start_time}    0
    ${time}    cli    ${device}    show alarm history subscope instance-id ${last_instance}        timeout=90
    @{end_time}=    Get Regexp Matches    ${time}    ne-event-time ([0-9A-Z:\-]+)    1
    ${end_time}    Get From List    ${end_time}    0
    @{time}    GetRegexp Matches    ${start_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    @{time1}    GetRegexp Matches    ${end_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    ${tuple}    Get From List    ${time}    0
    ${tuple1}    Get From List    ${time1}    0
    @{list}    Convert To List    ${tuple}
    @{list1}    Convert To List    ${tuple1}
    ${year1}    Get From List    ${list}    0
    ${year2}    Get From List    ${list1}    0
    ${month1}    Get From List    ${list}    1
    ${month2}    Get From List    ${list1}    1
    ${day1}    Get From List    ${list}    2
    ${day2}    Get From List    ${list1}    2
    ${hour1}    Get From List    ${list}    3
    ${hour2}    Get From List    ${list1}    3
    ${min1}    Get From List    ${list}    4
    ${min2}    Get From List    ${list1}    4
    ${sec1}    Get From List    ${list}    5
    ${sec2}    Get From List    ${list1}    5
    ${yr_chk}    Evaluate    ($year1 < $year2 )
    ${mon_chk}    Evaluate    ($year1 == $year2 and $month1 < $month2)
    ${day_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 < $day2)
    ${hrs_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 < $hour2)
    ${mins_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 == $hour2 and $min1 < $min2)
    ${sec_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 <= $day2 and $hour1 == $hour2 and $min1 == $min2 and $sec1 <= $sec2)
    ${tty}    Evaluate    ($yr_chk or $mon_chk or $day_chk or $hrs_chk or $mins_chk or $sec_chk == True)
    ${x}    Set Variable If    ${tty} == False    ${end_time}    ${start_time}
    ${end_time}    Set Variable If    ${tty} == False    ${start_time}    ${end_time}
    ${start_time}    Set Variable If    ${tty} == False    ${x}    ${x}
    ${result}    cli    ${device}    show alarm history timerange start-time ${start_time} end-time ${end_time}       timeout=90
    Result Should Contain    instance-id ${first_instance}
    Result Should Contain    instance-id ${last_instance}
    Result Should Contain    ne-event-time ${start_time}
    Result Should Contain    ne-event-time ${end_time}

Alarm history source
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Alarm history filtered by address using key and value
    [Tags]        @author=ssekar
    ${result}=    cli    ${device}    show alarm history address key port value ${port}      timeout=90
    Result Should Contain    ${port}']
    Should Match Regexp    ${result}    .*(${port}'])

Alarm history source using netconf
    [Arguments]    ${device}    ${port}
    [Documentation]    Verify Alarm history filtered by address using key and value
    [Tags]        @author=ssekar
    ${result}=    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-address xmlns="http://www.calix.com/ns/exa/base"><key>port</key><value>${port}</value></show-alarm-instances-history-address></rpc>]]>]]>
    Should Contain     ${result.xml}      ${port}']</address>    
 
Alarm history filter using ID
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using ID
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include id | exclude instance-id | exclude details | exclude description | exclude name | exclude probable-cause | exclude additional-text | exclude repair-action | exclude address | exclude session-id      timeout=90
    ${match}    Get Regexp Matches    ${result}    \s*id ([0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm history filter id ${list}    timeout=90
    \    Result Should Contain    id ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    id ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0



Alarm history filter using name
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using name
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include name | exclude description | exclude probable-cause | exclude repair-action | exclude address | exclude details       timeout=90
    @{match}    GetRegexp Matches    ${result}    name ([A-Za-z0-9\-\_]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm history filter name ${list}    timeout=90
    \    Result Should Contain    name ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    name ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history filter using instance-id
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using instance-id
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include instance-id | exclude address | exclude details    timeout=90
    @{match}    GetRegexp Matches    ${result}    instance-id ([0-9.]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm history filter instance-id ${list}    timeout=90
    \    Result Should Contain    instance-id ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    instance-id ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history filter using time
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history gets filtered using time
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include ne-event-time    timeout=90
    @{match}    Get Regexp Matches    ${result}    ne-event-time ([0-9A-Z:\-]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Evaluate    ${len}-1
    ${end}    Set Variable If    ${len} >= 8      8      ${len}
    : FOR    ${INDEX}    IN RANGE    1    ${end}
    \    ${start}    Evaluate    random.randint(1, ${len})    modules=random
    \    ${time}    Get From List    ${match}    ${start}
    \    ${result}    cli    ${device}    show alarm history filter time ${time}    timeout=90
    \    Result Should Contain    ne-event-time ${time}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${line1}    Get Lines Containing String    ${result}    ne-event-time ${time}
    \    ${count1}    Get Line Count    ${line1}
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history log using category start-value and end-value
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history log gets filtered using category
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include category     timeout=90
    @{match}    GetRegexp Matches    ${result}    category ([A-Z0-9]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${end}    Set Variable If    ${len} >= 20   20     ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${end}
    \    ${list}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm history subscope category ${list}    timeout=90
    \    Result Should Contain    category ${list}
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${result}    cli    ${device}    show alarm history log category ${list} start-value 1 end-value ${total_count1}      timeout=90
    \    Result Should Contain    total-count ${total_count1}
    \    Result Should Contain    category ${list}
    \    ${line1}    Get Lines Containing String    ${result}    category ${list}
    \    ${count1}    Get Line Count    ${line1}
    \    ${count1}=    Evaluate    ${count1}-1
    \    ${equal}    Should Be Equal    ${total_count1}    ${count1}
    \    ${total_count1}    Set Variable    0
    \    ${count1}    Set Variable    0

Alarm history log using category start-value and end-value in netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history log gets filtered using category
    [Tags]        @author=ssekar
    ${result}      Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    ${str}      Convert to string     ${result}
    @{category}       GetRegexp Matches    ${str}    <category>([A-Z0-9]+)</category>      1
    @{category}       Remove Duplicates    ${category}
    ${len}      Get Length    ${category}
    ${end}    Set Variable If    ${len} >= 20   20     ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${end}
    \    ${list}    Get From List    ${category}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${list}</category></show-alarm-instances-history-subscope></rpc>]]>]]>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}    <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>     1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-log xmlns="http://www.calix.com/ns/exa/base"><start-value>1</start-value><end-value>${total_count1}</end-value><category>${list}</category></show-alarm-instances-history-log></rpc>]]>]]>
    \    Should Contain     ${result.xml}    <category>${list}</category>
    \    Should Contain     ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count1}</total-count>

Alarm history log using perceived-severity start-value and end-value in netconf
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history log gets filtered using perceived-severity
    [Tags]        @author=ssekar
    ${result}      Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><count>${total_count}</count></show-alarm-instances-history-subscope></rpc>]]>]]>
    ${str}      Convert to string     ${result}
    @{severity}       GetRegexp Matches    ${str}    <perceived-severity>([A-Z]+)</perceived-severity>      1
    @{severity}       Remove Duplicates    ${severity}
    ${len}      Get Length    ${severity}
    ${end}    Set Variable If    ${len} >= 20   20     ${len}
    : FOR    ${INDEX}    IN RANGE    0    ${end}
    \    ${list}    Get From List    ${severity}    ${INDEX}
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><perceived-severity>${list}</perceived-severity></show-alarm-instances-history-subscope></rpc>]]>]]>
    \    ${str}      Convert to string     ${result}
    \    @{res1}    Get Regexp Matches    ${str}    <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>     1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count1}    0
    \    ${result}    Netconf Raw    ${device}     xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-log xmlns="http://www.calix.com/ns/exa/base"><start-value>1</start-value><end-value>${total_count1}</end-value><perceived-severity>${list}</perceived-severity></show-alarm-instances-history-log></rpc>]]>]]>
    \    Should Contain     ${result.xml}    <perceived-severity>${list}</perceived-severity>
    \    Should Contain     ${result.xml}    <total-count xmlns='http://www.calix.com/ns/exa/base'>${total_count1}</total-count>


Alarm history log using perceived-severity between time-range and value
    [Arguments]    ${device}    ${total_count}
    [Documentation]    Verifying Alarm history log gets filtered using perceived-severity
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include perceived-severity       timeout=90
    @{match}    GetRegexp Matches    ${result}    perceived-severity ([A-Z]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    : FOR    ${INDEX}    IN RANGE    0    ${len}
    \    ${list_fin}    Get From List    ${match}    ${INDEX}
    \    ${result}    cli    ${device}    show alarm history subscope perceived-severity ${list_fin}    timeout=90
    \    @{res1}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    \    ${total_count1}    Get From List    ${res1}    0
    \    ${total_count_1}    Convert To Integer    ${total_count1}
    \    Should Not Be Equal As Integers    ${total_count_1}    0
    \    Run Keyword    Alarm history log using time range    ${device}    ${total_count}    ${list_fin}    ${total_count_1}

Alarm history log using time range
    [Arguments]    ${device}    ${total_count}    ${list_fin}    ${total_count_1}
    [Documentation]    Verify Alarm history log by time range
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show alarm history subscope count ${total_count} | include instance-id | exclude address | exclude details      timeout=90
    @{match}    GetRegexp Matches    ${result}    instance-id ([0-9.]+)    1
    @{match}    Remove Duplicates    ${match}
    ${len}    Get Length    ${match}
    ${len}    Set Variable If    ${len} >= 100    100    ${len}
    ${last_value_in_list}    Evaluate    ${len}-1
    ${last_instance}    Get From List    ${match}    ${last_value_in_list}
    ${first_instance}    Get From List    ${match}    0
    Run Keyword    Filtering alarm history log using perceived-severity and time-range    ${device}    ${first_instance}    ${last_instance}    ${list_fin}    ${total_count_1}

Filtering alarm history log using perceived-severity and time-range
    [Arguments]    ${device}    ${first_instance}    ${last_instance}    ${list_fin}    ${total_count_1}
    [Documentation]    Filtering alarm history log using time-range
    [Tags]        @author=ssekar
    ${time}    cli    ${device}    show alarm history subscope instance-id ${first_instance}      timeout=90
    @{start_time}    Get Regexp Matches    ${time}    ne-event-time ([0-9A-Z:\-]+)    1
    ${start_time}    Get From List    ${start_time}    0
    ${time}    cli    ${device}    show alarm history subscope instance-id ${last_instance}       timeout=90
    @{end_time}=    Get Regexp Matches    ${time}    ne-event-time ([0-9A-Z:\-]+)    1
    ${end_time}    Get From List    ${end_time}    0
    @{time}    GetRegexp Matches    ${start_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    @{time1}    GetRegexp Matches    ${end_time}    (\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).*    1    2    3
    ...    4    5    6
    ${tuple}    Get From List    ${time}    0
    ${tuple1}    Get From List    ${time1}    0
    @{list}    Convert To List    ${tuple}
    @{list1}    Convert To List    ${tuple1}
    ${year1}    Get From List    ${list}    0
    ${year2}    Get From List    ${list1}    0
    ${month1}    Get From List    ${list}    1
    ${month2}    Get From List    ${list1}    1
    ${day1}    Get From List    ${list}    2
    ${day2}    Get From List    ${list1}    2
    ${hour1}    Get From List    ${list}    3
    ${hour2}    Get From List    ${list1}    3
    ${min1}    Get From List    ${list}    4
    ${min2}    Get From List    ${list1}    4
    ${sec1}    Get From List    ${list}    5
    ${sec2}    Get From List    ${list1}    5
    ${yr_chk}    Evaluate    ($year1 < $year2 )
    ${mon_chk}    Evaluate    ($year1 == $year2 and $month1 < $month2)
    ${day_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 < $day2)
    ${hrs_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 < $hour2)
    ${mins_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 == $day2 and $hour1 == $hour2 and $min1 < $min2)
    ${sec_chk}    Evaluate    ($year1 == $year2 and $month1 == $month2 and $day1 <= $day2 and $hour1 == $hour2 and $min1 == $min2 and $sec1 <= $sec2)
    ${tty}    Evaluate    ($yr_chk or $mon_chk or $day_chk or $hrs_chk or $mins_chk or $sec_chk == True)
    ${x}    Set Variable If    ${tty} == False    ${end_time}    ${start_time}
    ${end_time}    Set Variable If    ${tty} == False    ${start_time}    ${end_time}
    ${start_time}    Set Variable If    ${tty} == False    ${x}    ${x}
    ${result}    cli    ${device}    show alarm history log perceived-severity ${list_fin} start-time ${start_time} end-time ${end_time} start-value 1 end-value ${total_count_1}      timeout=90
    Result Should Contain    perceived-severity ${list_fin}
    @{perceived_severity}    GetRegexp Matches    ${result}    perceived-severity ([A-Z]+)    1
    ${perceived_severity}    Get From List    ${perceived_severity}    0
    Run Keyword If    '${perceived_severity}' == 'INFO'    Should Not Contain    ${result}    perceived-severity INDETERMINATE
    Run Keyword If    '${perceived_severity}' == 'CRITICAL' or '${perceived_severity}' == 'MAJOR'    Should Not Contain    ${result}    perceived-severity MINOR
    Run Keyword If    '${perceived_severity}' == 'CRITICAL'    Should Not Contain    ${result}    perceived-severity MAJOR
    Run Keyword If    '${perceived_severity}' == 'CRITICAL' or '${perceived_severity}' == 'MAJOR' or '${perceived_severity}' == 'MINOR' or '${perceived_severity}' == 'WARNING'    Should Not Contain    ${result}    perceived-severity CLEAR
    Run Keyword If    '${perceived_severity}' == 'CRITICAL' or '${perceived_severity}' == 'MAJOR' or '${perceived_severity}' == 'MINOR' or '${perceived_severity}' == 'WARNING'    Should Not Contain    ${result}    perceived-severity INFO
    Run Keyword If    '${perceived_severity}' == 'CRITICAL' or '${perceived_severity}' == 'MAJOR' or '${perceived_severity}' == 'MINOR'    Should Not Contain    ${result}    perceived-severity WARNING

Generic Alarms
    [Arguments]    ${device}    ${parameter}=None    ${command_execution}=None    ${alarm}=None      ${type}=None
    [Documentation]    Alarm active,description,name,repair-action
    [Tags]        @author=ssekar


    ${command}   Set Variable If     '${command_execution}' == 'active_alarm_name_loss_of_signal'     show alarm active subscope name loss-of-signal
    ...          '${command_execution}' == 'active_alarm_name_rmon_session'  show alarm active subscope name ethernet-rmon-session-stopped
    ...          '${command_execution}' == 'definition_alarm_name_loss_of_signal'     show alarm definitions subscope name loss-of-signal
    ...          '${command_execution}' == 'definition_alarm_name_rmon_session'     show alarm definitions subscope name ethernet-rmon-session-stopped
    ...          '${command_execution}' == 'history_alarm_name_loss_of_signal'     show alarm history filter name loss-of-signal
    ...          '${command_execution}' == 'history_alarm_name_rmon_session'     show alarm history filter name ethernet-rmon-session-stopped
    ...          '${command_execution}' == 'archiving_alarm_name_loss_of_signal'     show alarm archive filter name loss-of-signal
    ...          '${command_execution}' == 'archiving_alarm_name_rmon_session'     show alarm archive filter name ethernet-rmon-session-stopped
    ...         '${command_execution}' == 'active_alarm_category_loss_of_signal'    show alarm active subscope category PORT
    ...         '${command_execution}' == 'active_alarm_category_rmon_session'    show alarm active subscope category GENERAL
    ...         '${command_execution}' == 'definition_alarm_category_loss_of_signal'    show alarm definitions subscope category PORT
    ...         '${command_execution}' == 'definition_alarm_category_rmon_session'      show alarm definitions subscope category GENERAL
    ...         '${command_execution}' == 'history_alarm_category_loss_of_signal'       show alarm history subscope category PORT
    ...         '${command_execution}' == 'history_alarm_category_rmon_session'       show alarm history subscope category GENERAL
    ...         '${command_execution}' == 'archive_alarm_category_loss_of_signal'       show alarm archive subscope category PORT
    ...         '${command_execution}' == 'archive_alarm_category_rmon_session'       show alarm archive subscope category GENERAL
    ...          '${command_execution}' == 'active_alarm_loss_of_signal'    show alarm active subscope id 1201
    ...          '${command_execution}' == 'active_alarm_rmon_session'   show alarm active subscope id 1221
    ...          '${command_execution}' == 'definition_alarm_loss_of_signal'   show alarm definitions subscope id 1201
    ...          '${command_execution}' == 'definition_alarm_rmon_session'   show alarm definitions subscope id 1221
    ...          '${command_execution}' == 'history_alarm_loss_of_signal'   show alarm history filter id 1201
    ...          '${command_execution}' == 'history_alarm_rmon_session'   show alarm history filter id 1221
    ...          '${command_execution}' == 'archiving_alarm_loss_of_signal'    show alarm archive filter id 1201
    ...          '${command_execution}' == 'archiving_alarm_rmon_session'     show alarm archive filter id 1221
    ...          '${alarm}' == 'running_config_act'        show alarm ${type} subscope id 702
    ...          '${alarm}' == 'running_config_his'         show alarm ${type} filter id 702
    ...          '${alarm}' == 'ntp_prov_act' and '${parameter}' != 'category' and '${parameter}' != 'name'         show alarm ${type} subscope id 1919
    ...          '${alarm}' == 'ntp_prov_his' and '${parameter}' != 'category' and '${parameter}' != 'name'         show alarm ${type} filter id 1919
    ...          '${alarm}' == 'ntp_prov_act' and '${parameter}' == 'name'          show alarm ${type} subscope name ntp-prov
    ...          '${alarm}' == 'ntp_prov_his' and '${parameter}' == 'name'          show alarm ${type} filter name ntp-prov
    ...          ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his') and '${parameter}' == 'category'        show alarm ${type} subscope category NTP

    ${result}    cli    ${device}    ${command}      timeout=150  prompt=${prompt}
    @{local_total_count}       Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${local_total_count}    Get From List    ${local_total_count}    0
    ${local_total_count}    Convert To Integer    ${local_total_count}
    Should Not Be Equal As Integers    ${local_total_count}    0


    @{description}    Run Keyword If  '${parameter}' == 'description' and '${command_execution}' == 'active_alarm_loss_of_signal' or '${parameter}' == 'description' and '${command_execution}' == 'definition_alarm_loss_of_signal' or '${parameter}' == 'description' and '${command_execution}' == 'history_alarm_loss_of_signal' or '${parameter}' == 'description' and '${command_execution}' == 'archiving_alarm_loss_of_signal'   Get Regexp Matches    ${result}    description loss of signal
    ...        ELSE IF     '${command_execution}' == 'active_alarm_rmon_session' and '${parameter}' == 'description' or '${parameter}' == 'description' and '${command_execution}' == 'definition_alarm_rmon_session' or '${parameter}' == 'description' and '${command_execution}' == 'history_alarm_rmon_session' or '${parameter}' == 'description' and '${command_execution}' == 'archiving_alarm_rmon_session'    Get Regexp Matches    ${result}    description Ethernet port rmon-session has been stopped
    ...        ELSE IF     '${parameter}' == 'description' and ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')      Get Regexp Matches    ${result}    description This alarm is to indicate that NTP is not provisioned


    @{name}    Run Keyword If  '${parameter}' == 'name' and '${command_execution}' == 'active_alarm_name_loss_of_signal' or '${parameter}' == 'name' and '${command_execution}' == 'definition_alarm_name_loss_of_signal' or '${parameter}' == 'name' and '${command_execution}' == 'history_alarm_name_loss_of_signal' or '${parameter}' == 'name' and '${command_execution}' == 'archiving_alarm_name_loss_of_signal'   Get Regexp Matches    ${result}    name loss-of-signal
    ...        ELSE IF     '${parameter}' == 'name' and '${command_execution}' == 'active_alarm_name_rmon_session' or '${parameter}' == 'name' and '${command_execution}' == 'definition_alarm_name_rmon_session' or '${parameter}' == 'name' and '${command_execution}' == 'history_alarm_name_rmon_session' or '${parameter}' == 'name' and '${command_execution}' == 'archiving_alarm_name_rmon_session'    Get Regexp Matches    ${result}     name ethernet-rmon-session-stopped
    ...        ELSE IF     '${parameter}' == 'name' and ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')      Get Regexp Matches    ${result}    name ntp-prov

    @{repair_action}   Run Keyword If  '${parameter}' == 'repair_action' and '${alarm}' == 'signal_loss'   Get Regexp Matches    ${result}    repair-action Ensure that the physical interface is properly connected and is receiving a valid signal from the far end
    ...        ELSE IF     '${parameter}' == 'repair_action' and '${alarm}' == 'rmon_session'   Get Regexp Matches    ${result}    repair-action Re-enable the session when needed
    ...        ELSE IF     '${parameter}' == 'repair_action' and ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')      Get Regexp Matches    ${result}      repair-action Provision NTP

    @{probable_cause}  Run Keyword If  '${parameter}' == 'probable_cause' and '${alarm}' == 'signal_loss'   Get Regexp Matches    ${result}    probable-cause This alarm is set when there is no signal present on an enabled ethernet interface
    ...        ELSE IF     '${parameter}' == 'probable_cause' and '${alarm}' == 'rmon_session'   Get Regexp Matches    ${result}    probable-cause User action disabled the session
    ...        ELSE IF     '${parameter}' == 'probable_cause' and ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')      Get Regexp Matches    ${result}     probable-cause NTP is not provisioned

    @{alarm_type}      Run Keyword If  '${parameter}' == 'alarm_type' and '${alarm}' == 'signal_loss'    Get Regexp Matches    ${result}    alarm-type COMMUNICATION
    ...        ELSE IF     '${parameter}' == 'alarm_type' and ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')      Get Regexp Matches    ${result}    alarm-type PROCESSING-ERROR

    @{address}     Run Keyword If  '${parameter}' == 'address' and '${alarm}' == 'signal_loss'       Get Regexp Matches    ${result}    address /config/interface/ethernet\\[port.*
    ...        ELSE IF     '${parameter}' == 'address' and ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')      Get Regexp Matches    ${result}    address /config/system/ntp
    @{service_impact}   Run Keyword If  '${parameter}' == 'service_impact' and '${alarm}' == 'signal_loss'    Get Regexp Matches    ${result}    service-impacting TRUE
    ...        ELSE IF     '${parameter}' == 'service_impact' and ('${alarm}' == 'rmon_session' or '${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')     Get Regexp Matches    ${result}    service-impacting FALSE

    @{service_affect}   Run Keyword If  '${parameter}' == 'service_affect' and ('${alarm}' == 'running_config_act' or '${alarm}' == 'running_config_his')    Get Regexp Matches    ${result}    service-affecting TRUE
    ...        ELSE IF     '${parameter}' == 'service_affect' and ('${alarm}' == 'rmon_session' or '${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')     Get Regexp Matches    ${result}    service-affecting FALSE

    @{category}   Run Keyword If   '${parameter}' == 'category' and '${alarm}' == 'signal_loss'    Get Regexp Matches    ${result}    category PORT
     ...        ELSE IF     '${parameter}' == 'category' and '${alarm}' == 'rmon_session'     Get Regexp Matches    ${result}    category GENERAL
     ...        ELSE IF     '${parameter}' == 'category' and ('${alarm}' == 'ntp_prov_act' or '${alarm}' == 'ntp_prov_his')      Get Regexp Matches    ${result}     category NTP

    ${len_description}    Run Keyword If  '${parameter}' == 'description'   Get Length    ${description}
    ${len_name}    Run Keyword If  '${parameter}' == 'name'  Get Length    ${name}
    ${len_name}    Run Keyword If  '${parameter}' == 'name'  Evaluate    ${len_name}-1
    ${len_repair_action}   Run Keyword If  '${parameter}' == 'repair_action'  Get Length    ${repair_action}
    ${len_probable_cause}   Run Keyword If  '${parameter}' == 'probable_cause'  Get Length    ${probable_cause}
    ${len_alarm_type}   Run Keyword If  '${parameter}' == 'alarm_type'   Get Length    ${alarm_type}
    ${len_address}   Run Keyword If  '${parameter}' == 'address'    Get Length    ${address}
    ${len_service_impact}     Run Keyword If  '${parameter}' == 'service_impact'   Get Length    ${service_impact}
    ${len_service_affect}     Run Keyword If  '${parameter}' == 'service_affect'   Get Length    ${service_affect}
    ${len_category}     Run Keyword If  '${parameter}' == 'category'  Get Length    ${category}
    ${len_category}     Run Keyword If  '${parameter}' == 'category'  Evaluate    ${len_category}-1

    ${check}    Evaluate    ($local_total_count == $len_description or $local_total_count == $len_name or $local_total_count == $len_repair_action or $local_total_count == $len_probable_cause or $local_total_count == $len_alarm_type or $local_total_count == $len_address or $local_total_count == $len_service_impact or $local_total_count == $len_service_affect or $local_total_count == $len_category)
    ${true}     Convert To Boolean     'True'
    Should Be Equal    ${check}    ${true}

Alarm_Category_using_netconf
    [Arguments]    ${device}    ${category}=None    ${alarm}=None
    [Documentation]    Alarm active description,name,repair-action
    [Tags]        @author=ssekar

    ${command}    Set Variable If     '${alarm}' == 'active_alarm'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${category}</category></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...          '${alarm}' == 'definition_alarm'      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${category}</category></show-alarm-definitions-subscope></rpc>]]>]]>
    ...          '${alarm}' == 'history_alarm'    <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${category}</category></show-alarm-instances-history-subscope></rpc>]]>]]>
    ...       '${alarm}' == 'suppress_alarm'      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-suppressed-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${category}</category></show-alarm-instances-suppressed-subscope></rpc>]]>]]>
    ...          '${alarm}' == 'archive_alarm'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-subscope xmlns="http://www.calix.com/ns/exa/base"><category>${category}</category></show-alarm-instances-archive-subscope></rpc>]]>]]>
    ${result}     Netconf Raw      ${device}      xml=${command}
    Run Keyword If    '${category}' == 'CONFIGURATION'     Should Contain     ${result.xml}      <category>CONFIGURATION</category>
    Run Keyword If    '${category}' == 'GENERAL'     Should Contain     ${result.xml}      <category>GENERAL</category>
    Run Keyword If    '${category}' == 'NTP'     Should Contain     ${result.xml}      <category>NTP</category>
    ${str}      Convert to string     ${result}
    @{res1}    Get Regexp Matches    ${str}     <total-count xmlns='http://www.calix.com/ns/exa/base'>([0-9]+)</total-count>    1
    ${total_count1}    Get From List    ${res1}    0
    ${total_count1}    Convert To Integer    ${total_count1}
    Should Not Be Equal As Integers    ${total_count1}    0
    ${line1}    Get Lines Containing String    ${str}      <category>${category}</category>
    ${count1}    Get Line Count    ${line1}
    ${equal}    Should Be Equal    ${total_count1}    ${count1}

Alarm_Instance-id
   [Arguments]    ${device}    ${instance-id}    ${parameter}     ${alarm}
   [Documentation]    Alarm Instance-id
   [Tags]        @author=ssekar
   ${result}    cli    ${device}    show alarm ${parameter} subscope instance-id ${instance-id}      timeout=90
   Should Contain   ${result}      instance-id ${instance-id}
   Run Keyword If    '${alarm}' == 'signal_loss'      Should Contain   ${result}      name loss-of-signal
   Run Keyword If    '${alarm}' == 'ethernet_rmon'    Should Contain   ${result}     name ethernet-rmon-session-stopped
   Run Keyword If    '${alarm}' == 'ntp_prov'    Should Contain   ${result}     name ntp-prov

Alarm_Instance-id_netconf
   [Arguments]    ${device}    ${instance-id}    ${parameter}     ${alarm}
   [Documentation]    Alarm Instance-id
   [Tags]        @author=ssekar
   ${result}     Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-${parameter}-subscope xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance-id}</instance-id></show-alarm-instances-${parameter}-subscope></rpc>]]>]]>
   Should Contain    ${result.xml}     <instance-id>${instance-id}</instance-id>
   Run Keyword If    '${alarm}' == 'ethernet_rmon'      Should Contain    ${result.xml}      <name>ethernet-rmon-session-stopped</name>
   Run Keyword If    '${alarm}' == 'running_config'     Should Contain    ${result.xml}       <name>running-config-unsaved</name>
   Run Keyword If    '${alarm}' == 'ntp_prov'    Should Contain   ${result.xml}       <name>ntp-prov</name>

Alarms_verification_using_netconf
    [Arguments]    ${device}    ${parameter}=None    ${alarm}=None
    [Documentation]    Alarm active description,name,repair-action
    [Tags]        @author=ssekar

    ${command}    Set Variable If     '${alarm}' == 'active_alarm_running_config_unsaved'    <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>running-config-unsaved</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...          '${alarm}' == 'active_alarm_rmon_session'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>ethernet-rmon-session-stopped</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...       '${alarm}' == 'suppress_alarm_running_config_unsaved'    <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-suppressed-subscope xmlns="http://www.calix.com/ns/exa/base"><category>CONFIGURATION</category></show-alarm-instances-suppressed-subscope></rpc>]]>]]>
    ...       '${alarm}' == 'suppress_alarm_rmon_session'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-suppressed-subscope xmlns="http://www.calix.com/ns/exa/base"><category>GENERAL</category></show-alarm-instances-suppressed-subscope></rpc>]]>]]>
    ...          '${alarm}' == 'definition_alarm_running_config_unsaved'    <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><name>running-config-unsaved</name></show-alarm-definitions-subscope></rpc>]]>]]>
    ...          '${alarm}' == 'definition_alarm_rmon_session'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><name>ethernet-rmon-session-stopped</name></show-alarm-definitions-subscope></rpc>]]>]]>
    ...          '${alarm}' == 'history_alarm_running_config_unsaved'    <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><name>running-config-unsaved</name></show-alarm-instances-history-filter></rpc>]]>]]>
    ...          '${alarm}' == 'history_alarm_rmon_session'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><name>ethernet-rmon-session-stopped</name></show-alarm-instances-history-filter></rpc>]]>]]>
    ...          '${alarm}' == 'archive_alarm_running_config_unsaved'         <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-filter xmlns="http://www.calix.com/ns/exa/base"><name>running-config-unsaved</name></show-alarm-instances-archive-filter></rpc>]]>]]>
    ...          '${alarm}' == 'archive_alarm_rmon_session'          <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-filter xmlns="http://www.calix.com/ns/exa/base"><name>ethernet-rmon-session-stopped</name></show-alarm-instances-archive-filter></rpc>]]>]]>
    ...         '${alarm}' == 'active_alarm_application_suspended'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>application-suspended</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...         '${alarm}' == 'definition_alarm_application_suspended'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><name>application-suspended</name></show-alarm-definitions-subscope></rpc>]]>]]>
    ...         '${alarm}' == 'history_alarm_application_suspended'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><name>application-suspended</name></show-alarm-instances-history-filter></rpc>]]>]]>
    ...         '${alarm}' == 'suppress_alarm_application_suspended'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-suppressed-subscope xmlns="http://www.calix.com/ns/exa/base"><category>ARC</category></show-alarm-instances-suppressed-subscope></rpc>]]>]]>
    ...         '${alarm}' == 'archive_alarm_application_suspended'      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-filter xmlns="http://www.calix.com/ns/exa/base"><name>application-suspended</name></show-alarm-instances-archive-filter></rpc>]]>]]>
    ...         '${alarm}' == 'active_alarm_ntp_prov'          <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><name>ntp-prov</name></show-alarm-instances-active-subscope></rpc>]]>]]>
    ...         '${alarm}' == 'definition_alarm_ntp_prov'         <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-definitions-subscope xmlns="http://www.calix.com/ns/exa/base"><name>ntp-prov</name></show-alarm-definitions-subscope></rpc>]]>]]>
    ...         '${alarm}' == 'history_alarm_ntp_prov'           <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-history-filter xmlns="http://www.calix.com/ns/exa/base"><name>ntp-prov</name></show-alarm-instances-history-filter></rpc>]]>]]>
    ...         '${alarm}' == 'suppress_alarm_ntp_prov'          <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-suppressed-subscope xmlns="http://www.calix.com/ns/exa/base"><category>NTP</category></show-alarm-instances-suppressed-subscope></rpc>]]>]]>
    ...         '${alarm}' == 'archive_alarm_ntp_prov'          <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-filter xmlns="http://www.calix.com/ns/exa/base"><name>ntp-prov</name></show-alarm-instances-archive-filter></rpc>]]>]]>

    ${result}     Netconf Raw      ${device}      xml=${command}
    Run Keyword If  '${parameter}' == 'name' and ('${alarm}' == 'active_alarm_running_config_unsaved' or '${alarm}' == 'definition_alarm_running_config_unsaved' or '${alarm}' == 'history_alarm_running_config_unsaved' or '${alarm}' == 'archive_alarm_running_config_unsaved' or '${alarm}' == 'suppress_alarm_running_config_unsaved')      Should Contain    ${result.xml}     <name>running-config-unsaved</name>
    ...        ELSE IF     '${parameter}' == 'name' and ('${alarm}' == 'active_alarm_rmon_session' or '${alarm}' == 'definition_alarm_rmon_session' or '${alarm}' == 'history_alarm_rmon_session' or '${alarm}' == 'archive_alarm_rmon_session' or '${alarm}' == 'suppress_alarm_rmon_session')     Should Contain    ${result.xml}     <name>ethernet-rmon-session-stopped</name>
    ...        ELSE IF     '${parameter}' == 'name' and ('${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')       Should Contain    ${result.xml}     <name>ntp-prov</name>
    ...        ELSE IF     '${parameter}' == 'description' and ('${alarm}' == 'active_alarm_running_config_unsaved' or '${alarm}' == 'definition_alarm_running_config_unsaved' or '${alarm}' == 'history_alarm_running_config_unsaved' or '${alarm}' == 'archive_alarm_running_config_unsaved' or '${alarm}' == 'suppress_alarm_running_config_unsaved')    Should Contain    ${result.xml}     <description>Configuration data has changes that have not been saved to the startup-config.  Rebooting the system without saving, will result in the unsaved changes being lost</description>
    ...        ELSE IF     '${parameter}' == 'description' and ('${alarm}' == 'active_alarm_rmon_session' or '${alarm}' == 'definition_alarm_rmon_session' or '${alarm}' == 'history_alarm_rmon_session' or '${alarm}' == 'archive_alarm_rmon_session' or '${alarm}' == 'suppress_alarm_rmon_session')     Should Contain    ${result.xml}        <description>Ethernet port rmon-session has been stopped</description>
    ...        ELSE IF     '${parameter}' == 'description' and ('${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')       Should Contain    ${result.xml}     <description>This alarm is to indicate that NTP is not provisioned</description>
    ...        ELSE IF     '${parameter}' == 'alarm_type' and ('${alarm}' == 'active_alarm_running_config_unsaved' or '${alarm}' == 'definition_alarm_running_config_unsaved' or '${alarm}' == 'history_alarm_running_config_unsaved' or '${alarm}' == 'archive_alarm_running_config_unsaved' or '${alarm}' == 'suppress_alarm_running_config_unsaved' or '${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')    Should Contain    ${result.xml}     <alarm-type>PROCESSING-ERROR</alarm-type>
    ...        ELSE IF     '${parameter}' == 'alarm_type' and ('${alarm}' == 'active_alarm_rmon_session' or '${alarm}' == 'definition_alarm_rmon_session' or '${alarm}' == 'history_alarm_rmon_session' or '${alarm}' == 'archive_alarm_rmon_session' or '${alarm}' == 'suppress_alarm_rmon_session')     Should Contain    ${result.xml}           <alarm-type>COMMUNICATION</alarm-type>
    ...        ELSE IF     '${parameter}' == 'probable_cause' and ('${alarm}' == 'active_alarm_rmon_session' or '${alarm}' == 'definition_alarm_rmon_session' or '${alarm}' == 'history_alarm_rmon_session' or '${alarm}' == 'archive_alarm_rmon_session' or '${alarm}' == 'suppress_alarm_rmon_session')     Should Contain    ${result.xml}       <probable-cause>User action disabled the session</probable-cause>
    ...        ELSE IF     '${parameter}' == 'probable_cause' and ('${alarm}' == 'active_alarm_application_suspended' or '${alarm}' == 'definition_alarm_application_suspended' or '${alarm}' == 'history_alarm_application_suspended' or '${alarm}' == 'suppress_alarm_application_suspended' or '${alarm}' == 'archive_alarm_application_suspended')     Should Contain    ${result.xml}        <probable-cause>Application crashed or locked up more than three times in 5 minutes</probable-cause>
    ...        ELSE IF     '${parameter}' == 'probable_cause' and ('${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')       Should Contain    ${result.xml}     <probable-cause>NTP is not provisioned</probable-cause>
    ...        ELSE IF     '${parameter}' == 'repair_action' and ('${alarm}' == 'active_alarm_running_config_unsaved' or '${alarm}' == 'definition_alarm_running_config_unsaved' or '${alarm}' == 'history_alarm_running_config_unsaved' or '${alarm}' == 'archive_alarm_running_config_unsaved' or '${alarm}' == 'suppress_alarm_running_config_unsaved')      Should Contain    ${result.xml}     <repair-action>copy running-configuration to startup-configuration</repair-action>
    ...        ELSE IF     '${parameter}' == 'repair_action' and ('${alarm}' == 'active_alarm_rmon_session' or '${alarm}' == 'definition_alarm_rmon_session' or '${alarm}' == 'history_alarm_rmon_session' or '${alarm}' == 'archive_alarm_rmon_session' or '${alarm}' == 'suppress_alarm_rmon_session')     Should Contain    ${result.xml}        <repair-action>Re-enable the session when needed</repair-action>
    ...        ELSE IF     '${parameter}' == 'repair_action' and ('${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')       Should Contain    ${result.xml}     <repair-action>Provision NTP</repair-action>
    ...        ELSE IF     '${parameter}' == 'service_impact' and ('${alarm}' == 'active_alarm_running_config_unsaved' or '${alarm}' == 'definition_alarm_running_config_unsaved' or '${alarm}' == 'history_alarm_running_config_unsaved' or '${alarm}' == 'archive_alarm_running_config_unsaved' or '${alarm}' == 'suppress_alarm_running_config_unsaved')      Should Contain    ${result.xml}     <service-impacting>TRUE</service-impacting>
    ...        ELSE IF     '${parameter}' == 'service_impact' and ('${alarm}' == 'active_alarm_rmon_session' or '${alarm}' == 'definition_alarm_rmon_session' or '${alarm}' == 'history_alarm_rmon_session' or '${alarm}' == 'archive_alarm_rmon_session' or '${alarm}' == 'suppress_alarm_rmon_session' or '${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')     Should Contain    ${result.xml}        <service-impacting>FALSE</service-impacting> 
    ...        ELSE IF     '${parameter}' == 'service_affect' and ('${alarm}' == 'active_alarm_running_config_unsaved' or '${alarm}' == 'definition_alarm_running_config_unsaved' or '${alarm}' == 'history_alarm_running_config_unsaved' or '${alarm}' == 'archive_alarm_running_config_unsaved' or '${alarm}' == 'suppress_alarm_running_config_unsaved')      Should Contain    ${result.xml}     <service-affecting>TRUE</service-affecting>
    ...        ELSE IF     '${parameter}' == 'service_affect' and ('${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')      Should Contain    ${result.xml}     <service-affecting>FALSE</service-affecting>
    ...        ELSE IF     '${parameter}' == 'address' and ('${alarm}' == 'active_alarm_running_config_unsaved' or '${alarm}' == 'definition_alarm_running_config_unsaved' or '${alarm}' == 'history_alarm_running_config_unsaved' or '${alarm}' == 'archive_alarm_running_config_unsaved' or '${alarm}' == 'suppress_alarm_running_config_unsaved')      Should Contain    ${result.xml}     <address>/config/system</address>
    ...        ELSE IF     '${parameter}' == 'address' and ('${alarm}' == 'active_alarm_ntp_prov' or '${alarm}' == 'definition_alarm_ntp_prov' or '${alarm}' == 'history_alarm_ntp_prov' or '${alarm}' == 'archive_alarm_ntp_prov')      Should Contain    ${result.xml}     <address>/config/system/ntp</address>


Verify Suppressing Alarms
    [Arguments]    ${device}    ${parameter}    ${command_execution}
    [Documentation]     Verify Suppressing Alarms
    [Tags]        @author=ssekar

    ${command}   Set Variable If    '${command_execution}' == 'suppressed_alarm_loss_of_signal'   show alarm suppressed subscope category PORT
    ...          '${command_execution}' == 'suppressed_alarm_rmon_session'   show alarm suppressed subscope category GENERAL
    ${result}    cli    ${device}    ${command}      timeout=90
    @{local_total_count}       Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${local_total_count}    Get From List    ${local_total_count}    0
    ${local_total_count}    Convert To Integer    ${local_total_count}
    Should Not Be Equal As Integers    ${local_total_count}    0

    Log   *** Suppression of Active alarms ***
    Run Keyword If  '${parameter}' == 'description' and '${command_execution}' == 'suppressed_alarm_loss_of_signal'   Should Contain   ${result}   description loss of signal
    Run Keyword If  '${parameter}' == 'description' and '${command_execution}' == 'suppressed_alarm_rmon_session'   Should Contain   ${result}   description Ethernet port rmon-session has been stopped
    Run Keyword If  '${parameter}' == 'name' and '${command_execution}' == 'suppressed_alarm_loss_of_signal'   Should Contain   ${result}    name loss-of-signal
    Run Keyword If  '${parameter}' == 'name' and '${command_execution}' == 'suppressed_alarm_rmon_session'   Should Contain   ${result}   name ethernet-rmon-session-stopped
    Run Keyword If  '${parameter}' == 'alarm_type'    Should Contain   ${result}    alarm-type COMMUNICATION
    Run Keyword If  '${parameter}' == 'probable_cause' and '${command_execution}' == 'suppressed_alarm_loss_of_signal'   Should Contain   ${result}   probable-cause This alarm is set when there is no signal present on an enabled ethernet interface
    Run Keyword If  '${parameter}' == 'probable_cause' and '${command_execution}' == 'suppressed_alarm_rmon_session'   Should Contain   ${result}   probable-cause User action disabled the session
    Run Keyword If  '${parameter}' == 'repair_action' and '${command_execution}' == 'suppressed_alarm_loss_of_signal'   Should Contain   ${result}    repair-action Ensure that the physical interface is properly connected and is receiving a valid signal from the far end
    Run Keyword If  '${parameter}' == 'repair_action' and '${command_execution}' == 'suppressed_alarm_rmon_session'   Should Contain   ${result}    repair-action Re-enable the session when needed
    Run Keyword If  '${parameter}' == 'category' and '${command_execution}' == 'suppressed_alarm_loss_of_signal'   Should Contain   ${result}     category                   PORT
    Run Keyword If  '${parameter}' == 'category' and '${command_execution}' == 'suppressed_alarm_rmon_session'   Should Contain   ${result}    category                   GENERAL
     Run Keyword If  '${parameter}' == 'service_impact' and '${command_execution}' == 'suppressed_alarm_loss_of_signal'   Should Contain   ${result}     service-impacting          TRUE
    Run Keyword If  '${parameter}' == 'service_impact' and '${command_execution}' == 'suppressed_alarm_rmon_session'   Should Contain   ${result}    service-impacting          FALSE
    Run Keyword If  '${parameter}' == 'service_affect' and '${command_execution}' == 'suppressed_alarm_rmon_session'   Should Contain   ${result}    service-affecting          FALSE

Suppressing Active alarms
    [Arguments]    ${device}
    [Documentation]   Suppressing Active alarms
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show inventory    prompt=\\#      timeout=90
    ${suppress}    Set Variable If    ${result.__contains__('${hostname}')}==True    alarm-suppression ENABLED
    ...         ${result.__contains__('E5-520')}==True     suppress TRUE
    cli    ${device}   configure     timeout=90
    cli    ${device}   ${suppress}
    cli    ${device}   end
    ${total_count}    Getting Active alarms total count    ${device}
    Should Be Equal As Integers   ${total_count}   0
    ${result}    cli    ${device}    show alarm suppressed | include total-count    timeout=30
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    ${total_count}    Convert To Integer    ${total_count}

Suppressing Active alarms using netconf
    [Arguments]    ${device}
    [Documentation]   Suppressing Active alarms
    [Tags]        @author=ssekar
    ${get_interface_by_inventory_check}   Netconf Raw    ${device}    xml=<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter xmlns="http://www.calix.com/ns/exa/base"><status><system><inventory/></system></status></filter></get></rpc>]]>]]>
    ${str}      Convert to string     ${get_interface_by_inventory_check}
    ${suppress}    Set Variable If    ${str.__contains__('${hostname}')}==True   <alarm-suppression>ENABLED</alarm-suppression>    <suppress>TRUE</suppress>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base">${suppress}</config></config></edit-config></rpc>]]>]]>
    ${total_count}    Getting Active alarms total count using netconf    ${device}
    Should Be Equal As Integers   ${total_count}   0
    ${result}     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/suppressed"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    ${total_count}    Convert To Integer    ${total_count}
    [Return]    ${total_count}

Unsuppressing Active alarms using netconf
    [Arguments]    ${device}
    [Documentation]   Unsuppressing Active alarms
    [Tags]        @author=ssekar
    ${get_interface_by_inventory_check}   Netconf Raw    ${device}    xml=<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter xmlns="http://www.calix.com/ns/exa/base"><status><system><inventory/></system></status></filter></get></rpc>]]>]]>
    ${str}      Convert to string     ${get_interface_by_inventory_check}
    ${suppress}    Set Variable If    ${str.__contains__('${hostname}')}==True   <alarm-suppression>DISABLED</alarm-suppression>    <suppress>FALSE</suppress>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base">${suppress}</config></config></edit-config></rpc>]]>]]>
    ${result}     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/suppressed"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    ${total_count}    Convert To Integer    ${total_count}
    Should Be Equal As Integers   ${total_count}   0

Unsuppressing Active alarms
    [Arguments]    ${device}
    [Documentation]   Unsuppressing Active alarms
    [Tags]        @author=ssekar
    ${result}    cli    ${device}    show inventory    prompt=\\#       timeout=10
    ${unsuppress}    Set Variable If    ${result.__contains__('${hostname}')}==True    alarm-suppression DISABLED
    ...         ${result.__contains__('E5-520')}==True     suppress FALSE
    cli    ${device}   configure
    cli    ${device}   ${unsuppress}
    cli    ${device}   end
    ${result}    cli    ${device}    show alarm suppressed | include total-count    timeout=30
    @{result}    Get Regexp Matches    ${result}    total-count ([0-9]+)    1
    ${total_count}    Get From List    ${result}    0
    ${total_count}    Convert To Integer    ${total_count}
    Should Be Equal As Integers   ${total_count}   0

Shelving Active alarms
    [Arguments]    ${device}     ${parameter}=None    ${command_execution}=None     ${un-shelve}=None     ${shelve}=None    ${unshelve_instanceid}=None
    [Documentation]   Shelving Active alarms
    [Tags]        @author=ssekar

    ${command}   Set Variable If     '${command_execution}' == 'shelved_runningconfig_unsaved'     show alarm active subscope name running-config-unsaved
    ...          '${command_execution}' == 'shelved_alarm_rmon_session'  show alarm active subscope name ethernet-rmon-session-stopped
    ...          '${command_execution}' == 'shelved_ntp_prov'      show alarm active subscope name ntp-prov
    ...          '${command_execution}' == 'shelved_app_sus'       show alarm active subscope name application-suspended

    Log    *** Getting instance-id from triggered active alarm ***
    ${result}    cli    ${device}     ${command}      timeout=90
    @{result}    Get Regexp Matches    ${result}    instance-id ([0-9.]+)    1
    ${instance1}    Get From List    ${result}    0
    Run Keyword If    '${shelve}' == 'None'       cli    ${device}   manual shelve instance-id ${instance1}      timeout=90
    #Sleep for 5s
    #${shelved_time}     Getting Alarm or event time from DUT     ${device}     ${instance1}
    ${shelved_time}     Get DUT current time   ${device}
    ${result}    Run Keyword If    '${shelve}' == 'None'    cli    ${device}     show alarm shelved      timeout=90
    Run Keyword If    '${shelve}' == 'None'    Should Contain      ${result}           manual-shelve              TRUE
    Run Keyword If    '${parameter}' == 'description' and '${command_execution}' == 'shelved_runningconfig_unsaved'   Acknowledging_and_Shelving_alarm_description   ${result}
    Run Keyword If    '${parameter}' == 'name' and '${command_execution}' == 'shelved_runningconfig_unsaved'   Acknowledging_and_Shelving_alarm_name   ${result}
    Run Keyword If    '${parameter}' == 'name' and '${command_execution}' == 'shelved_ntp_prov'     Should Contain    ${result}    name                       ntp-prov
    Run Keyword If    '${parameter}' == 'name' and '${command_execution}' == 'shelved_app_sus'    Should Contain    ${result}    name                       application-suspended
    Run Keyword If    '${parameter}' == 'alarm_type' and '${command_execution}' == 'shelved_runningconfig_unsaved'   Acknowledging_and_Shelving_alarm_type   ${result}
    Run Keyword If    '${parameter}' == 'probable_cause' and '${command_execution}' == 'shelved_ntp_prov'    Should Contain    ${result}     probable-cause             "NTP is not provisioned"
    Run Keyword If    '${parameter}' == 'probable_cause' and '${command_execution}' == 'shelved_alarm_rmon_session'  Acknowledging_and_Shelving_alarm_probable_cause     ${result}
    Run Keyword If    '${parameter}' == 'repair_action' and '${command_execution}' == 'shelved_runningconfig_unsaved'   Acknowledging_and_Shelving_alarm_repair_action      ${result}
    Run Keyword If    '${parameter}' == 'severity' and '${command_execution}' == 'shelved_runningconfig_unsaved'    Acknowledging_and_Shelving_alarm_severity     ${result}
    Run Keyword If    '${parameter}' == 'category' and '${command_execution}' == 'shelved_runningconfig_unsaved'     Should Contain    ${result}    category                   CONFIGURATION
    Run Keyword If    '${parameter}' == 'service_impact' and '${command_execution}' == 'shelved_runningconfig_unsaved'     Should Contain    ${result}    service-impacting          TRUE
    Run Keyword If    '${parameter}' == 'instance-id' and '${command_execution}' == 'shelved_runningconfig_unsaved'     Should Contain    ${result}    instance-id                ${instance1}
    Run Keyword If    '${parameter}' == 'service_affect' and '${command_execution}' == 'shelved_runningconfig_unsaved'     Should Contain    ${result}    service-affecting          TRUE
    Run Keyword If    '${parameter}' == 'address' and '${command_execution}' == 'shelved_runningconfig_unsaved'     Should Contain    ${result}    address                    /config/system
    Run Keyword If    '${parameter}' == 'address' and '${command_execution}' == 'shelved_ntp_prov'      Should Contain    ${result}    address                    /config/system/ntp
    # Sleep for 7s
    Sleep     7s
    Run Keyword If    '${un-shelve}' == 'None'     cli    ${device}   manual un-shelve instance-id ${instance1}      timeout=90
    ...    ELSE IF     '${un-shelve}' == 'True' and '${unshelve_instanceid}' != 'None'     cli    ${device}   manual un-shelve instance-id ${unshelve_instanceid}    timeout=90
    ${un_shelved_time}       Run Keyword If    '${un-shelve}' == 'True' or '${un-shelve}' == 'None'      Get DUT current time     ${device}
    #${un_shelved_time}     Run Keyword If    '${un-shelve}' == 'True' or '${un-shelve}' == 'None'     Getting Alarm or event time from DUT     ${device}  
    #...      ${instance1}
    # Sleep for 7s
    Run Keyword If    '${un-shelve}' == 'None'     Sleep     7s
    Run Keyword If    '${parameter}' == 'list'      Return From Keyword     ${instance1}     ${shelved_time}     ${un_shelved_time} 
    Run Keyword If    '${parameter}' == 'list' and '${un-shelve}' == 'True'         Return From Keyword     ${unshelve_instanceid}      ${un_shelved_time}

Verify cleared alarm removed from shelved
    [Arguments]    ${device}     ${instance-id}
    [Documentation]   Verify cleared alarm removed from shelved
    [Tags]        @author=ssekar

    ${result}   cli     ${device}     show alarm shelved      timeout=120
    Should Not Contain      ${result}     instance-id                ${instance-id}
    
Verify cleared alarm removed from shelved using netconf
    [Arguments]    ${device}     ${instance-id}
    [Documentation]   Verify cleared alarm removed from shelved
    [Tags]        @author=ssekar

    ${result}   Netconf Raw      ${device}      xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/shelved"/></get></rpc>]]>]]>
    Should Not Contain      ${result.xml}      <instance-id>${instance-id}</instance-id>

Shelving Active alarms using netconf
    [Arguments]    ${device}     ${parameter}=None    ${alarm}=None     ${un-shelve}=None
    [Documentation]   Shelving Active alarms
    [Tags]        @author=ssekar

    ${command}   Set Variable If     '${alarm}' == 'shelve_alarm_application_suspended'     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>1702</id></show-alarm-instances-active-subscope></rpc>]]>]]>         <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"><id>702</id></show-alarm-instances-active-subscope></rpc>]]>]]>

    ${show_alarm}=    Netconf Raw    n1_netconf    xml=${command}
    Run Keyword If    '${alarm}' != 'shelve_alarm_application_suspended'      Should contain    ${show_alarm.xml}     <id>702</id>
    Run Keyword If    '${alarm}' == 'shelve_alarm_application_suspended'      Should contain    ${show_alarm.xml}     <id>1702</id>
    Log    ${show_alarm.xml}
    ${str}=    Convert to string    ${show_alarm}
    ${instanceid}=    Get Lines Containing String    ${str}    instance-id
    ${first}=    Get Regexp Matches    ${instanceid}    <instance-id>([0-9.]+)</instance-id>    1
    ${instance_id}    Get From List    ${first}    0
    Log      *** Shelving the alarm ***
    ${result}     Netconf Raw    n1_netconf    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><manual-shelve xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></manual-shelve></rpc>]]>]]>
    ${shelved_time}     Get DUT current time using netconf   ${device}
    ${result}     Netconf Raw    n1_netconf    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/shelved"/></get></rpc>]]>]]>
    Should Contain     ${result.xml}     <manual-shelve>TRUE</manual-shelve>
    Run Keyword If    '${parameter}' == 'severity'     Should Contain     ${result.xml}     <perceived-severity>INFO</perceived-severity>
    Run Keyword If    '${parameter}' == 'name'     Should Contain     ${result.xml}     <name>running-config-unsaved</name>
    Run Keyword If    '${parameter}' == 'description'      Should Contain     ${result.xml}     <description>Configuration data has changes that have not been saved to the startup-config.  Rebooting the system without saving, will result in the unsaved changes being lost</description>
    Run Keyword If    '${parameter}' == 'alarm_type'      Should Contain     ${result.xml}      <alarm-type>PROCESSING-ERROR</alarm-type>
    Run Keyword If    '${parameter}' == 'probable_cause'     Should Contain     ${result.xml}      <probable-cause>Application crashed or locked up more than three times in 5 minutes</probable-cause>
    Run Keyword If    '${parameter}' == 'repair_action'     Should Contain     ${result.xml}      <repair-action>copy running-configuration to startup-configuration</repair-action>
    Run Keyword If    '${parameter}' == 'category'     Should Contain     ${result.xml}       <category>CONFIGURATION</category>
    Run Keyword If    '${parameter}' == 'instance-id'    Should Contain     ${result.xml}       <instance-id>${instanceid}</instance-id>
    Run Keyword If    '${parameter}' == 'service_impact'   Should Contain     ${result.xml}       <service-impacting>TRUE</service-impacting>
    Run Keyword If    '${parameter}' == 'service_affect'   Should Contain     ${result.xml}       <service-affecting>TRUE</service-affecting>    
    Run Keyword If    '${parameter}' == 'address'   Should Contain     ${result.xml}       <address>/config/system</address>

    Log      *** Un-shelving the alarm ***
    # Sleep for 7s
    Sleep     7s
    Run Keyword If    '${un-shelve}' == 'None'    Netconf Raw    n1_netconf    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><manual-un-shelve xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></manual-un-shelve></rpc>]]>]]>
    ${un_shelved_time}       Run Keyword If      '${un-shelve}' == 'None'      Get DUT current time using netconf     ${device}
    Run Keyword If    '${un-shelve}' == 'None'    Sleep     7s

    ${un_shelve}     Run Keyword If    '${un-shelve}' == 'None'    Netconf Raw    n1_netconf    xml=${command}
    Run Keyword If    '${un-shelve}' == 'None'    Should Contain     ${un_shelve.xml}      <manual-shelve>FALSE</manual-shelve>
    Run Keyword If    '${parameter}' == 'list'      Return From Keyword     ${instance_id}     ${shelved_time}     ${un_shelved_time}

Clearing Archive alarm
    [Arguments]    ${device}
    [Documentation]  Clearing Archive alarm
    [Tags]        @author=ssekar
    cli    ${device}    clear archive alarm-log     timeout=90
    ${result}    cli    ${device}     show alarm archive      timeout=90
    Result Should Contain    total-count 0

Clearing Archive alarm using netconf
    [Arguments]    ${device}
    [Documentation]  Clearing Archive alarm using netconf
    [Tags]        @author=ssekar
    Netconf Raw    ${device}    xml=<rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><archive-alarm-log xmlns="http://www.calix.com/ns/exa/base"/></rpc>]]>]]>
    ${result}     Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/system/alarm/archive"/></get></rpc>]]>]]>
    ${str}=    Convert to string    ${result}
    ${total_count}   Get Regexp Matches     ${str}    <total-count>([0-9]+)</total-count>    1
    ${total_count}    Get From List    ${total_count}   0
    ${total_count}    Convert To Integer    ${total_count}
    Should Be Equal As Integers   ${total_count}   0

# Reload The System
#    [Arguments]    ${device}    ${linux}=None
#   [Documentation]    Performs a system reload and confirms reload occurs.
#    [Tags]    @author=ssekar
#    cli    ${device}    accept running-config     timeout=90
#    cli    ${device}    copy run start       timeout=90
#    cli    ${device}    reload    prompt=]      timeout=90
# #    cli    ${device}    reload all    prompt=]      timeout=90
#    Result Should Contain    Proceed with reload
#   Result Should Contain    The system is going down for reboot NOW!
#    #Sleep for 250s until DUT comes UP
#    Sleep    250 
#    Run Keyword If     '${linux}' != 'None'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${linux}
#    Wait Until Keyword Succeeds      2 min     10 sec      caferobot.command.adapter.CliAdapter.Login      ${device}


Reload The System using netconf
    [Arguments]    ${device}      ${linux}=None
    [Documentation]    Performs a system reload and confirms reload occurs.
    [Tags]    @author=ssekar
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
    Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><reload xmlns="http://www.calix.com/ns/exa/base"></reload></rpc>]]>]]>
    #Sleep for 250s until DUT comes UP
    Log      The system is going down for reboot NOW!
    Sleep    250
    wait until keyword succeeds    10 min    1 min    keyword_common.ping_device   h1    ${DEVICES.n1_sh.ip}
    Run Keyword If     '${linux}' != 'None'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect    ${linux}
    #Sleep for 5s
    Sleep     5


Acknowledging_and_Shelving_alarm_name
    [Arguments]    ${result}
    [Documentation]    Acknowledging_and_Shelving_alarm_name
    [Tags]        @author=ssekar

    Should Contain     ${result}     name                       running-config-unsaved

Acknowledging_and_Shelving_alarm_description
    [Arguments]    ${result}
    [Documentation]    Acknowledging and shelving alarm description
    [Tags]        @author=ssekar

    Should Contain     ${result}    description                "Configuration data has changes that have not been saved to the startup-config.  Rebooting the system without saving, will result in the unsaved changes being lost"

Acknowledging_and_Shelving_alarm_type
    [Arguments]    ${result}
    [Documentation]    Acknowledging and shelving alarm type
    [Tags]        @author=ssekar

    Should Contain     ${result}    alarm-type                 PROCESSING-ERROR

Acknowledging_and_Shelving_alarm_probable_cause
    [Arguments]    ${result}
    [Documentation]    Acknowledging and shelving alarm probable cause
    [Tags]        @author=ssekar

    Should Contain     ${result}    probable-cause             "User action disabled the session"

Acknowledging_and_Shelving_alarm_repair_action
    [Arguments]    ${result}
    [Documentation]    Acknowledging and shelving alarm repair action
    [Tags]        @author=ssekar

    Should Contain     ${result}    repair-action              "copy running-configuration to startup-configuration"

Acknowledging_and_Shelving_alarm_severity
    [Arguments]    ${result}
    [Documentation]    Acknowledging and shelving alarm severity
    [Tags]        @author=ssekar

    Should Contain     ${result}    perceived-severity         INFO


Closing existing netconf connections
    [Arguments]       ${linux}     ${netconf_username}
    [Documentation]  Closing existing netconf connections
    [Tags]        @author=ssekar    

    Wait Until Keyword Succeeds    2 min     10 sec         Disconnect     ${linux}
    Wait Until Keyword Succeeds    2 min     10 sec         cli      ${linux}      cd /var         timeout_exception=0       timeout=120 
    : FOR    ${INDEX}    IN RANGE    0    800
    \     ${result}    Wait Until Keyword Succeeds    2 min     10 sec         cli      ${linux}      ps -ef | grep netconf        timeout_exception=0       timeout=120    prompt=var
    \     ${result}     Get Lines Containing String       ${result}        /opt/confd/bin/netconf-subsys
    \     ${process_id}     Get Regexp Matches     ${result}        ${netconf_username}\\s*([0-9]+)      1
    \     ${len}     Get Length      ${process_id}
    \     ${process_id}     Run Keyword If   ${len} != 0    Get From List    ${process_id}     0
    \     Run Keyword If   ${len} != 0    cli      ${linux}      kill -9 ${process_id}        timeout_exception=0       timeout=120     prompt=var
    #Sleep for 8s after killing all netconf sessions
    \     BuiltIn.Sleep    8s
    \     ${result}     cli      ${linux}      ps -ef | grep netconf        timeout_exception=0       timeout=120      prompt=var
    \     ${result}     Get Lines Containing String       ${result}        /opt/confd/bin/netconf-subsys
    \     ${line_count}     Get Line Count     ${result}
    \     Exit For Loop If    ${line_count} == 0

Verifying_Event_subscription_filter
    [Arguments]       ${device_ip}        ${username}      ${password}    ${ssh_port}      ${local_pc_ip}      ${device_netconf}   ${port}     ${device_linux}
    [Documentation]     Verifying subscribed events can be filtered and notified
    [Tags]        @author=ssekar

    ${connection}     Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact></contact></system></config></config></edit-config></rpc>]]>]]>
    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
    Alarm_subscription_netconf      parameter=without_filter
    #Sleep for 5s after Alarm subscription
    Sleep    5s
    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact>Ero1</contact></system></config></config></edit-config></rpc>]]>]]>
    #Sleep for 5s after triggering Alarm
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </db-change>
    Log      ${output}
    Should Contain      ${output}        <new-value>Ero1</new-value>
    Should Contain      ${output}        <category>DBCHANGE</category>
    SSHLibrary.Close All Connections

    Log    *** Subscribing severity MAJOR and specific category NTP ***
    Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    Alarm_subscription_netconf      parameter=category_ntp_with_severity_major
    Log    *** Trigerring MAJOR alarm with NTP category ***
    Wait Until Keyword Succeeds      2 min     10 sec     Trigerring NTP prov alarm netconf       ${device_netconf}
    ${output}       SSHLibrary.Read Until     </ntp-prov>
    Log      ${output}
    Should Contain      ${output}        <perceived-severity>MAJOR</perceived-severity>
    Should Contain      ${output}        <category>NTP</category>
    Should Contain      ${output}        <description>This alarm is to indicate that NTP is not provisioned</description>
    Log    *** Trigerring MAJOR alarm with PORT category ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering Loss of Signal MAJOR alarm    device=${device_netconf}         user_interface=netconf 
    ${output}       SSHLibrary.Read      delay=30s
    Log      ${output}
    #Should Not Contain      ${output}        <perceived-severity>MAJOR</perceived-severity>
    Should Not Contain      ${output}        <category>PORT</category>
    Should Not Contain      ${output}        <description>loss of signal</description>
    Log    *** Clearing MAJOR alarm with NTP category ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm netconf       ${device_netconf}
    ${output}       SSHLibrary.Read      delay=30s
    Log      ${output}
    Should Not Contain      ${output}        <perceived-severity>CLEAR</perceived-severity>
    SSHLibrary.Close All Connections

Verifying_Event_subscription_max
    [Arguments]       ${device_ip}        ${username}      ${password}    ${ssh_port}      ${local_pc_ip}      ${device_netconf}   ${port}     ${device_linux}   
    ...               ${device}
    [Documentation]     Verifying DUT must support the ability to configure at least 8 distinct event subscriptions and errors out when exceeded
    [Tags]        @author=ssekar
  
    Log    *** Event notification for DBCHANGE ***
    : FOR    ${INDEX}    IN RANGE    1      9
    \    ${connection}     Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    \    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact></contact></system></config></config></edit-config></rpc>]]>]]>
    \    Alarm_subscription_netconf      parameter=dbchange
    \    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    \    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
    \    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact>Ero1</contact></system></config></config></edit-config></rpc>]]>]]>
    #Sleep for 5s until Netconf notification been captured
    \    Sleep    5s
    \    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    \    Log      ${output}
    \    Should Contain      ${output}        <new-value>Ero1</new-value>
    \    Should Contain      ${output}        <category>DBCHANGE</category> 
    \    ${session}     Wait Until Keyword Succeeds      2 min     10 sec     cli    ${device}
    \    ...     show user-sessions session session-manager netconf | include session-id     timeout=50     timeout_exception=0
    \    ${line1}    Get Regexp Matches    ${session}    session-id\\s*([0-9]+)    1
    \    ${count1}    Get Length    ${line1}
    \    Log     ${INDEX}
    \    Exit For Loop If     ${count1} == 8

    ${total}     SSHLibrary.Get Connections    
    Log   ${total}
    ${len}    Get Length     ${total}
    ${Exceeded_connection}    Run Keyword If    ${count1} == 8      SSHLibrary.Open Connection       ${device_ip}       port=${ssh_port}     prompt=closing session
    ${result}    Run Keyword If    ${count1} == 8      SSHLibrary.Login       ${username}     ${password}    delay=10 seconds
    Log    ${result}
    Run Keyword If    ${count1} == 8     Should Contain       ${result}       Error: Too many sessions
    #SSHLibrary.Close All Connections

Verifying_Event_multiple_subscription
    [Arguments]       ${device_ip}        ${username}      ${password}    ${ssh_port}      ${local_pc_ip}      ${device_netconf}   ${port}     ${device_linux}
    ...                 ${device}
    [Documentation]     Verifying DUT must support the ability to configure at least 8 distinct event subscriptions and errors out when exceeded
    [Tags]        @author=ssekar

    Log    *** Event notification for DBCHANGE ***
    : FOR    ${TOTAL_INDEX}    IN RANGE    1      9
    \    ${connection}     Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    \    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact></contact></system></config></config></edit-config></rpc>]]>]]>
    \    Alarm_subscription_netconf      parameter=dbchange
    \    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    \    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
    \    ${session}     Wait Until Keyword Succeeds      2 min     10 sec     cli    ${device}     
    \    ...     show user-sessions session session-manager netconf | include session-id     timeout=50     timeout_exception=0   
    \    ${line1}    Get Regexp Matches    ${session}    session-id\\s*([0-9]+)    1
    \    ${count1}    Get Length    ${line1}
    \    Log     ${TOTAL_INDEX}
    \    Exit For Loop If     ${count1} == 8
    

    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact>Ero1</contact></system></config></config></edit-config></rpc>]]>]]>

    Log     *** Modifying configuration while notifications are sent ***
    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><contact>Ero12</contact></system></config></config></edit-config></rpc>]]>]]>

    #Sleep for 7s until Netconf notification been captured
    Sleep    7s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log      ${output}
    Should Contain      ${output}        <category>DBCHANGE</category>
    : FOR    ${INDEX}    IN RANGE    1      ${TOTAL_INDEX}
    \     SSHLibrary.Switch Connection      ${INDEX}
    \     ${output1}      SSHLibrary.Read Until     </notification>]]>]]>
    \     Log      ${output1}
    \     Should Contain      ${output1}     <category>DBCHANGE</category>
    ${total}     SSHLibrary.Get Connections
    Log   ${total}
    ${len}    Get Length     ${total}
    ${Exceeded_connection}    Run Keyword If    ${count1} == 8      SSHLibrary.Open Connection       ${device_ip}       port=${ssh_port}     prompt=closing session
    ${result}    Run Keyword If    ${count1} == 8      SSHLibrary.Login       ${username}     ${password}    delay=10 seconds
    Log    ${result}
    Run Keyword If    ${count1} == 8     Should Contain       ${result}       Error: Too many sessions
    #SSHLibrary.Close All Connections

Multiple_Alarm_Notifications
    [Arguments]       ${device_ip}        ${username}      ${password}    ${ssh_port}      ${local_pc_ip}      ${device_netconf}     ${snmp}    ${snmp_port}    ${linux}    ${local_pc}       ${local_pc_password}     ${cli}
    [Documentation]    verifying multiple Alarm notifications can be sent at the same time
    [Tags]        @author=ssekar

    Closing existing netconf connections      ${linux}      ${username}
    ${connection}     Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    Alarm_subscription_netconf      alarm_severity=CRITICAL     parameter=severity
    Log     ${snmp_port}
    : FOR    ${INDEX}    IN RANGE    1      3
    \     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_start_trap     ${snmp}     ${snmp_port}
    \     Wait Until Keyword Succeeds      2 min     10 sec      Triggering CRITICAL alarm     ${linux}     ${device_netconf}     netconf
    \     ${app_instance_id}       Getting instance-id from Triggered alarms using netconf      ${device_netconf}        app_sus
   
    \     Log     *** Modifying configuration while notifications are sent ***
    \     SSHLibrary.Write      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>false</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    \     SSHLibrary.Write      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>invalid</address></server></ntp></system></config></config></edit-config></rpc>]]>]]> 

    \     Wait Until Keyword Succeeds      2 min     10 sec      Clearing CRITICAL alarm      ${linux}     ${device_netconf}     netconf
    \     @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmp}
    \     ${result}     Get From List     ${result}    0
    \     ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    \     Log      ${output}
    \     Should Contain      ${output}        <perceived-severity>CRITICAL</perceived-severity>
    \     Should Contain      ${output}        <probable-cause>Application crashed or locked up more than three times in 5 minutes</probable-cause>
    \     Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_application_suspended_alarm       ${snmp}     ${result}    ${app_instance_id}
    \     Wait Until Keyword Succeeds      2 min     10 sec         Alarm_application_suspended_recorded_on_syslog_server     ${cli}      ${local_pc}      ${local_pc_ip}      ${local_pc_password}     parameter=alarm_raise
    \     Wait Until Keyword Succeeds    30 seconds    5 seconds    Restarting syslog server on local pc      ${local_pc}      ${local_pc_ip}     ${local_pc_password}
    SSHLibrary.Close All Connections
    ${result}    Netconf Raw    ${device_netconf}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><get><filter xmlns:t="http://www.calix.com/ns/exa/base" type="xpath" select="/status/ntp"/></get></rpc>]]>]]>
    Should Contain     ${result.xml}       <server-addr>invalid</server-addr>

Alarm_subscription_netconf
    [Arguments]        ${alarm_severity}=None     ${parameter}=severity      ${event-name}=None
    [Documentation]    Subscribing to alarms on various severities
    [Tags]        @author=ssekar
    Run Keyword If     '${parameter}' == 'severity'    SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[alarm='true' and perceived-severity='${alarm_severity}']"/></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'dbchange'    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[category='DBCHANGE']"/></create-subscription></rpc> 
    Run Keyword If     '${parameter}' == 'without_filter'    SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'category_ntp_with_severity_major'     SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[category='NTP' and alarm='true' and perceived-severity='MAJOR']"/></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'category_port'      SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[alarm='true' and category='PORT']"/></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'category_dhcp'      SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[alarm='true' and category='DHCP']"/></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'category_environmental'      SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[alarm='true' and category='ENVIRONMENTAL']"/></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'ont-arrival'     SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter><ont-arrival xmlns='http://www.calix.com/ns/exa/gpon-interface-base'></ont-arrival></filter></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'ospf'      SSHLibrary.Write      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter><${event-name} xmlns="http://www.calix.com/ns/router-ospf"/></filter></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'general'      SSHLibrary.Write      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter><${event-name} xmlns="http://www.calix.com/ns/exa/base"/></filter></create-subscription></rpc>]]>]]>
    Run Keyword If     '${parameter}' == 'GENERAL'      SSHLibrary.Write      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[category='GENERAL']"/></create-subscription></rpc>]]>]]>
    ${output}       SSHLibrary.Read Until     <ok/></rpc-reply>]]>]]>
    Log     ${output}

Verifying ONT arrival event gets notified in Netconf
    [Arguments]        ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}      ${device}    ${linux}
    [Documentation]      Verifying ONT arrival event gets notified in Netconf
    [Tags]        @author=ssekar

    ${connection}     Connection_establishment_using_SSHLibrary      ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}
    Alarm_subscription_netconf      parameter=ont-arrival

    Wait Until Keyword Succeeds      2 min     10 sec      Triggering ont-arrival event      ${device}    ${linux}
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </ont-arrival>
    Should Contain      ${output}     <description>ONT has arrived on PON port</description>

Verifying Alarm category DHCP gets notified in Netconf
    [Arguments]        ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}      ${device}    ${linux}
    [Documentation]      Verifying Alarm category DHCP gets notified in Netconf
    [Tags]        @author=ssekar

    ${connection}     Connection_establishment_using_SSHLibrary      ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}
    ...          ${device_netconf}
    Alarm_subscription_netconf      parameter=category_dhcp
    Log    *** Verifying alarms from category DHCP can be triggered and cleared ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     ${device}    ${linux}     source-verify-resources-limited
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </source-verify-resources-limited>
    Should Contain      ${output}     <perceived-severity>MINOR</perceived-severity>

    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli      ${device}    ${linux}     source-verify-resources-limited
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </source-verify-resources-limited>
    Should Contain      ${output}     <perceived-severity>CLEAR</perceived-severity>
    SSHLibrary.Close All Connections

Verifying Event category OSPF gets notified in Netconf
    [Arguments]        ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}      ${device}    ${linux}
    ...                ${port}              ${linux_user}
    [Documentation]      Verifying Event category OSPF gets notified in Netconf
    [Tags]        @author=ssekar

    @{total_events}     Create List     ospf-event-nssa-trans-change     ospf-event-if-auth-failure       ospf-event-if-state-change      ospf-event-nbr-state-change 
    ...                 ospf-event-oper-change

    : FOR    ${event}    IN      @{total_events}
    \        ${connection}     Connection_establishment_using_SSHLibrary      ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}   
    \        ...       ${local_pc_ip}      ${device_netconf}
    \        Alarm_subscription_netconf      parameter=ospf     event-name=${event}
    \        Run Keyword If    '${event}' == 'ospf-event-if-auth-failure' or '${event}' == 'ospf-event-nbr-state-change'
    \        ...       Wait Until Keyword Succeeds      2 min     10 sec        Triggering OSPF event       ${device}     if-auth and nbr-state     
    \        ...       ${port}    ${linux}     ${linux_user}
    \        Run Keyword If    '${event}' == 'ospf-event-oper-change' or '${event}' == 'ospf-event-if-state-change'      Wait Until Keyword Succeeds    2 min    10 sec
    \        ...       Triggering OSPF event       ${device}     if-state nssa-trans and oper-change     ${port}    ${linux}     ${linux_user}      nssa-event=false
    \        Run Keyword If    '${event}' == 'ospf-event-nssa-trans-change'    Wait Until Keyword Succeeds    2 min    10 sec
    \        ...       Triggering OSPF event       ${device}     if-state nssa-trans and oper-change     ${port}    ${linux}     ${linux_user}      nssa-event=true
    #Sleep for 5s
    \    Sleep    5s
    \    ${output}       SSHLibrary.Read Until     </${event}>
    \    Log     ${output}
    \    Should Contain      ${output}     ${event}
    \    SSHLibrary.Close All Connections

Verifying Event category GENERAL gets notified in Netconf
    [Arguments]        ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}      ${device}    ${linux}
    ...                ${port}      ${cisco}     ${cisco_ip}    ${cisco_user}      ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    [Documentation]      Verifying Event category GENERAL gets notified in Netconf
    [Tags]        @author=ssekar

    @{total_events}     Create List     transfer-failed     transfer-aborted      transfer-finished      lldp-neighbor-activity    
    ...     ethernet-rmon-pmdata-cleared       core-file-generated
  
    Log      *** Generating techlog file ***
    ${techlog}    Wait Until Keyword Succeeds      2 min     10 sec        Generating techlog files        ${device}

    : FOR    ${event}    IN      @{total_events}
    \        ${connection}     Connection_establishment_using_SSHLibrary      ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}
    \        ...       ${local_pc_ip}      ${device_netconf}
    \        Run Keyword If    '${event}' == 'transfer-failed' or '${event}' == 'transfer-aborted' or '${event}' == 'transfer-finished'    
    \        ...       Alarm_subscription_netconf      parameter=general     event-name=${event}
    \        ...      ELSE     Alarm_subscription_netconf      parameter=GENERAL
    \        Run Keyword If    '${event}' == 'transfer-failed' or '${event}' == 'transfer-aborted' or '${event}' == 'transfer-finished'
    \        ...      Wait Until Keyword Succeeds      2 min     10 sec        Triggering TRANSFER events       ${device}     ${event}     ${techlog}     ${localpc_ip}
    \        ...      ELSE IF     '${event}' == 'lldp-neighbor-activity'      Wait Until Keyword Succeeds      2 min     10 sec        
    \        ...      Triggering lldp neighbor event between Calix and Cisco         ${device}      ${port}    ${cisco}     ${cisco_ip}    ${cisco_user}
    \        ...      ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    \        ...      ELSE IF     '${event}' == 'ethernet-rmon-pmdata-cleared'       Wait Until Keyword Succeeds      2 min     10 sec
    \        ...      Triggering ethernet-rmon-pmdata-cleared event       ${device}        ${port} 
    \        ...      ELSE     Wait Until Keyword Succeeds      2 min     10 sec     Triggering dcli events        ${device}     ${linux}      ${event}
    #Sleep for 5s
    \    Sleep    5s
    \    ${output}       SSHLibrary.Read Until     </${event}>
    \    Log     ${output}
    \    Should Contain      ${output}     ${event}
    \    SSHLibrary.Close All Connections

Verifying ENVIRONMENTAL Alarms gets notified in Netconf
    [Arguments]        ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}      ${device}    ${linux}
    [Documentation]     Verifying ENVIRONMENTAL Alarms gets notified in Netconf
    [Tags]        @author=ssekar

    ${connection}     Connection_establishment_using_SSHLibrary      ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip} 
    ...       ${device_netconf}
    Alarm_subscription_netconf      parameter=category_environmental

    @{total_alarms}     Create List     environment-input    post_fpga     post_ddr_mem     post_dyad     post_bid     post_sram_memory     post_i2c     post_phy
    ...      post_nor

    Log    *** Verifying ENVIRONMENTAL alarms are triggered and cleared ***
    : FOR    ${alarm}    IN      @{total_alarms}
    \    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli    ${device}    ${linux}     ${alarm}      env=true
    #Sleep for 5s
    \    Sleep    5s
    \    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    \    Log     ${output}
    \    Should Contain      ${output}     ${alarm}
    \    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli       ${device}    ${linux}      ${alarm}       env=true
    #Sleep for 5s
    \    Sleep    5s
    \    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    \    Log     ${output}
    \    Should Contain      ${output}     ${alarm}
    \    Should Contain      ${output}     <perceived-severity>CLEAR</perceived-severity>
    SSHLibrary.Close All Connections

Verifying Alarm category PORT gets notified in Netconf
    [Arguments]        ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}      ${device}    ${linux}
    [Documentation]      Verifying Alarm category PORT gets notified in Netconf
    [Tags]        @author=ssekar

    ${connection}     Connection_establishment_using_SSHLibrary      ${netconf_ip}       ${netconf_user}      ${netconf_pass}    ${netconf_port}    ${local_pc_ip}    ${device_netconf}
    Alarm_subscription_netconf      parameter=category_port

    Log    *** Verifying alarms from category PORT can be triggered and cleared ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     n1      n1_sh     module-fault
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </module-fault>
    Should Contain      ${output}     <perceived-severity>MAJOR</perceived-severity>

    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli      n1      n1_sh     module-fault
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </module-fault>
    Should Contain      ${output}     <perceived-severity>CLEAR</perceived-severity>

    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     n1      n1_sh     unsupported-equipment
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </unsupported-equipment>
    Should Contain      ${output}     <perceived-severity>MAJOR</perceived-severity>
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli      n1      n1_sh     unsupported-equipment
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </unsupported-equipment>
    Should Contain      ${output}     <perceived-severity>CLEAR</perceived-severity>

    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm for dhcp server detected     n1
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </dhcp-server-detected>
    Should Contain      ${output}     <perceived-severity>MAJOR</perceived-severity>
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm for dhcp server detected     n1
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </dhcp-server-detected>
    Should Contain      ${output}     <perceived-severity>CLEAR</perceived-severity>

    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm for improper-removal      n1      n1_sh
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </improper-removal>
    Should Contain      ${output}     <perceived-severity>MAJOR</perceived-severity>
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm for improper-removal      n1      n1_sh 
    #Sleep for 5s
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>
    Log     ${output}
    Should Contain      ${output}     </improper-removal>
    Should Contain      ${output}     <perceived-severity>CLEAR</perceived-severity>
    SSHLibrary.Close All Connections

Alarm_notification_for_various_severities
    [Arguments]      ${device_ip}         ${username}      ${password}    ${ssh_port}      ${local_pc_ip}      ${device_netconf}   ${port}     ${device_linux}
    [Documentation]      Alarm notification for different severities
    [Tags]        @author=ssekar

    Log    *** Alarm notification for severity MAJOR ***
    Alarm_subscription_netconf      MAJOR
    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>${local_pc_ip}</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    SSHLibrary.Write      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>iert</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    #Sleep for 5s until Netconf notification been captured
    Sleep    5s
    ${output}       SSHLibrary.Read Until     </notification>]]>]]>     
    Should Contain      ${output}        </ntpd-down>
    Should Contain      ${output}        <perceived-severity>MAJOR</perceived-severity>
    SSHLibrary.Close All Connections
 
    Log    *** Alarm notification for severity INFO ***
    Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    SSHLibrary.Write       <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    SSHLibrary.Write        <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
    Alarm_subscription_netconf     INFO
    SSHLibrary.Write       <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>falsd</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    #Sleep for 5s until Netconf notification been captured
    Sleep    5s
    ${result}       SSHLibrary.Read Until     </notification>]]>]]>      
    Should Contain     ${result}      </running-config-unsaved>
    Should Contain     ${result}      <perceived-severity>INFO</perceived-severity>
    SSHLibrary.Close All Connections

    Log    *** Alarm notification for severity MINOR ***
    Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    Alarm_subscription_netconf     MINOR
    Log    "As ethernet-rmon-session-stopped alarm is having issue when clearing alarm, it is executed by issuing FAKE alarm from linux mode to verify MINOR severity, Once Bug EXA-11371 is fixed, FAKE alarm will be removed."
    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${device_linux}
    #Sleep for 5s before RMON session alarms being cleared
    Sleep  5s
    cli    ${device_linux}     dcli evtmgrd evtpost4 event ethernet-rmon-session-stopped severity CLEAR key1 port value1 'x3'      timeout=250
    #Clearing RMON MINOR alarm       device=${device_netconf}      user_interface=netconf
    # Sleep for 5s after clearing alarm
    Sleep    5s
    #Triggering RMON MINOR alarm     device=${device_netconf}      user_interface=netconf
    cli    ${device_linux}     dcli evtmgrd evtpost4 event ethernet-rmon-session-stopped severity MINOR key1 port value1 'x3'       timeout=250
    SSHLibrary.Write       <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"><interface><name>${port}</name><ethernet xmlns="http://www.calix.com/ns/ethernet-std"><rmon-session><bin-duration>one-minute</bin-duration><bin-count>60</bin-count><admin-state>disable</admin-state></rmon-session></ethernet></interface></interfaces></config></edit-config></rpc>]]>]]>
    #Sleep for 5s until Netconf notification been captured
    Sleep    5s
    ${result}       SSHLibrary.Read Until     </notification>]]>]]>    
    Should Contain     ${result}      </ethernet-rmon-session-stopped>
    Should Contain     ${result}      <perceived-severity>MINOR</perceived-severity>
    SSHLibrary.Close All Connections
    #Disconnect      ${device_netconf}

    Log    *** Alarm notification for severity CLEAR ***
    Connection_establishment_using_SSHLibrary      ${device_ip}         ${username}      ${password}    ${ssh_port}       ${local_pc_ip}      ${device_netconf}
    Alarm_subscription_netconf      CLEAR
    SSHLibrary.Write       <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id=""><edit-config><target><running/></target><config><config xmlns="http://www.calix.com/ns/exa/base"><system><ntp><server><id>1</id><address>${local_pc_ip}</address></server></ntp></system></config></config></edit-config></rpc>]]>]]>
    #Sleep for 5s until Netconf notification been captured
    Sleep    5s
    ${result}       SSHLibrary.Read Until     </notification>]]>]]>     
    Should Contain     ${result}      <perceived-severity>CLEAR</perceived-severity>
    Should Contain     ${result}      </ntpd-down>
    Should Contain     ${result}      <prev-severity>MAJOR</prev-severity>

    SSHLibrary.Write      <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><accept-running-config xmlns="http://www.calix.com/ns/exa/base"></accept-running-config></rpc>]]>]]>
    SSHLibrary.Write     <?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><copy-running-startup xmlns="http://www.calix.com/ns/exa/base"></copy-running-startup></rpc>]]>]]>
    #Sleep for 5s until Netconf notification been captured
    Sleep    5s
    ${result}       SSHLibrary.Read Until     </running-config-unsaved>      
    Should Contain     ${result}      </running-config-unsaved>
    Should Contain     ${result}      <perceived-severity>CLEAR</perceived-severity>
    Should Contain     ${result}      <prev-severity>INFO</prev-severity>
    SSHLibrary.Close All Connections

Connection_establishment_using_SSHLibrary
    [Arguments]      ${device_ip}         ${username}      ${password}    ${port}       ${local_pc_ip}     ${user_interface}=None
    [Documentation]      Initiating SSH connection using SSHLibrary keyword
    [Tags]        @author=ssekar
    SSHLibrary.Open Connection       ${device_ip}       port=${port}
    SSHLibrary.Login       ${username}     ${password}     delay=20 seconds
    Run Keyword If   '${user_interface}' == 'n1_netconf'      SSHLibrary.Write     <?xml version="1.0" encoding="UTF-8"?><hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><capabilities><capability>urn:ietf:params:netconf:base:1.0</capability></capabilities></hello>]]>]]>
    ${connection}       SSHLibrary.Get Connection 
    [Return]      ${connection}

Open_Connection_using_SSHLibrary
    [Arguments]      ${device_ip}         ${username}      ${password}        ${device}
    [Documentation]      Initiating SSH connection using SSHLibrary keyword
    [Tags]        @author=ssekar
    SSHLibrary.Open Connection       ${device_ip}        prompt=#
    SSHLibrary.Login       ${username}     ${password}     delay=20 seconds

Multiple_Alarm_Notifications_cli
    [Arguments]       ${device_ip}        ${username}      ${password}       ${local_pc_ip}      ${device}     ${snmp}    ${snmp_port}    ${linux}    ${local_pc}       ${local_pc_password}     
    [Documentation]    verifying multiple Alarm notifications can be sent at the same time
    [Tags]        @author=ssekar

    ${connection}     Open_Connection_using_SSHLibrary      ${device_ip}         ${username}      ${password}     ${device}
    : FOR    ${INDEX}    IN RANGE    1      3
    \     Log      ******* Subscribing to CRITICAL notification ********* 
    \     SSHLibrary.Write       session notification severity CRITICAL
    \     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_start_trap     ${snmp}     ${snmp_port}
    \     Wait Until Keyword Succeeds      2 min     10 sec      Triggering CRITICAL alarm     ${linux}     ${device}     cli
    \     ${app_instance_id}       Getting instance-id from Triggered alarms       ${device}        app_sus

    \     ${output}       SSHLibrary.Read Until       (affects service)
    \     Log      ${output}
    \     Should Contain      ${output}        ARC ALARM CRITICAL 'application-suspended'
    \     SSHLibrary.Write       session notification severity NONE

    \     Log     *** Modifying configuration while notifications are sent ***
    \     cli     ${device}       configure       timeout=90
    \     cli     ${device}       contact Ero1345
    \     cli     ${device}       ntp server 1 invalid
    \     cli     ${device}       end

    \     Wait Until Keyword Succeeds      2 min     10 sec      Clearing CRITICAL alarm      ${linux}     ${device}     cli
    \     @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmp}
    \     ${result}     Get From List     ${result}    0
    \     Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_application_suspended_alarm       ${snmp}     ${result}    ${app_instance_id}
    \     Wait Until Keyword Succeeds      2 min     10 sec         Alarm_application_suspended_recorded_on_syslog_server     ${device}      ${local_pc}      ${local_pc_ip}      ${local_pc_password}     parameter=alarm_raise
    \     Wait Until Keyword Succeeds    30 seconds    5 seconds    Restarting syslog server on local pc      ${local_pc}      ${local_pc_ip}     ${local_pc_password}
    SSHLibrary.Close All Connections
    ${result}    cli    ${device}      show running-config contact
    Should Contain      ${result}     contact Ero1345
    ${result}    cli    ${device}      show running-config ntp
    Should Contain      ${result}     ntp server 1 invalid

Verifying only current session subscription is displayed when logged with OPER role user
    [Arguments]       ${device_ip}        ${username}      ${password}       ${local_pc_ip}      ${device}
    [Documentation]    Verifying only current session subscription is displayed when logged with OPER role user
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Adding New user under oper role     ${device}
    : FOR    ${INDEX}    IN RANGE    1      3
    \     ${connection}     Open_Connection_using_SSHLibrary      ${device_ip}         ${username}      ${password}     ${device}
    \     Run Keyword If      ${INDEX} == 1     SSHLibrary.Write      session notification severity INFO
    \     Run Keyword If      ${INDEX} == 1     SSHLibrary.Write      show session notifications
    \     ${output}     Run Keyword If      ${INDEX} == 1      SSHLibrary.Read Until       INFO
    \     Log      ${output}
    \     Run Keyword If      ${INDEX} == 1      Should Contain      ${output}        Any alarm post or clear with minimum severity INFO
    \     Run Keyword If      ${INDEX} == 2     SSHLibrary.Write      session notification set-category GENERAL
    \     Run Keyword If      ${INDEX} == 2     SSHLibrary.Write      show session notifications
    \     ${output}     Run Keyword If      ${INDEX} == 2      SSHLibrary.Read Until       GENERAL
    \     Log      ${output}
    \     Run Keyword If      ${INDEX} == 2     Should Contain      ${output}        Alarm or event from category GENERAL

    ${result}      cli     ${device}      show user-notifications      timeout=120
    Should Contain      ${result}      Alarm or event from category GENERAL
    Should Contain      ${result}      Any alarm post or clear with minimum severity INFO

    #Logging with OPER user
    ${connection}     Open_Connection_using_SSHLibrary      device_ip=${device_ip}         username=newcafe      password=newcafe      device=${device}
    SSHLibrary.Write      session notification set-category DBCHANGE 
    SSHLibrary.Write      show session notifications
    ${output}     SSHLibrary.Read Until       DBCHANGE
    Log      ${output}
    ${match}    Get Lines Containing String       ${output}      DBCHANGE
    Should Contain      ${match}        Alarm or event from category DBCHANGE
    SSHLibrary.Write       show user-notifications
    ${output}     SSHLibrary.Read       delay=30 sec
    Log      ${output}
    Should Contain      ${output}        Alarm or event from category DBCHANGE
    #Should Not Contain      ${output}        Alarm or event from category GENERAL
    #Should Not Contain      ${output}        Any alarm post or clear with minimum severity INFO
        
    Log     *** Clearing all subscriptions ***
    Wait Until Keyword Succeeds      2 min     10 sec     SSHLibrary.Close All Connections

    #sleep for 5s
    Sleep     5s
    ${result}      cli     ${device}      show session notifications     timeout=120
    Should Contain      ${result}      no severity sessions
    Should Contain      ${result}      no category sessions

    Wait Until Keyword Succeeds      2 min     10 sec      Removing configured user under oper role       ${device}

Getting hostname
    [Arguments]       ${device}
    [Documentation]    Getting hostname
    [Tags]        @author=ssekar

    ${result}       cli     ${device}      show running-config hostname      timeout=120
    ${hostname}     Get Regexp Matches     ${result}        hostname ([A-Za-z0-9\-\_\:\(\)\$\#\@\^]+)     1
    ${hostname}     Get From List    ${hostname}     0
    [Return]      ${hostname}

Verifying configured alarm subscriptions are retrieved using CLI
    [Arguments]       ${device_ip}        ${username}      ${password}       ${local_pc_ip}      ${device}   
    [Documentation]    verifying configured alarm subscriptions are retrieved using CLI
    [Tags]        @author=ssekar

    : FOR    ${INDEX}    IN RANGE    1      3
    \     ${connection}     Open_Connection_using_SSHLibrary      ${device_ip}         ${username}      ${password}     ${device}
    \     Run Keyword If      ${INDEX} == 1     SSHLibrary.Write      session notification severity INFO
    \     Run Keyword If      ${INDEX} == 1     SSHLibrary.Write      show session notifications
    \     ${output}     Run Keyword If      ${INDEX} == 1      SSHLibrary.Read Until       INFO
    \     Log      ${output}
    \     Run Keyword If      ${INDEX} == 1      Should Contain      ${output}        Any alarm post or clear with minimum severity INFO
    \     Run Keyword If      ${INDEX} == 2     SSHLibrary.Write      session notification set-category GENERAL
    \     Run Keyword If      ${INDEX} == 2     SSHLibrary.Write      show session notifications
    \     ${output}     Run Keyword If      ${INDEX} == 2      SSHLibrary.Read Until       GENERAL
    \     Log      ${output}
    \     Run Keyword If      ${INDEX} == 2     Should Contain      ${output}        Alarm or event from category GENERAL

    ${result}      cli     ${device}      show user-notifications      timeout=120
    Should Contain      ${result}      Alarm or event from category GENERAL
    Should Contain      ${result}      Any alarm post or clear with minimum severity INFO

    Log     *** Clearing all subscriptions ***
    Wait Until Keyword Succeeds      2 min     10 sec     SSHLibrary.Close All Connections

    #sleep for 5s
    Sleep     5s
    ${result}      cli     ${device}      show session notifications     timeout=120
    Should Contain      ${result}      no severity sessions
    Should Contain      ${result}      no category sessions
    
Archived_Alarms
    [Arguments]    ${device}    ${instance_id} 
    [Documentation]    Verifying Active and cleared alarms are archived
    [Tags]        @author=ssekar

    ${result}      cli    ${device}      show alarm archive filter instance-id ${instance_id}
    Result Should Contain       perceived-severity CLEAR
    @{ins_id}      Get Regexp Matches    ${result}    instance-id (${instance_id})     1
    ${len_ins_id}     Get Length     ${ins_id}
    Log     ${len_ins_id}
    Should Be True       ${len_ins_id} >= 2

Archived_Alarms_using_netconf
    [Arguments]    ${device}    ${instance_id}
    [Documentation]    Verifying Active and cleared alarms are archived
    [Tags]        @author=ssekar

    ${result}      Netconf Raw    ${device}    xml=<?xml version="1.0" encoding="utf-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"><show-alarm-instances-archive-filter xmlns="http://www.calix.com/ns/exa/base"><instance-id>${instance_id}</instance-id></show-alarm-instances-archive-filter></rpc>]]>]]>
    Should Contain       ${result.xml}      <perceived-severity>CLEAR</perceived-severity>
    ${str}      Convert to string     ${result}
    @{ins_id}      Get Regexp Matches    ${str}      <instance-id>(${instance_id})</instance-id>     1
    ${len_ins_id}     Get Length     ${ins_id}
    Log     ${len_ins_id}
    Should Be True       ${len_ins_id} >= 2 

Verifying category PORT alarm
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}     ${snmp}=false    ${syslog}=false
    [Documentation]    Verifying category PORT alarm
    [Tags]        @author=ssekar

    Log    *** Starting SNMP trap ***
    Run Keyword If     '${snmp}' == 'true'       Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    Log    *** Verifying alarms from category PORT can be triggered and cleared ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     ${device}     ${linux}     module-fault
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli      ${device}     ${linux}     module-fault
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     ${device}     ${linux}     unsupported-equipment
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli      ${device}     ${linux}    unsupported-equipment

    ${dhcp_raise_time}     Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm for dhcp server detected     ${device}
    ${dhcp_clear_time}     Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm for dhcp server detected     ${device}

    ${improper_raise_time}    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm for improper-removal      ${device}     ${linux}
    ${improper_clear_time}    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm for improper-removal        ${device}     ${linux}

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Run Keyword If     '${snmp}' == 'true'      Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${output}      Run Keyword If     '${snmp}' == 'true'      Get From List     ${result}     0
    Run Keyword If     '${snmp}' == 'true'      Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications     ${snmpv2}     ${output} 
    ...      improper-removal       raise_time=${improper_raise_time}     clear_time=${improper_clear_time}
    Run Keyword If     '${snmp}' == 'true'      Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      ${snmpv2}     ${output} 
    ...      module-fault
    Run Keyword If     '${snmp}' == 'true'      Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      ${snmpv2}     ${output}
    ...     unsupported-equipment
    Run Keyword If     '${snmp}' == 'true'      Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      ${snmpv2}     ${output} 
    ...     dhcp-server-detected      raise_time=${dhcp_raise_time}     clear_time=${dhcp_clear_time}

    Log    *** verifying syslog server received the message ***
    Run Keyword If     '${syslog}' == 'true'    Wait Until Keyword Succeeds      2 min     10 sec     Alarm_messages_in_syslog_server      ${device}    ${localpc} 
    ...     ${localpc_ip}     ${localpc_pass}      alarm=module-fault     
    Run Keyword If     '${syslog}' == 'true'    Wait Until Keyword Succeeds      2 min     10 sec     Alarm_messages_in_syslog_server      ${device}    ${localpc}
    ...     ${localpc_ip}     ${localpc_pass}      alarm=unsupported-equipment
    Run Keyword If     '${syslog}' == 'true'    Wait Until Keyword Succeeds      2 min     10 sec     Alarm_messages_in_syslog_server      ${device}    ${localpc}
    ...     ${localpc_ip}     ${localpc_pass}      alarm=dhcp-server-detected       raise_time=${dhcp_raise_time}     clear_time=${dhcp_clear_time}
    Run Keyword If     '${syslog}' == 'true'    Wait Until Keyword Succeeds      2 min     10 sec     Alarm_messages_in_syslog_server      ${device}    ${localpc}
    ...     ${localpc_ip}     ${localpc_pass}      alarm=improper-removal         raise_time=${improper_raise_time}     clear_time=${improper_clear_time}

Verifying ntpd down alarm
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}
    [Documentation]    Verifying ntpd down alarm
    [Tags]        @author=ssekar
  
    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    Log    *** Verifying ntpd down alarm can be triggered and cleared, maintained in historical alarms ***
    ${instance_id}     Wait Until Keyword Succeeds    30 seconds    5 seconds    Trigerring NTPD down alarm       ${device}       ${localpc_ip}
    ${ntpd_raise_time}     Wait Until Keyword Succeeds    30 seconds    5 seconds    Getting Alarm or event time from DUT    ${device}    ${instance_id}
    ${ntpd_clear_time}     Wait Until Keyword Succeeds    30 seconds    5 seconds    Clearing NTPD down alarm       ${device}        ${instance_id}
    @{list}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap       ${snmpv2}
    ${result}     Get From List     ${list}    0
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_ntpd_down_alarm     ${snmpv2}    ${result}    instance-id=${instance_id}
    ...       raise_time=${ntpd_raise_time}      clear_time=${ntpd_clear_time}

Verifying loss of signal alarm
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}
    [Documentation]    Verifying loss of signal alarm
    [Tags]        @author=ssekar

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    Log    *** Verifying loss of signal alarm can be triggered and cleared ***
    ${passed}    Wait Until Keyword Succeeds    30 seconds    5 seconds      Run Keyword And Return Status     Triggering Loss of Signal MAJOR alarm    ${device}      user_interface=cli
    ${passed}    Wait Until Keyword Succeeds    30 seconds    5 seconds     Run Keyword And Return Status      Clearing Loss of Signal MAJOR alarm     ${device}      user_interface=cli

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}       Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${output}       Get From List     ${result}     0
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_loss_of_signal_alarm     ${snmpv2}     ${output}

Triggering OSPF event
    [Arguments]       ${device}     ${event}     ${port}     ${linux}      ${linux_user}     ${nssa-event}=true
    [Documentation]    Triggering OSPF event
    [Tags]        @author=ssekar

    Run Keyword If    '${event}' == 'if-auth and nbr-state'     Run Keywords    cli    ${device}     configure     timeout=50
    ...   AND      cli    ${device}     interface ethernet ${port}     timeout=50
    ...   AND      cli    ${device}     ip ospf 1 authentication md5 67890      timeout=50
    # Sleep for 10s to trigger an event
    ...   AND      Sleep     10s
    ...   AND      cli    ${device}     no ip ospf 1 authentication       timeout=50
    ...   AND      cli    ${device}     shut      timeout=50
    ...   AND      cli    ${device}     no shut     timeout=50
    ...   AND      cli    ${device}     end

    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Run Keywords    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    ...   AND      cli      ${linux}       cd /var         timeout=120
    ...   AND      cli      ${linux}       /etc/init.d/ipmgr.sh start
    #Sleep for 5s
    ...   AND      Sleep   5s
    ${result}      Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'      cli      ${linux}       ps -ef | grep ipmgrd       timeout=120   
    ...            prompt=var
    ${result}     Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Get Lines Containing String       ${result}        /usr/bin/ipmgrd
    ${process_id}     Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Get Regexp Matches     ${result}        ${linux_user}\\s*([0-9]+)      1
    ${process_id}     Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Get From List    ${process_id}     0
    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     cli      ${linux}      kill -9 ${process_id}         timeout=120     prompt=var
    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     cli      ${linux}      /etc/init.d/ipmgr.sh start     timeout=120     prompt=var
    #Sleep for 200s after triggering ospf nssa-trans event
    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change' and '${nssa-event}' == 'true'     Sleep   200s
    #Sleep for 10s after triggering ospf oper-change event
    ...   ELSE IF     '${event}' == 'if-state nssa-trans and oper-change' and '${nssa-event}' == 'false'     Sleep    30s

    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${device}
    ${result}     Run Keyword If    '${event}' == 'if-auth and nbr-state'      Wait Until Keyword Succeeds      2 min     10 sec      cli    ${device}    
    ...         show event filter name ospf-event-if-auth-failure       timeout=120      prompt=\\#
    Run Keyword If    '${event}' == 'if-auth and nbr-state'    Should Contain     ${result}    id 4502
    ${result}     Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Wait Until Keyword Succeeds      2 min     10 sec    cli    ${device} 
    ...        show event filter name ospf-event-if-state-change      timeout=120      prompt=\\#
    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Should Contain     ${result}    id 4503
    ${result}     Run Keyword If    '${event}' == 'if-auth and nbr-state'     Wait Until Keyword Succeeds      2 min     10 sec    cli    ${device}  
    ...              show event filter name ospf-event-nbr-state-change       timeout=120     prompt=\\#
    Run Keyword If    '${event}' == 'if-auth and nbr-state'     Should Contain     ${result}    id 4501

    ${result}    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Wait Until Keyword Succeeds      2 min     10 sec    cli    ${device}   
    ...         show event filter name ospf-event-oper-change       timeout=120      prompt=\\#
    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change'     Should Contain     ${result}    id 4505
    ${result}    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change' and '${nssa-event}' == 'true'    Wait Until Keyword Succeeds      2 min 
    ...       10 sec    cli    ${device}    show event filter name ospf-event-nssa-trans-change      timeout=120      prompt=\\#
    Run Keyword If    '${event}' == 'if-state nssa-trans and oper-change' and '${nssa-event}' == 'true'     Should Contain     ${result}    id 4504

Triggering TRANSFER events
    [Arguments]       ${device}     ${event}     ${techlog}     ${local_pc_ip}
    [Documentation]    Triggering TRANSFER events
    [Tags]        @author=ssekar

    : FOR     ${INDEX}    IN RANGE    0    5
    \    ${result}    Run Keyword If    '${event}' == 'transfer-finished' or '${event}' == 'transfer-aborted'     cli     ${device}     
    \    ...          upload file techlog from-file ${techlog} to-URI tftp://${local_pc_ip}       timeout=120         prompt=\\#     retry=4
    \    Run Keyword If    '${event}' == 'transfer-finished' or '${event}' == 'transfer-aborted'    Should Contain       ${result}      status Initiating upload
    \    ${result}     Run Keyword If    '${event}' == 'transfer-aborted'    cli     ${device}     stop file transfer    timeout=120      prompt=\\#    retry=4
    \    ${transfer_abort}    Run Keyword If    '${event}' == 'transfer-aborted'     Run Keyword And Return Status    Should Contain       ${result}      status OK
    #Sleep for 20s
    \    Run Keyword If    '${event}' == 'transfer-finished'     Sleep    20s
    \    ${result}    Run Keyword If    '${event}' == 'transfer-finished'     cli     ${device}       show event filter id 2402      timeout=120      prompt=\\#
    \    ...      retry=4
    \    ${transfer_fin}     Run Keyword If    '${event}' == 'transfer-finished'     Run Keyword And Return Status    Should Contain       ${result}  
    \    ...      name transfer-finished
    \    Exit For Loop If      '${transfer_fin}' == 'True' or '${transfer_abort}' == 'True'
    ${res}    Run Keyword If    '${event}' == 'transfer-aborted'      cli     ${device}       show event filter id 2403      timeout=120        prompt=\\#    retry=4
    Run Keyword If    '${event}' == 'transfer-aborted'     Should Contain     ${res}     name transfer-aborted

    : FOR     ${INDEX}    IN RANGE    0    5
    \    ${result}    Run Keyword If    '${event}' == 'transfer-failed'     cli     ${device}     
    \    ...         upload file techlog from-file ${techlog}.12345 to-URI tftp://${local_pc_ip}       timeout=120       prompt=\\#      retry=4
    \    Run Keyword If    '${event}' == 'transfer-failed'     Should Contain       ${result}      status Initiating upload
    #Sleep for 5s
    \    Run Keyword If    '${event}' == 'transfer-failed'      Sleep    5s
    \    ${result}     Run Keyword If    '${event}' == 'transfer-failed'      cli     ${device}       show event filter id 2404      timeout=120       prompt=\\#
    \    ...       retry=4
    \    ${transfer_fail}    Run Keyword If    '${event}' == 'transfer-failed'    Run Keyword And Return Status    Should Contain     ${result}   name transfer-failed
    \    Exit For Loop If      '${transfer_fail}' == 'True'
  
    ${res}    Run Keyword If    '${event}' == 'transfer-failed'      cli     ${device}       show event filter id 2404       timeout=120       prompt=\\#     retry=4
    Run Keyword If    '${event}' == 'transfer-failed'     Should Contain     ${res}     name transfer-failed

    ${res}    Run Keyword If    '${event}' == 'transfer-finished'      cli     ${device}       show event filter id 2402      timeout=120      prompt=\\#      retry=4
    Run Keyword If    '${event}' == 'transfer-finished'      Should Contain     ${res}     name transfer-finished

    #Sleep for 8s
    Sleep    8s

Triggering lldp neighbor event between Calix and Cisco
    [Arguments]       ${device}     ${port}    ${cisco}     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    [Documentation]    Triggering lldp neighbor event between Calix and Cisco
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      30 sec     10 sec         Disabling Switchport in E3-2     ${device}     ${port}
    Wait Until Keyword Succeeds      30 sec     10 sec         Configure LLDP on E3-2      ${device}     ${port}
    Wait Until Keyword Succeeds      30 sec     10 sec         Configure LLDP on Cisco     ${cisco}     ${cisco_ip}     ${cisco_user}       ${cisco_password}
    ...     ${cisco_en_pw}      ${cisco_port1}   
    #sleep for 50s
    Sleep     50s
    Wait Until Keyword Succeeds      30 sec     10 sec         Enabling the Cisco shutdown port      ${cisco}     ${cisco_ip}     ${cisco_user}       ${cisco_password}
    ...     ${cisco_en_pw}      ${cisco_port1}
    #sleep for 30s
    Sleep     30s
    ${result}     cli     ${device}        show event filter name lldp-neighbor-activity     timeout=50      prompt=\\#
    Should Contain      ${result}           id 3701

Triggering lacp fault alarm between Calix and Cisco
    [Arguments]       ${device}     ${port}    ${cisco}     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    [Documentation]    Triggering lacp fault alarm between Calix and Cisco
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      30 sec     10 sec         Disabling Switchport in E3-2     ${device}     ${port}
    Wait Until Keyword Succeeds      30 sec     10 sec         Configure LAG on E3-2      ${device}     ${port}
    Wait Until Keyword Succeeds      30 sec     10 sec         Configure Port-channel on Cisco     ${cisco}     ${cisco_ip}     ${cisco_user}       ${cisco_password}
    ...     ${cisco_en_pw}      ${cisco_port1}
    #sleep for 10s
    Sleep     10s
    Wait Until Keyword Succeeds      30 sec     10 sec         Disabling port-channel on Cisco     ${cisco}     ${cisco_ip}     ${cisco_user}       ${cisco_password}
    ...     ${cisco_en_pw}      ${cisco_port1}
    #sleep for 15s
    Sleep     15s
    ${result}     cli     ${device}        show alarm active subscope name lacp-fault-on-port      timeout=50      prompt=\\#     retry=2
    Should Contain      ${result}           id 2101
    Should Contain      ${result}           ${port}
    ${raise_time}     Get Lines Containing String     ${result}     ne-event-time
    @{raise_time}     Get Regexp Matches    ${raise_time}      ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    #${raise_time}     Convert To String     ${raise_time}
    Log    ${raise_time}
    [Return]     ${raise_time}

Clearing lacp fault alarm between Calix and Cisco
    [Arguments]       ${device}     ${port}    ${cisco}     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    [Documentation]    Clearing lacp fault alarm between Calix and Cisco
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      30 sec     10 sec         Disabling Switchport in E3-2     ${device}     ${port}
    #Wait Until Keyword Succeeds      30 sec     10 sec         Configure LAG on E3-2      ${device}     ${port}
    #Wait Until Keyword Succeeds      30 sec     10 sec         Configure Port-channel on Cisco     ${cisco}     ${cisco_ip}     ${cisco_user}       ${cisco_password}
    #...     ${cisco_en_pw}      ${cisco_port1}
    Wait Until Keyword Succeeds      30 sec     10 sec         Disabling port-channel on Cisco     ${cisco}     ${cisco_ip}     ${cisco_user}       ${cisco_password}
    ...     ${cisco_en_pw}      ${cisco_port1}
    #sleep for 15s
    Sleep     15s

    ${result}     cli     ${device}        show alarm active subscope name lacp-fault-on-port      timeout=50      prompt=\\#
    Should Not Contain      ${result}           ${port}

    ${result}     cli     ${device}        show alarm history filter name lacp-fault-on-port      timeout=50      prompt=\\#
    ${clear_time}      Get Lines Containing String     ${result}     ne-event-time
    @{clear_time}      Get Regexp Matches    ${clear_time}     ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    [Return]     ${clear_time}

Configure LLDP on E3-2
    [Arguments]       ${device}      ${port1}
    [Documentation]    Configure LLDP on E3-2
    [Tags]        @author=ssekar

    cli      ${device}    configure      timeout=50       prompt=\\#      
    cli    ${device}    interface ethernet ${port1}      timeout=50      prompt=\\#
    cli     ${device}     switchport ENABLED       timeout=50      prompt=\\#
    cli     ${device}     role lag       timeout=50      prompt=\\#
    cli     ${device}     end         timeout=50      prompt=\\#
    ${result}      cli     ${device}     show running-config interface ethernet ${port1}      timeout=50
    Should Contain      ${result}       switchport  ENABLED
    Should Contain      ${result}       role        lag

Configure LAG on E3-2
    [Arguments]       ${device}      ${port1}
    [Documentation]    Configure LAG on E3-2
    [Tags]        @author=ssekar

    cli      ${device}    configure      timeout=50       prompt=\\#
    cli    ${device}    interface lag la1     timeout=50       prompt=\\#
    cli    ${device}    lacp-mode active     timeout=50       prompt=\\#
    cli    ${device}    switchport ENABLED    timeout=50       prompt=\\#
    cli    ${device}    no shutdown    timeout=50       prompt=\\#
    cli    ${device}    exit     timeout=50       prompt=\\#
    cli      ${device}    interface ethernet ${port1}      timeout=50      prompt=\\#
    cli     ${device}     switchport ENABLED       timeout=50      prompt=\\#
    cli     ${device}     role lag       timeout=50      prompt=\\#
    cli     ${device}     group la1     timeout=50      prompt=\\#
    cli     ${device}     no shutdown    timeout=50       prompt=\\#
    cli    ${device}      end        timeout=50       prompt=\\#
    ${result}      cli     ${device}     show running-config interface ethernet ${port1}      timeout=50
    Should Contain      ${result}       switchport  ENABLED
    Should Contain      ${result}       role        lag
    Should Contain      ${result}       group       la1

Configure Port-channel on Cisco
    [Arguments]    ${device}    ${device_ip}     ${user}   ${password}   ${enable_pw}     ${port1}
    [Documentation]      Configure Port-channel on Cisco
    [Tags]        @author=ssekar 

    Telnet.Open Connection     ${device_ip}        timeout=30
    Telnet.Login        ${user}      ${password}    login_prompt=Username:   password_prompt=Password:     login_timeout=10 seconds
    Telnet.Write        enable
    Telnet.Write        ${enable_pw}
    Telnet.Write        configure terminal
    Telnet.Read Until      (config)#
    Telnet.Write        interface port-channel 14 
    Telnet.Write        no shut
    Telnet.Write        exit
    Telnet.Write        interface ${port1}
    Telnet.Write        no shut
    Telnet.Write        no ip address
    Telnet.Write        channel-group 14 mode active
    Telnet.Write        end
    Telnet.Write        exit

Disabling port-channel on Cisco
    [Arguments]    ${device}    ${device_ip}     ${user}   ${password}   ${enable_pw}     ${port1}
    [Documentation]      Disabling port-channel on Cisco
    [Tags]        @author=ssekar

    Telnet.Open Connection     ${device_ip}        timeout=30
    Telnet.Login        ${user}      ${password}    login_prompt=Username:   password_prompt=Password:     login_timeout=10 seconds
    Telnet.Write        enable
    Telnet.Write        ${enable_pw}
    Telnet.Write        configure terminal
    Telnet.Read Until      (config)#
    Telnet.Write        interface ${port1}
    Telnet.Write        no channel-group
    Telnet.Write        end
    Telnet.Write        exit

Configure LLDP on Cisco
    [Arguments]    ${device}    ${device_ip}     ${user}   ${password}   ${enable_pw}     ${port1}  
    [Documentation]      Configure LLDP on Cisco
    [Tags]        @author=ssekar

    Telnet.Open Connection     ${device_ip}        timeout=30
    Telnet.Login        ${user}      ${password}    login_prompt=Username:   password_prompt=Password:     login_timeout=10 seconds
    Telnet.Write        enable
    Telnet.Write        ${enable_pw}
    Telnet.Write        configure terminal
    Telnet.Read Until      (config)#
    Telnet.Write         lldp run
    Telnet.Write         lldp holdtime 9000
    Telnet.Write         lldp timer 5
    Telnet.Write        interface ${port1}
    Telnet.Write        no ip address
    Telnet.Write        no shut
    Telnet.Write        end
    Telnet.Write        exit

Disabling Switchport in E3-2
    [Arguments]       ${device}     ${port1}
    [Documentation]    Disabling Switchport in E3-2
    [Tags]        @author=ssekar

    cli      ${device}    configure      timeout=50       prompt=\\#
    cli    ${device}    interface ethernet ${port1}      timeout=50      prompt=\\#
    Run Keyword And Ignore Error     cli     ${device}     no group     timeout=50      prompt=\\#
    Run Keyword And Ignore Error     cli     ${device}     no role      timeout=50      prompt=\\#
    cli     ${device}     no switchport      timeout=50      prompt=\\#
    cli     ${device}     end         timeout=50      prompt=\\#
    ${result}      cli     ${device}     show running-config interface ethernet ${port1}      timeout=50
    Should Not Contain      ${result}       switchport  ENABLED
    Should Not Contain      ${result}       role        lag    

Triggering dcli events
    [Arguments]       ${device}    ${linux}     ${event}
    [Documentation]    Triggering dcli events
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec        Disconnect      ${linux}
    : FOR     ${INDEX}    IN RANGE    0    5
    \    cli     ${linux}       dcli evtmgrd evtpost ${event} INFO      timeout=120
    #Sleep for 5s
    \    Sleep     5s   
    \    ${result}     cli      ${device}      show event filter name ${event}       timeout=120
    \    ${name}      Get Regexp Matches      ${result}      (name ${event})     1
    \    ${len}       Get Length      ${name}
    \    ${res}      Run Keyword And Return Status    Should Be True    ${len} >= 2
    #Sleep for 8s
    \    Sleep     8s
    \    Exit For Loop If      '${res}' == 'True'
    Run Keyword If   '${res}' == 'False'      Fail     msg=Failed while triggering events

Triggering System restart event
    [Arguments]       ${device}    ${event}
    [Documentation]    Triggering System restart event
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec       Reload The System      ${device} 
    ${result}     cli      ${device}      show event filter name system-restart
    Should Contain      ${result}      id 2604

Verifying OSPF events 
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}     ${port}     ${linux_user}
    [Documentation]    Verifying OSPF events
    [Tags]        @author=ssekar

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    @{total_events}     Create List     ospf-event-if-auth-failure       ospf-event-if-state-change      ospf-event-nbr-state-change      ospf-event-nssa-trans-change
    ...                 ospf-event-oper-change

    @{total_event}     Create List        if-auth and nbr-state       if-state nssa-trans and oper-change

    Log    *** Verifying OSPF events can be triggered and cleared ***
    : FOR    ${event}    IN      @{total_event}
    \    Wait Until Keyword Succeeds      2 min     10 sec        Triggering OSPF event       ${device}     ${event}      ${port}    ${linux}     ${linux_user}

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${output}      Get From List     ${result}     0
    : FOR    ${event}    IN      @{total_events}
    \    Wait Until Keyword Succeeds      30 seconds     10 sec          SNMP_trap_verifications_for_events      ${snmpv2}     ${output}     ${event}

Verifying other GENERAL events
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}     ${port}     ${linux_user}
    [Documentation]    Verifying GENERAL events
    [Tags]        @author=ssekar

    @{total_events}      Create List          core-file-generated     ethernet-rmon-pmdata-cleared 

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    : FOR    ${dcli_event}     IN      @{total_events}
    \    Run Keyword If     '${dcli_event}' != 'ethernet-rmon-pmdata-cleared'     Wait Until Keyword Succeeds      2 min     10 sec        Triggering dcli events      
    \    ...        ${device}     ${linux}      ${dcli_event}

    Log     *** Triggering ethernet-rmon-pmdata-cleared event ***
    Wait Until Keyword Succeeds      2 min     10 sec        Triggering ethernet-rmon-pmdata-cleared event      ${device}     ${port}

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${output}      Get From List     ${result}     0
    : FOR    ${event}    IN      @{total_events}
    \    Wait Until Keyword Succeeds      2 min     10 sec          SNMP_trap_verifications_for_events      ${snmpv2}     ${output}     ${event}

Verifying GENERAL events
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}     ${port}     ${linux_user}
    ...      ${cisco}    ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    [Documentation]    Verifying GENERAL events
    [Tags]        @author=ssekar

    @{total_events}     Create List      transfer-failed     transfer-aborted      transfer-finished      lldp-neighbor-activity      
    @{total_dcli_events}      Create List      kernel-oops-detected      ethernet-rmon-pmdata-cleared      dot1x-supplicant-denied    
    ...     dhclient-option-ignored       default-route-add-ignored       core-file-generated      
    
    Log      *** Generating techlog file ***
    ${techlog}    Wait Until Keyword Succeeds      2 min     10 sec        Generating techlog files        ${device}

    Log    *** Starting SNMP trap ***
    : FOR    ${INDEX}    IN RANGE    0    3
    \    ${snmp_start}    Wait Until Keyword Succeeds     30 sec    10 sec     Run Keyword And Return Status      SNMP_start_trap        ${snmpv2}     port=${snmp_port}
    \    Run Keyword If    '${snmp_start}' == 'False'      Wait Until Keyword Succeeds      30 sec     10 sec       SNMP_stop_trap     ${snmpv2}
    \    Exit For Loop If    '${snmp_start}' == 'True'

    Log    *** Trigerring Transfer finish, transfer aborted, transfer fail events ***
    : FOR    ${event}    IN      @{total_events}
    \    Run Keyword If    '${event}' != 'lldp-neighbor-activity'     Wait Until Keyword Succeeds      2 min     10 sec        Triggering TRANSFER events  
    \    ...       ${device}     ${event}     ${techlog}      ${localpc_ip}
    Wait Until Keyword Succeeds      2 min     10 sec        Triggering lldp neighbor event between Calix and Cisco      ${device}     ${port}    ${cisco}    
    ...     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${output}      Get From List     ${result}     0
    : FOR    ${event}    IN      @{total_events}
    \    Wait Until Keyword Succeeds      30 seconds     10 sec          SNMP_trap_verifications_for_events      ${snmpv2}     ${output}     ${event}

    : FOR    ${INDEX}    IN RANGE    0    3
    \    ${result}    Wait Until Keyword Succeeds      30 seconds     10 sec     Run Keyword And Return Status      Verifying other GENERAL events 
    \    ...     ${snmpv2}     ${snmp_port}     ${device}      ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}     ${port}     ${linux_user}
    \    Exit For Loop If    '${result}' == 'True'

    Run Keyword If   '${result}' == 'False'      Fail     msg=Failed while triggering events

    @{panic_events}     Create List      kernel-oops-detected     
    
    #Log  *** Triggering kernel-oops-detected and system-restart event ***
    Wait Until Keyword Succeeds      2 min     10 sec        Triggering kernel-oops-detect and system-restart event        ${linux}      ${device}

Triggering ethernet-rmon-pmdata-cleared event
    [Arguments]       ${device}     ${port}
    [Documentation]    Triggering ethernet-rmon-pmdata-cleared event
    [Tags]        @author=ssekar

    cli     ${device}       clear interface ethernet ${port} performance-monitoring rmon-session bin-or-interval bin bin-duration one-minute all-or-current all
    ...     prompt=\\#     timeout=90
    ${result}       cli     ${device}       show event filter name ethernet-rmon-pmdata-cleared     prompt=\\#     timeout=90
    Should Contain      ${result}      id 1223

Triggering kernel-oops-detect and system-restart event
    [Arguments]       ${linux}      ${device}
    [Documentation]    Triggering kernel-oops-detect and system-restart event
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    Wait Until Keyword Succeeds      2 min     10 sec      cli      ${linux}      sudo sysctl -w kernel.sysrq=1      timeout=90      timeout_exception=0    prompt=\\#
    Wait Until Keyword Succeeds      2 min     10 sec      Run Keyword And Return Status    cli      ${linux}      echo c > /proc/sysrq-trigger       timeout=90     
    ...           timeout_exception=0
    #Sleep 200s
    Sleep     200s
    ${result}     Wait Until Keyword Succeeds     2 min    10 sec    cli     ${device}      show event filter name kernel-oops-detected     timeout=90      prompt=\\#
    Should Contain      ${result}      id 2619
    ${result}     Wait Until Keyword Succeeds     2 min    10 sec    cli     ${device}      show event filter name system-restart    timeout=90      prompt=\\#
    Should Contain      ${result}      id 2604
   

Verifying SNMP trap is not running
    [Arguments]       ${snmpv2}     ${snmp_port}
    [Documentation]    Verifying SNMP trap is not running
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      30 sec     10 sec       Run Keyword And Return Status       SNMP_start_trap        ${snmpv2}     port=${snmp_port}
    ${result}    Wait Until Keyword Succeeds      30 sec     10 sec       Run Keyword And Return Status       snmp stop trap host       ${snmpv2}
    Should Be True     '${result}' == 'True'

Verifying source-verify-resources-limited alarm
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}
    [Documentation]    Verifying source-verify-resources-limited alarm
    [Tags]        @author=ssekar

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    Log    *** Verifying alarms from category DHCP can be triggered and cleared ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     ${device}     ${linux}      source-verify-resources-limited

    Log    *** Getting instance-id for Triggered Alarms ***
    ${instance_id}    Getting instance-id from Triggered alarms    ${device}       source-verify-resources-limited

    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm using dcli      ${device}     ${linux}      source-verify-resources-limited

    Log    *** Verifying Alarm history stores the cleared alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Verifying Alarm history stores the cleared alarm     ${device}      ${instance_id}   
    ...     source-verify-resources-limited

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${output}      Get From List     ${result}     0
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      ${snmpv2}     ${output}    source-verify-resources-limited

    Log    *** verifying syslog server received the message ***
    Wait Until Keyword Succeeds      2 min     10 sec     Alarm_messages_in_syslog_server      ${device}     ${localpc}     ${localpc_ip}     ${localpc_pass}
    ...       alarm=source-verify-resources-limited

Verifying lacp fault alarm for syslog
    [Arguments]        ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}     ${port}     ${linux_user}
    ...      ${cisco}    ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    [Documentation]    Verifying lacp fault alarm for syslog
    [Tags]        @author=ssekar

    ${raise_time}   Wait Until Keyword Succeeds      30 sec     10 sec        Triggering lacp fault alarm between Calix and Cisco      ${device}     ${port}    ${cisco}
    ...     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}

    ${clear_time}    Wait Until Keyword Succeeds      30 sec     10 sec        Clearing lacp fault alarm between Calix and Cisco       ${device}     ${port}    ${cisco}
    ...     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}

    Log    *** verifying syslog server received the message ***
    Wait Until Keyword Succeeds      2 min     10 sec     Alarm_messages_in_syslog_server      ${device}     ${localpc}     ${localpc_ip}     ${localpc_pass}
    ...       alarm=lacp-fault-on-port     raise_time=${raise_time}      clear_time=${clear_time}

Verifying lacp fault alarm 
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}     ${port}     ${linux_user}
    ...      ${cisco}    ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}
    [Documentation]    Verifying lacp fault alarm
    [Tags]        @author=ssekar

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    ${raise_time}   Wait Until Keyword Succeeds      30 sec     10 sec     Triggering lacp fault alarm between Calix and Cisco      ${device}     ${port}    ${cisco}   
    ...     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}

    ${clear_time}   Wait Until Keyword Succeeds      30 sec     10 sec        Clearing lacp fault alarm between Calix and Cisco       ${device}     ${port}    ${cisco}
    ...     ${cisco_ip}     ${cisco_user}     ${cisco_password}     ${cisco_en_pw}     ${cisco_port1}

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${output}      Get From List     ${result}     0
    ${count}    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      ${snmpv2}     ${output}    lacp-fault-on-port    ${raise_time} 
    ...     ${clear_time}
    Should Be True    ${count} >= 2

Verifying ENVIRONMENTAL alarms
    [Arguments]       ${snmpv2}     ${snmp_port}     ${device}     ${linux}     ${localpc}     ${localpc_ip}     ${localpc_pass}
    [Documentation]    Verifying ENVIRONMENTAL alarms
    [Tags]        @author=ssekar

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      30 sec     10 sec        SNMP_start_trap        ${snmpv2}     port=${snmp_port}

    @{total_alarms}     Create List     environment-input    post_fpga     post_ddr_mem     post_dyad     post_bid     post_sram_memory     post_i2c     post_phy
    ...      post_nor
    Log    *** Verifying alarms from category DHCP can be triggered and cleared ***
    : FOR    ${alarm}    IN      @{total_alarms}
    \    Wait Until Keyword Succeeds      30 sec     10 sec      Triggering alarm using dcli     ${device}     ${linux}        ${alarm}      env=true
    \    Log    *** Getting instance-id for Triggered Alarms ***
    \    ${instance_id}    Getting instance-id from Triggered alarms    ${device}       ${alarm}      env=true
    #Sleep for 10s
    \    Sleep    10s
    \    Wait Until Keyword Succeeds      30 sec     10 sec     Clearing alarm using dcli       ${device}     ${linux}       ${alarm}       env=true
    \    Log    *** Verifying Alarm history stores the cleared alarm ***
    \    Wait Until Keyword Succeeds      30 sec     10 sec     Verifying Alarm history stores the cleared alarm     ${device}      ${instance_id}     ${alarm}
    #Sleep for 10s
    \    Sleep    10s

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     ${snmpv2}
    ${passed}     Wait Until Keyword Succeeds    30 seconds    5 seconds    Run Keyword And Return Status     Verifying snmp trap and syslog server receives messages    ${snmpv2}     ${result}     ${device}    ${localpc}     ${localpc_ip}     ${localpc_pass}       ${snmp_port}       ${linux}
    [Return]    ${passed} 

Verifying snmp trap and syslog server receives messages
    [Arguments]      ${snmpv2}     ${result}     ${device}    ${localpc}     ${localpc_ip}     ${localpc_pass}      ${snmp_port}       ${linux}
    [Documentation]    Verifying snmp trap and syslog server receives messages
    [Tags]        @author=ssekar

    @{total_alarms}     Create List     environment-input    post_fpga     post_ddr_mem     post_dyad     post_bid     post_sram_memory     post_i2c     post_phy
    ...      post_nor
    ${output}      Get From List     ${result}     0
    : FOR    ${alarm}    IN      @{total_alarms}
    \    ${passed}    Wait Until Keyword Succeeds      30 sec     10 sec      Run Keyword And Return Status     SNMP_trap_verifications      ${snmpv2}     ${output}     ${alarm}
    \    Wait Until Keyword Succeeds      30 sec     10 sec     Alarm_messages_in_syslog_server      ${device}     ${localpc}    ${localpc_ip}     ${localpc_pass}
    \    ...        alarm=${alarm}     env=true

Deleting SNMP
    [Arguments]      ${device}       ${snmp_manager_ip}
    [Documentation]        Removing existing SNMP configuration
    [Tags]        @author=ssekar

    #Removing existing SNMP configuration
    ${result}    cli    ${device}      show running-config snmp     timeout=90
    ${trap_result}    Get Lines Containing String    ${result}    v2 trap-host
    ${com_result}     Get Lines Containing String    ${result}    v2 community
    ${v3trap_result}    Get Lines Containing String    ${result}    v3 trap-host
    @{trap}    Get Regexp Matches     ${trap_result}      v2 trap-host ([0-9\.]+) (.*)    1    2
    @{com}    Get Regexp Matches     ${com_result}      v2 community (.*) ro       1
    @{v3trap}     Get Regexp Matches     ${v3trap_result}     v3 trap-host ([0-9\.]+) (.*)    1    2
    ${len_com}    Get Length     ${com}
    ${len_trap}    Get Length     ${trap}
    ${len_v3_trap}     Get Length     ${v3trap}

    Log     ***************** Removing existing SNMP configuration *************************
    Run Keyword If     ${len_v3_trap} > 0    Removing SNMPv3 trap      ${device}     ${len_v3_trap}     ${v3trap}
    Run Keyword If     ${len_trap} > 0     Removing SNMP trap     ${device}     ${len_trap}     ${trap}
    Run Keyword If     ${len_com} > 0    Removing SNMP community      ${device}     ${len_com}    ${com}

Removing SNMP community
    [Arguments]    ${device}     ${len_com}    ${com}
    [Documentation]        Removing SNMP community
    [Tags]        @author=ssekar

    : FOR    ${INDEX}    IN RANGE    0     ${len_com}
    \       ${community}    Get From List      ${com}     ${INDEX}
    \       Log    ${community}
    \       cli     ${device}        configure      timeout=90
    \       cli     ${device}        snmp v2 admin-state enable     timeout=90
    \       cli     ${device}        no v2 community ${community} ro
    \       cli     ${device}        end

Removing SNMPv3 trap
    [Arguments]    ${device}     ${len_v3_trap}     ${v3trap}
    [Documentation]        Removing SNMPv3 trap
    [Tags]        @author=ssekar

    : FOR    ${INDEX}    IN RANGE    0     ${len_v3_trap}
    \       ${tuple}    Get From List      ${v3trap}      ${INDEX}
    \       @{list1}    Convert To List    ${tuple}
    \       Log    ${list1}
    \       ${ip}    Get From List    ${list1}   0
    \       Log    ip: ${ip}
    \       ${user}     Get From List    ${list1}   1
    \       Log    user: ${user}
    \       cli     ${device}        configure      timeout=90
    \       cli     ${device}        snmp v3 admin-state enable     timeout=90
    \       cli     ${device}        no v3 trap-host ${ip} ${user}    timeout=90
    \       cli     ${device}        end     timeout=90

Removing SNMP trap
    [Arguments]    ${device}     ${len_trap}     ${trap}
    [Documentation]        Call SNMP
    [Tags]        @author=ssekar

    : FOR    ${INDEX}    IN RANGE    0     ${len_trap}
    \       ${tuple}    Get From List      ${trap}     ${INDEX}
    \       @{list1}    Convert To List    ${tuple}
    \       Log    ${list1}
    \       ${ip}    Get From List    ${list1}   0
    \       Log    ip: ${ip}
    \       ${com}     Get From List    ${list1}   1
    \       Log    com: ${com}
    \       cli     ${device}        configure      timeout=90
    \       cli     ${device}        snmp v2 admin-state enable     timeout=90
    \       cli     ${device}        no v2 trap-host ${ip} ${com}      timeout=90
    \       cli     ${device}        end     timeout=90

Adding New user under oper role
    [Arguments]    ${device}
    [Documentation]    Adding New user under oper role
    [Tags]        @author=ssekar

    cli     ${device}       configure      timeout=120
    cli     ${device}       aaa user newcafe password newcafe role oper       timeout=120
    cli     ${device}       end      timeout=120
    ${result}     cli     ${device}      show running-config aaa user newcafe role    timeout=120
    Should Contain      ${result}      oper

Removing configured user under oper role
    [Arguments]    ${device}
    [Documentation]    Removing configured user under oper role 
    [Tags]        @author=ssekar

    cli     ${device}       configure      timeout=120
    cli     ${device}       no aaa user newcafetimeout=120
    cli     ${device}       end      timeout=120

Triggering_Alarms_netconf
    [Arguments]    ${device1}    ${device1_linux_mode}      ${device1_port}      ${user_interface}=netconf
    [Documentation]    Triggering alarms on basis of severity
    [Tags]        @author=ssekar
   
    Log    *** Triggering Loss of Signal MAJOR alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering Loss of Signal MAJOR alarm    device=${device1}      linux=${device1_linux_mode}     user_interface=${user_interface}

    #Log    *** Trigerring one MINOR Alarm ***
    #Triggering RMON MINOR alarm       ${device1_linux_mode}       ${device1}     ${user_interface}

    Log    *** Triggering anyone INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    ${device1}      ${device1_linux_mode}     user_interface=${user_interface}

    Log    *** Triggering NTP prov alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Trigerring NTP prov alarm netconf       ${device1} 

Triggering alarm using dcli
    [Arguments]     ${device}    ${linux}    ${alarm}     ${env}=false
    [Documentation]    Triggering alarm using dcli
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}  
    Run Keyword If    '${alarm}' == 'module-fault'    cli      ${linux}      dcli evtmgrd evtpost module-fault MAJOR      timeout=120
    Run Keyword If    '${alarm}' == 'unsupported-equipment'   cli      ${linux}      dcli evtmgrd evtpost unsupported-equipment MAJOR      timeout=120
    Run Keyword If    '${alarm}' == 'source-verify-resources-limited'   cli      ${linux}      dcli evtmgrd evtpost source-verify-resources-limited MINOR 
    ...      timeout=120
    Run Keyword If    '${env}' == 'true' and '${alarm}' != 'environment-input'       cli      ${linux}      dcli evtmgrd evtpost ${alarm} CRITICAL     timeout=120
    Run Keyword If    '${alarm}' == 'environment-input'       cli      ${linux}      dcli evtmgrd evtpost ${alarm} INFO      timeout=120
    #Sleep for 5s
    Sleep     5s

    ${result}     Run Keyword If    '${alarm}' == 'module-fault'       cli      ${device}      show alarm active subscope id 1204      timeout=120
    Run Keyword If    '${alarm}' == 'module-fault'        Should Contain      ${result}      name module-fault
    ${result}     Run Keyword If    '${alarm}' == 'unsupported-equipment'      cli      ${device}      show alarm active subscope id 1225    timeout=120
    Run Keyword If    '${alarm}' == 'unsupported-equipment'      Should Contain      ${result}      name unsupported-equipment   
    ${result}     Run Keyword If    '${alarm}' == 'source-verify-resources-limited'   cli      ${device}      show alarm active subscope id 2302      timeout=120
    Run Keyword If    '${alarm}' == 'source-verify-resources-limited'    Should Contain      ${result}      name source-verify-resources-limited

    ${result}     Run Keyword If    '${alarm}' == 'environment-input'       cli      ${device}      show alarm active subscope id 2601      timeout=120
    Run Keyword If    '${alarm}' == '${alarm}' == 'environment-input'       Should Contain      ${result}      name environment-input
    ${result}     Run Keyword If    '${env}' == 'true' and '${alarm}' != 'environment-input'        cli      ${device}      show alarm active subscope name ${alarm}  
    ...    timeout=120
    @{env_len}   Run Keyword If    '${env}' == 'true' and '${alarm}' != 'environment-input'       Get Regexp Matches    ${result}    (name ${alarm})      1
    ${env_len}   Run Keyword If    '${env}' == 'true' and '${alarm}' != 'environment-input'       Get Length     ${env_len}
    Run Keyword If    '${env}' == 'true' and '${alarm}' != 'environment-input'       Should Be True     ${env_len} > 1

Clearing alarm using dcli
    [Arguments]     ${device}      ${linux}    ${alarm}    ${env}=false
    [Documentation]    Clearing alarm using dcli
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    Run Keyword If    '${alarm}' == 'module-fault'    cli      ${linux}      dcli evtmgrd evtpost module-fault CLEAR      timeout=120
    Run Keyword If    '${alarm}' == 'unsupported-equipment'   cli      ${linux}      dcli evtmgrd evtpost unsupported-equipment CLEAR      timeout=120
    Run Keyword If    '${alarm}' == 'source-verify-resources-limited'    cli      ${linux}      dcli evtmgrd evtpost source-verify-resources-limited CLEAR 
    ...      timeout=120
    Run Keyword If    '${env}' == 'true'        cli      ${linux}      dcli evtmgrd evtpost ${alarm} CLEAR      timeout=120
    #Sleep for 5s
    Sleep     5s

Triggering alarm for dhcp server detected
    [Arguments]     ${device}
    [Documentation]    Triggering alarm for dhcp server detected
    [Tags]        @author=ssekar

    cli    ${device}     configure        timeout=120
    cli    ${device}     interface craft 1      timeout=120
    cli    ${device}     ip dhcp server enable      timeout=120
    cli    ${device}     end       timeout=120
   
    ${result}     cli     ${device}     show alarm active subscope id 1917       timeout=120
    Should Contain      ${result}      name dhcp-server-detected
    ${raise_time}     Get Lines Containing String     ${result}     ne-event-time
    @{raise_time}     Get Regexp Matches    ${raise_time}      ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    Log    ${raise_time}
    [Return]     ${raise_time}
    
Clearing alarm for dhcp server detected
    [Arguments]     ${device}
    [Documentation]    Clearing alarm for dhcp server detected
    [Tags]        @author=ssekar

    cli    ${device}     configure       timeout=120
    cli    ${device}     interface craft 1       timeout=120
    cli    ${device}     no ip dhcp server       timeout=120
    cli    ${device}     end      timeout=120
    #Sleep for 5s
    Sleep    5s

    ${result}     cli     ${device}     show alarm active subscope id 1917     timeout=120
    Should Not Contain      ${result}      name dhcp-server-detected
    ${result}     cli     ${device}        show alarm history filter name dhcp-server-detected      timeout=50      prompt=\\#
    ${clear_time}      Get Lines Containing String     ${result}     ne-event-time
    @{clear_time}      Get Regexp Matches    ${clear_time}     ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    [Return]     ${clear_time}

Triggering alarm for improper-removal
    [Arguments]      ${device}      ${linux}
    [Documentation]    Triggering alarm for improper-removal
    [Tags]        @author=ssekar

    Log      ********** CLI: Verifying Admin state of PON interfaces are UP otherwise enabling it ************
    : FOR     ${INDEX}    IN RANGE    1    8
    \    ${admin_state}    cli    ${device}    show interface pon status admin-state | tab | include disable      timeout=50
    \    @{port_admin}     Get Regexp Matches    ${admin_state}     ([0-9a-z/]+).*    1
    \    ${length_port_admin}      Get Length     ${port_admin}
    \    ${port_admin_status}     Set Variable If    ${length_port_admin} > 1     admin_ports_down     admin_all_ports_up
    \    Exit For Loop If      '${port_admin_status}' == 'admin_all_ports_up'
    \    ${list_port_admin}    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     Get From List    ${port_admin}     1
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     cli    ${device}    configure      timeout=50
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     cli    ${device}    interface pon ${list_port_admin}
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'      cli    ${device}    no shut
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'      cli    ${device}    end

    Log      ********** Getting Interface which are in DOWN state in cli ************
    : FOR     ${INDEX}    IN RANGE    1    5
    \    ${result}        cli    ${device}    show interface pon status oper-state | tab | include down    timeout=50
    \    @{port_id}       Get Regexp Matches    ${result}    ([0-9a-z/]+).*    1
    \    ${length_port_id}      Get Length     ${port_id}
    \    ${port_status}    Set Variable If    ${length_port_id} > 1      port_down     all_ports_up
    \    ${port_id}    	Run Keyword If          '${port_status}' == 'port_down'    Get From List    ${port_id}    1
    \    Exit For Loop If      '${port_status}' == 'port_down'

    Run Keyword If     '${port_status}' == 'all_ports_up'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    Run Keyword If     '${port_status}' == 'all_ports_up'      cli    ${linux}     dcli evtmgrd evtpost improper-removal MAJOR      timeout=120

    Log      ********** Shut and unshut interface for Alarm to get triggered in cli ************
    Run Keyword If     '${port_status}' == 'port_down'     Run Keywords     cli    ${device}    configure      timeout=50
    ...    AND    cli    ${device}    interface pon ${port_id}     timeout=50
    ...    AND    cli    ${device}    shut     timeout=50
    #Sleep for 5s for Alarms to generate properly after shut
    ...    AND     BuiltIn.Sleep    5s
    ...    AND     cli    ${device}    no shut    timeout=50
    #Sleep for 10s after noshut
    ...    AND     BuiltIn.Sleep     10s
    ...    AND     cli    ${device}    end    prompt=\\#     timeout=50
    ...    AND     cli    ${device}    accept running-config     timeout=50
    ...    AND     cli    ${device}    copy running-config startup-config      timeout=50

    Log     ******* Verifying alarm got triggered in cli **********
    ${result1}       cli    ${device}    show alarm active subscope id 1203     timeout=50
    Should Contain     ${result1}    name improper-removal
    Run Keyword If     '${port_status}' == 'port_down'      Should Contain      ${result1}      ${port_id}']

    Log     ******* Returning down raised alarm time in cli *********
    ${raise_time}     Get Lines Containing String     ${result1}     ne-event-time
    @{raise_time}     Get Regexp Matches    ${raise_time}      ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    Log    ${raise_time}
    Return From Keyword     ${raise_time}
    #Run Keyword If     '${port_status}' == 'port_down'      Return From Keyword     ${port_id}     ${raise_time}

Clearing alarm for improper-removal
    [Arguments]      ${device}      ${linux}
    [Documentation]    Clearing alarm for improper-removal
    [Tags]        @author=ssekar

    Log      ********** Getting Interface which are in DOWN state in cli ************
    : FOR     ${INDEX}    IN RANGE    1    5
    \    ${result}        cli    ${device}    show interface pon status oper-state | tab | include down    timeout=50
    \    @{port_id}       Get Regexp Matches    ${result}    ([0-9a-z/]+).*    1
    \    ${length_port_id}      Get Length     ${port_id}
    \    ${port_status}    Set Variable If    ${length_port_id} > 1      port_down     all_ports_up
    \    ${port_id}     Run Keyword If          '${port_status}' == 'port_down'    Get From List    ${port_id}    1

    \    Exit For Loop If      '${port_status}' == 'port_down'

    Run Keyword If     '${port_status}' == 'all_ports_up'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    Run Keyword If     '${port_status}' == 'all_ports_up'      cli    ${linux}     dcli evtmgrd evtpost improper-removal CLEAR     timeout=120

    Run Keyword If     '${port_status}' == 'port_down'     Run Keywords     cli    ${device}    configure      timeout=50
    ...    AND    cli    ${device}    interface pon ${port_id}     timeout=50
    ...    AND     cli    ${device}    shut    timeout=50
    #Sleep for 10s after noshut
    ...    AND     BuiltIn.Sleep     10s
    ...    AND     cli    ${device}    end    prompt=\\#     timeout=50
    ...    AND     cli    ${device}    accept running-config     timeout=50
    ...    AND     cli    ${device}    copy running-config startup-config      timeout=50

    ${result1}       cli    ${device}    show alarm active subscope id 1203     timeout=50
    Run Keyword If     '${port_status}' == 'port_down'      Should Not Contain      ${result1}      ${port_id}']

    ${result}     cli     ${device}        show alarm history filter name improper-removal      timeout=50      prompt=\\#
    ${clear_time}      Get Lines Containing String     ${result}     ne-event-time
    @{clear_time}      Get Regexp Matches    ${clear_time}     ne-event-time .*T(\\d{2}:\\d{2}:\\d{2})   1
    [Return]     ${clear_time}

Triggering ont-arrival event
    [Arguments]      ${device}      ${linux}
    [Documentation]    Triggering ont-arrival event
    [Tags]        @author=ssekar

    Log      ********** CLI: Verifying Admin state of PON interfaces are UP otherwise enabling it ************
    : FOR     ${INDEX}    IN RANGE    1    8
    \    ${admin_state}    cli    ${device}    show interface pon status admin-state | tab | include disable      timeout=50
    \    @{port_admin}     Get Regexp Matches    ${admin_state}     ([0-9a-z/]+).*    1
    \    ${length_port_admin}      Get Length     ${port_admin}
    \    ${port_admin_status}     Set Variable If    ${length_port_admin} > 1     admin_ports_down     admin_all_ports_up
    \    Exit For Loop If      '${port_admin_status}' == 'admin_all_ports_up'
    \    ${list_port_admin}    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     Get From List    ${port_admin}     1
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     cli    ${device}    configure      timeout=50
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     cli    ${device}    interface pon ${list_port_admin}
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'      cli    ${device}    no shut
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'      cli    ${device}    end

    Log      ********** CLI: Getting PON interface which are in DOWN state **********
    : FOR     ${INDEX}    IN RANGE    1    5
    \    ${result}        cli    ${device}    show interface pon status oper-state | tab | include up    timeout=50
    \    @{port_id}       Get Regexp Matches    ${result}    ([0-9a-z/]+).*    1
    \    ${length_port_id}      Get Length     ${port_id}
    \    ${port_status}    Set Variable If    ${length_port_id} > 1      port_up     all_ports_down
    \    ${port_id}     Run Keyword If          '${port_status}' == 'port_up'    Get From List    ${port_id}    1

    \    Exit For Loop If      '${port_status}' == 'port_up'

    Run Keyword If     '${port_status}' == 'all_ports_down'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    Run Keyword If     '${port_status}' == 'all_ports_down'      cli    ${linux}     dcli evtmgrd evtpost ont-arrival MINOR    timeout=120

    Run Keyword If     '${port_status}' == 'port_up'     Run Keywords     cli    ${device}    configure      timeout=50
    ...    AND    cli    ${device}    interface pon ${port_id}     timeout=50
    ...    AND     cli    ${device}    shut    timeout=50
    #Sleep for 5s after shut
    ...    AND     sleep    5s
    ...    AND     cli    ${device}    no shut     timeout=50 
    #Sleep for 10s after no shut
    ...    AND     BuiltIn.Sleep     10s
    ...    AND     cli    ${device}    end    prompt=\\#     timeout=50
    ...    AND     cli    ${device}    accept running-config     timeout=50
    ...    AND     cli    ${device}    copy running-config startup-config      timeout=50

    ${result1}       cli    ${device}    show event filter name ont-arrival     timeout=50
    Run Keyword If     '${port_status}' == 'port_up'      Should Contain      ${result1}      ${port_id}']

Triggering ont-departure event
    [Arguments]      ${device}      ${linux}
    [Documentation]    Triggering ont-departure event
    [Tags]        @author=ssekar

    Log      ********** CLI: Verifying Admin state of PON interfaces are UP otherwise enabling it ************
    : FOR     ${INDEX}    IN RANGE    1    8
    \    ${admin_state}    cli    ${device}    show interface pon status admin-state | tab | include disable      timeout=50
    \    @{port_admin}     Get Regexp Matches    ${admin_state}     ([0-9a-z/]+).*    1
    \    ${length_port_admin}      Get Length     ${port_admin}
    \    ${port_admin_status}     Set Variable If    ${length_port_admin} > 1     admin_ports_down     admin_all_ports_up
    \    Exit For Loop If      '${port_admin_status}' == 'admin_all_ports_up'
    \    ${list_port_admin}    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     Get From List    ${port_admin}     1
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     cli    ${device}    configure      timeout=50
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'     cli    ${device}    interface pon ${list_port_admin}
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'      cli    ${device}    no shut
    \    Run Keyword If     '${port_admin_status}' == 'admin_ports_down'      cli    ${device}    end  

    Log      ********** CLI: Getting PON interface which are in UP state **********
    : FOR     ${INDEX}    IN RANGE    1    5
    \    ${result}        cli    ${device}    show interface pon status oper-state | tab | include up    timeout=50
    \    @{port_id}       Get Regexp Matches    ${result}    ([0-9a-z/]+).*    1
    \    ${length_port_id}      Get Length     ${port_id}
    \    ${port_status}    Set Variable If    ${length_port_id} > 1      port_up     all_ports_down
    \    ${port_id}     Run Keyword If          '${port_status}' == 'port_up'    Get From List    ${port_id}    1

    \    Exit For Loop If      '${port_status}' == 'port_up'

    Run Keyword If     '${port_status}' == 'all_ports_down'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    Run Keyword If     '${port_status}' == 'all_ports_down'      cli    ${linux}     dcli evtmgrd evtpost ont-departure MINOR    timeout=120

    Run Keyword If     '${port_status}' == 'port_up'     Run Keywords     cli    ${device}    configure      timeout=50
    ...    AND    cli    ${device}    interface pon ${port_id}     timeout=50
    ...    AND     cli    ${device}    shut    timeout=50
    #Sleep for 10s after shut
    ...    AND     BuiltIn.Sleep     10s
    ...    AND     cli    ${device}    end    prompt=\\#     timeout=50
    ...    AND     cli    ${device}    accept running-config     timeout=50
    ...    AND     cli    ${device}    copy running-config startup-config      timeout=50

    ${result1}       cli    ${device}    show event filter name ont-departure     timeout=50
    Run Keyword If     '${port_status}' == 'port_up'      Should Contain      ${result1}      ${port_id}']

Clearing ont-departure event
    [Arguments]      ${device}      ${linux}
    [Documentation]    Clearing ont-departure event 
    [Tags]        @author=ssekar

    Log      ********** Getting Interface which are in DOWN state in cli ************
    : FOR     ${INDEX}    IN RANGE    1    5
    \    ${result}        cli    ${device}    show interface pon status oper-state | tab | include down    timeout=50
    \    @{port_id}       Get Regexp Matches    ${result}    ([0-9a-z/]+).*    1
    \    ${length_port_id}      Get Length     ${port_id}
    \    ${port_status}    Set Variable If    ${length_port_id} > 1      port_down     all_ports_up
    \    ${port_id}     Run Keyword If          '${port_status}' == 'port_down'    Get From List    ${port_id}    1

    \    Exit For Loop If      '${port_status}' == 'port_down'

    Run Keyword If     '${port_status}' == 'all_ports_up'     Wait Until Keyword Succeeds      2 min     10 sec      Disconnect      ${linux}
    Run Keyword If     '${port_status}' == 'all_ports_up'      cli    ${linux}     dcli evtmgrd evtpost ont-departure CLEAR     timeout=120

    Run Keyword If     '${port_status}' == 'port_down'     Run Keywords     cli    ${device}    configure      timeout=50
    ...    AND    cli    ${device}    interface pon ${port_id}     timeout=50
    ...    AND     cli    ${device}    no shut    timeout=50
    #Sleep for 10s after noshut
    ...    AND     BuiltIn.Sleep     10s
    ...    AND     cli    ${device}    end    prompt=\\#     timeout=50
    ...    AND     cli    ${device}    accept running-config     timeout=50
    ...    AND     cli    ${device}    copy running-config startup-config      timeout=50

    ${result1}       cli    ${device}    show event filter name ont-departure    timeout=50
    Run Keyword If     '${port_status}' == 'port_down'      Should Not Contain      ${result1}      ${port_id}']
   
    ${result1}       cli    ${device}    show event filter name ont-arrival    timeout=50
    Run Keyword If     '${port_status}' == 'port_down'      Should Contain      ${result1}      ${port_id}']

Configuring OSPF on E3-2
    [Arguments]    ${device}    ${port1}     ${port2}    ${loopback_addr}    ${prefix-length}
    [Documentation]    Configuring OSPF for E3-2
    [Tags]        @author=ssekar

    cli    ${device}    configure      timeout=50
    cli    ${device}    router ospf 1     timeout=50
    cli    ${device}    area 0.0.0.255 nssa    timeout=50
    cli    ${device}    redistribute connected     timeout=50
    cli    ${device}    exit      timeout=50
    cli    ${device}    router-id ${loopback_addr}      timeout=50
    cli    ${device}    logging all     timeout=50
    cli    ${device}    graceful-restart enable      timeout=50
    cli    ${device}    exit     timeout=50
    cli    ${device}    interface ethernet ${port1}      timeout=50
    cli    ${device}    ip ospf 1 area 0.0.0.255       timeout=50
    cli    ${device}    no shut     timeout=50
    cli    ${device}    exit     timeout=50
    cli    ${device}    interface ethernet ${port2}      timeout=50
    cli    ${device}    ip ospf 1 area 0.0.0.255       timeout=50
    cli    ${device}    no shut     timeout=50
    cli    ${device}    exit     timeout=50
    cli    ${device}    interface loopback lo4     timeout=50
    cli    ${device}    no shut
    cli    ${device}    ip address ${loopback_addr} prefix-length ${prefix-length}     timeout=50
    cli    ${device}    ip ospf 1 area 0.0.0.255       timeout=50
    cli    ${device}    end     timeout=50
  
Unconfigure OSPF on E3-2
    [Arguments]    ${device}    ${port1}     ${port2}    
    [Documentation]    Unconfigure OSPF on E3-2
    [Tags]        @author=ssekar

    cli    ${device}    configure      timeout=50
    cli    ${device}    interface ethernet ${port1}      timeout=50
    cli    ${device}    no ip ospf 1        timeout=50
    cli    ${device}    exit     timeout=50
    cli    ${device}    interface ethernet ${port2}      timeout=50
    cli    ${device}    no ip ospf 1        timeout=50
    cli    ${device}    exit     timeout=50
    cli    ${device}    interface loopback lo4     timeout=50
    cli    ${device}    no ip address     timeout=50 
    cli    ${device}    no ip ospf 1        timeout=50
    cli    ${device}    exit     timeout=50
    cli    ${device}    router ospf 1     timeout=50
    cli    ${device}    no area     timeout=50
    cli    ${device}    no router ospf 1     timeout=50
    cli    ${device}    end     timeout=50

Verifying OSPF neighbors
    [Arguments]    ${device}    ${port1}     ${port2}
    [Documentation]    Verifying OSPF neighbors
    [Tags]        @author=ssekar

    #Sleep for 50s for OSPF neighbors to come UP
    Sleep    50s
    ${result}   cli    ${device}    show ip ospf neighbors       timeout=120    
    Should Contain      ${result}     FULL
    ${int}       Should Match Regexp    ${result}      ${port1}|${port2}  
    Log     ${int}

Generating techlog files
    [Arguments]    ${device}  
    [Documentation]    Generating techlog files
    [Tags]        @author=ssekar

    ${result}      cli     ${device}         delete file techlog filename all     timeout=120     prompt=\\#
    Should Contain       ${result}       OK
    ${result}     cli     ${device}         generate techlog generator lacp-techlog     timeout=120      prompt=\\#
    Should Contain       ${result}       status Initiating Tech Log generation
    : FOR    ${INDEX}    IN RANGE    1     20
    #Sleep for 20s
    \    Sleep     20s
    \    ${result}     cli     ${device}         show techlog status      timeout=120      prompt=\\#      timeout_exception=0
    \    Run Keyword Unless     'tar.gz' in '''${result}'''        Continue For Loop
    \    ${match}    Get Regexp Matches    ${result}    (techlog.*gz)      1
    \    ${len}      Get Length     ${match}
    \    Exit For Loop If     ${len} > 0
    ${techlog_filename}        Get From List    ${match}    0
    Log     ${techlog_filename}
    [Return]     ${techlog_filename}    

Triggering_Alarms
    [Arguments]    ${device1}    ${device1_linux_mode}      ${device1_port}      ${user_interface}=cli
    [Documentation]    Triggering alarms on basis of severity
    [Tags]        @author=ssekar

    Log    *** Trigerring Alarms ***
    #Triggering CRITICAL alarm       ${device1_linux_mode}       ${device1}     ${user_interface}
    #Wait Until Keyword Succeeds      5 min     10 sec
    Triggering Loss of Signal MAJOR alarm    ${device1}      ${device1_linux_mode}      ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec    Trigerring NTP prov alarm      ${device1}
    #Triggering RMON MINOR alarm    ${device1_linux_mode}       ${device1}       ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    ${device1}      ${device1_linux_mode}          ${user_interface}

Clearing_Alarms
    [Arguments]    ${device1}      ${device1_linux_mode}      ${device1_port}      ${user_interface}=cli
    [Documentation]    Clearing alarms
    [Tags]        @author=ssekar

    Log    *** Clearing Alarms ***
    #Unsuppressing Active alarms     ${device1}    
    #Clearing RMON MINOR alarm     ${device1_linux_mode}       ${device1}      ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm       ${device1}
    Wait Until Keyword Succeeds      30 sec     10 sec      Clearing Loss of Signal MAJOR alarm     ${device1}      ${device1_linux_mode}      ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm    ${device1}     ${device1_linux_mode}     ${user_interface}
    #Clearing CRITICAL alarm           ${device1_linux_mode}       ${device1}      ${user_interface}

Clearing_Alarms_netconf
    [Arguments]    ${device1}      ${device1_linux_mode}      ${device1_port}     ${user_interface}=netconf
    [Documentation]    Clearing alarms
    [Tags]        @author=ssekar

    Log    *** Clearing Alarms ***
    #Unsuppressing Active alarms using netconf     ${device1}
    #Clearing RMON MINOR alarm     ${device1_linux_mode}       ${device1}      ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm netconf     ${device1}
    Wait Until Keyword Succeeds      30 sec    10 sec     Clearing Loss of Signal MAJOR alarm     device=${device1}      linux=${device1_linux_mode}     user_interface=${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm    ${device1}     ${device1_linux_mode}      ${user_interface}

Alarms_and_SNMP_setup
    [Arguments]    ${device1}    ${device1_linux_mode}=None      ${device1_port}=None      ${user_interface}=cli      ${local_pc_ip}=None     ${local_pc_password}=None
    [Documentation]    Triggering alarms and setting up SNMP
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec      Triggering CRITICAL alarm      ${device1_linux_mode}    ${device1}     ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec      Trigerring NTP prov alarm      ${device1}
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering any one alarm for severity INFO    ${device1}      user_interface=${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT       ${device1}         ${local_pc_ip}
    #SNMP_port_redirect_on_localpc       ${local_pc_ip}        ${local_pc_password}

Alarms_and_SNMP_teardown
    [Arguments]    ${device1}    ${device1_linux_mode}=None      ${device1_port}=None      ${user_interface}=cli      ${local_pc_ip}=None     ${local_pc_password}=None
    [Documentation]    Clearing Alarms and unconfiguring SNMP
    [Tags]        @author=ssekar

    Wait Until Keyword Succeeds      2 min     10 sec     Clearing CRITICAL alarm       ${device1_linux_mode}    ${device1}     ${user_interface}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm       ${device1}
    Run Keyword And Return Status      Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_start_trap    n1_snmp_v2   
    ...        port=${DEVICES.n1_snmp_v2.redirect}
    ${snmp_status}     Run Keyword And Return Status      Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap    n1_snmp_v2
    Wait Until Keyword Succeeds      2 min     10 sec     Unconfiguring_SNMP_on_DUT     ${device1}        ${local_pc_ip} 
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm    ${device1}     user_interface=${user_interface}
    #SNMP_port_redirect_removal_on_localpc       ${local_pc_ip}        ${local_pc_password}
