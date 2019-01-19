*** Settings ***
Documentation     This test suite is going to verify whether the alarm definitions can be filtered using subscope.
Suite Setup       alarm_definition_count    n1_netconf
Library           String
Library           Collections
Resource          base.robot
Force Tags

*** Test Cases ***
Alarm_Definition_Filter_Subscope
    [Documentation]    Test case verifies alarm definitions can be filtered using subscope
    ...                1. Verify alarm definitions can be displayed paginated and not paginated. Default is to paginate, but when disabled, no user intervention is required to display the entire list.(Not Supported for netconf)
    ...                2. Verify alarm definitions can be filtered by subscope categories. Alarm definition filter is working. show alarm definitions subscope category
    ...                3. Verify alarm definitions can be filtered by subscope count. Alarm definition filter is working.
    ...                4. Verify alarm definitions can be filtered by subscope ID. Alarm definition filter is working.
    ...                5. Verify alarm definitions can be filtered by subscope name. Alarm definition filter is working.
    ...                6. Verify alarm definitions can be filtered by subscope perceived severity. Alarm definition filter is working.
    [Tags]            @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2896    @functional    @priority=P2     @user_interface=netconf

    Log         *** Verify Alarm definitions get paginated (Not Supported) ***

    Log         *** Verifying Alarm definition subscope gets filtered using category ***
    Wait Until Keyword Succeeds    30 seconds    10 seconds    Alarm_definition_subscope_category_netconf    n1_netconf    ${total_count}

    Log         *** Verifying Alarm definition subscope gets filtered using name ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds     Alarm_definition_subscope_name_netconf     n1_netconf    ${total_count}

    Log         *** Verifying Alarm definition subscope gets filtered using count ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_definition_subscope_count_netconf     n1_netconf    ${total_count}

    Log         *** Verifying Alarm definition subscope gets filtered using id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_definition_subscope_ID_netconf    n1_netconf    ${total_count}

    Log         *** Verify Alarm definition filtered by severity ***
    @{total_severities}     Create List     CRITICAL   MAJOR   MINOR   INFO    WARNING    CLEAR     INFO
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity using netconf    n1_netconf    definition    ${severity}

*** Keyword ***
alarm_definition_count
    [Arguments]    ${device1}
    [Documentation]    Getting Alarm definition total count

    Log         *** Getting Alarm definition total count ***
    ${total_count}    Getting Alarm definition total count using netconf    ${device1}
    Set Suite Variable    ${total_count}    ${total_count}
