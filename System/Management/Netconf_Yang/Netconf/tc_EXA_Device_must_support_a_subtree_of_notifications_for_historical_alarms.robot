*** Settings ***
Documentation     The historical alarm subtree contains all historical alarms chronologically ordered from latest to oldest. Historical alarms are those alarms that are acknowledged, and cleared
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=dzala
Resource          ./base.robot

*** Variables ***
@{alarm}          []
@{output}         []

*** Test Cases ***
tc_EXA_Device_must_support_a_subtree_of_notifications_for_historical_alarms
    [Documentation]    Support a subtree of notification for historical alarms
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1769       @globalid=2322300

    #Get netconf attributes for ne-event
    @{elem}=    Get attributes netconf    n1_session3    /status/system/alarm/instances/history/detail/alarm    ne-event-time

    # To retrieve the capabilites from xml
    ${count}    Get Length    ${elem}
    :FOR    ${index}    IN RANGE    ${count}-1
    \    ${alarm-time}=    Convert Date    ${elem[${count}-1].text}    result_format=%Y-%m-%d %H:%M
    \    log    ${alarm-time}
    \    Append to list    ${alarm}    ${alarm-time}

    #calculate the alarm list and display
    ${length}    Get Length    ${alarm}
    ${length}    Evaluate    ${length}-1
    log list    ${alarm}

    #Verificaiton
    :FOR    ${index1}    IN RANGE    1    ${length}
    \    ${ini_index}    Evaluate    ${index1}+1
    \    log many    @{alarm}[${ini_index}]    @{alarm}[${index1}]
    \    ${res}    Subtract Date From Date    @{alarm}[${ini_index}]    @{alarm}[${index1}]
    \    should be true    ${res} >= 0
