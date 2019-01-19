*** Settings ***
Documentation    Resource file for IGMP test suites
Resource     ../base.robot
#Library      lib/lib_template.py
Resource        keyword/igmp_keyword.robot
Resource        case_template/template_common.robot
Resource        case_template/template_mvr_Video.robot
Resource        case_template/template_non_mvr_video.robot
Resource        case_template/template_ring_switch_check_mvr_video.robot
Resource        case_template/template_ring_switch_check_non_mvr_video.robot
