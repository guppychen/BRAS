*** Settings ***
Resource          ../base.robot    #Resource    ../base.robot
Resource          case_template/template_bidirection_raw_traffic_and_check.robot    #Resource    caferobot/cafebase.robot
Resource          VLAN/case_template/run_dhcp_and_check_traffic.robot
