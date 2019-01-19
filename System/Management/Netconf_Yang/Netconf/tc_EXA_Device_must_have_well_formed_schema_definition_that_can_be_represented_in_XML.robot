*** Settings ***
Documentation     There are two key approaches to having a well defined schema with NETCONF;
...               YANG - We can defined YANG based models and generate XSD for managers to facilitate their interaction with our NETCONF agent
...               XSD - We can define native XSDs
...               Either way is acceptable. What is not acceptable is not having a well defined grammar to facilitate developing and using managers to interact with our NETCONF agent.
...               An XML schema defines element and attribute names for a class of XML documents. the W3C defines what a well formed schema is here in the specifications section (A list of tools capable of validating schemas is also provided). The schema also specifies the structure that those documents must follow and the type of content that each element can hold.
...               XML documents that are dervied from an XML schema are defined to be instances of that schema. If they correctly follow the schema, then they are valid instances. This is not the same as being well formed. A well-formed XML document follows all the syntax rules of XML, but it does necessarily adhere to any particular schema. So, an XML document can be well formed without being valid, but it cannot be valid unless it is well formed.
...               An XML schema is defined using the following primitives:
...               Note: See http://www.w3.org/TR/2012/REC-xmlschema11-2-20120405/ for w3c standard describing data types.

Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=pmunisam
Resource          ./base.robot

*** Variables ***
${command}         //system/user-sessions
${namespace}    http
${format}    yang
${identifier}    aaa

*** Test Cases ***
tc_EXA_Device_must_have_well_formed_schema_definition_that_can_be_represented_in_XML
    [Documentation]    1 Open netconf session: ssh < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password. Enter password
    ...    2 Send "hello" rpc. Does not reject Enable "urn:ietf:params:netconf:base:1.0" capability
    ...    3 send "get-schema" rpc Returns the schema Alternatively, it might be a "get" rpc filtering for the schema.
    ...    4 Verify the schema is well-formed. It is well formed.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1788     @globalid=2322319   dual_card_not_support   @jira=EXA-29537
    
    log    STEP:1 Open netconf session: ssh < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password. Enter password
    log    STEP:2 Send "hello" rpc. Does not reject Enable "urn:ietf:params:netconf:base:1.0" capability
    log    STEP:3 send "get-schema" rpc Returns the schema Alternatively, it might be a "get" rpc filtering for the schema.
    log    STEP:4 Verify the schema is well-formed. It is well formed.
    
    
    #logging in using EXA device
    @{elem}    Get attributes netconf    n1_session3    ${command}    session-login
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0     ${count}
     \      ${val}=   Set Variable If   "${elem[${index}].text}" == "${DEVICES.n1_session3.user_interface}"   1
    Run Keyword If   "${val}" == "1"  log   user ${DEVICES.n1_session3.user_interface} is logged in     ELSE    log    ERROR:user ${DEVICES.n1_session3.user_interface} is not logged in
    
    # Send "get-schema" rpc
    ${get_schema}    set variable   <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="21"><get><filter type="subtree"><ncm:netconf-state xmlns:ncm="urn:ietf:params:xml:ns:yang:ietf-netconf-monitoring"><ncm:schemas/></ncm:netconf-state></filter></get></rpc>
    ${result} =    Netconf Raw    n1_session3    ${get_schema}
    
    #verifying if identifier present in the schema
    ${res}   Raw netconf configure    n1_session3    ${get_schema}    identifier
    should be equal as strings  ${res[0].text}    ${identifier}
    
    #verifying if version present in the schema
    #show version in cli didnt help as the value that comes in the result differs from the result that is produced passing the rpc
    ${res}   Raw netconf configure    n1_session3    ${get_schema}    version
    Should Match Regexp    ${res[0].text}    \\d+-\\d+-\\d+
    
    #verifying if format present in the schema
    ${res}   Raw netconf configure    n1_session3    ${get_schema}    format
    should be equal as strings  ${res[0].text}    ${format}
    
    #verifying if namespace present in the schema
    ${res}   Raw netconf configure    n1_session3    ${get_schema}    namespace
    should contain  ${res[0].text}    ${namespace}
    
    #verifying if location present in the schema
    ${res}   Raw netconf configure    n1_session3    ${get_schema}    location
    should be equal as strings  ${res[0].text}    ${DEVICES.n1_session3.user_interface}
