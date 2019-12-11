# 
# Synthesis run script generated by Vivado
# 

namespace eval rt {
    variable rc
}
set rt::rc [catch {
  uplevel #0 {
    set ::env(BUILTIN_SYNTH) true
    source $::env(HRT_TCL_PATH)/rtSynthPrep.tcl
    rt::HARTNDb_startJobStats
    set rt::cmdEcho 0
    rt::set_parameter writeXmsg true
    rt::set_parameter enableParallelHelperSpawn true
    set ::env(RT_TMP) "./.Xil/Vivado-12018-eecs-digital-207/realtime/tmp"
    if { [ info exists ::env(RT_TMP) ] } {
      file mkdir $::env(RT_TMP)
    }

    rt::delete_design

    set rt::partid xc7a100tcsg324-1
     file delete -force synth_hints.os

    set rt::multiChipSynthesisFlow false
    source $::env(SYNTH_COMMON)/common_vhdl.tcl
    set rt::defaultWorkLibName xil_defaultlib

    # Skipping read_* RTL commands because this is post-elab optimize flow
    set rt::useElabCache true
    if {$rt::useElabCache == false} {
      rt::read_verilog -sv -include {
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/image_rom_1
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/image_rom_map_1
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/alph_image_rom
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/alph_map_red_rom
  } {
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/FPGuitAr_Hero.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/audio_gen.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/beat_generator.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/clk_wizard_65.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/hex_to_decimal.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/music_lookup.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/note_generator.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/note_positions.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/picture_blob.sv
      /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/new/top_level.sv
      /var/local/xilinx-local/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv
    }
      rt::read_verilog -include {
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/image_rom_1
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/image_rom_map_1
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/alph_image_rom
    /afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.srcs/sources_1/ip/alph_map_red_rom
  } {
      ./.Xil/Vivado-12018-eecs-digital-207/realtime/image_rom_stub.v
      ./.Xil/Vivado-12018-eecs-digital-207/realtime/image_rom_map_stub.v
      ./.Xil/Vivado-12018-eecs-digital-207/realtime/alph_image_rom_stub.v
      ./.Xil/Vivado-12018-eecs-digital-207/realtime/alph_map_red_rom_stub.v
    }
      rt::read_vhdl -lib xpm /var/local/xilinx-local/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd
      rt::filesetChecksum
    }
    rt::set_parameter usePostFindUniquification true
    set rt::SDCFileList ./.Xil/Vivado-12018-eecs-digital-207/realtime/labkit_synth.xdc
    rt::sdcChecksum
    set rt::top labkit
    rt::set_parameter enableIncremental true
    set rt::reportTiming false
    rt::set_parameter elaborateOnly false
    rt::set_parameter elaborateRtl false
    rt::set_parameter eliminateRedundantBitOperator true
    rt::set_parameter elaborateRtlOnlyFlow false
    rt::set_parameter writeBlackboxInterface true
    rt::set_parameter ramStyle auto
    rt::set_parameter merge_flipflops true
# MODE: 
    rt::set_parameter webTalkPath {/afs/athena.mit.edu/user/a/d/addiaz15/FPGuitAr/project_2/project_2.cache/wt}
    rt::set_parameter enableSplitFlowPath "./.Xil/Vivado-12018-eecs-digital-207/"
    set ok_to_delete_rt_tmp true 
    if { [rt::get_parameter parallelDebug] } { 
       set ok_to_delete_rt_tmp false 
    } 
    if {$rt::useElabCache == false} {
        set oldMIITMVal [rt::get_parameter maxInputIncreaseToMerge]; rt::set_parameter maxInputIncreaseToMerge 1000
        set oldCDPCRL [rt::get_parameter createDfgPartConstrRecurLimit]; rt::set_parameter createDfgPartConstrRecurLimit 1
        $rt::db readXRFFile
      rt::run_synthesis -module $rt::top
        rt::set_parameter maxInputIncreaseToMerge $oldMIITMVal
        rt::set_parameter createDfgPartConstrRecurLimit $oldCDPCRL
    }

    set rt::flowresult [ source $::env(SYNTH_COMMON)/flow.tcl ]
    rt::HARTNDb_stopJobStats
    rt::HARTNDb_reportJobStats "Synthesis Optimization Runtime"
    rt::HARTNDb_stopSystemStats
    if { $rt::flowresult == 1 } { return -code error }


  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] } { 
     $rt::db killSynthHelper $hsKey
  } 
  rt::set_parameter helper_shm_key "" 
    if { [ info exists ::env(RT_TMP) ] } {
      if { [info exists ok_to_delete_rt_tmp] && $ok_to_delete_rt_tmp } { 
        file delete -force $::env(RT_TMP)
      }
    }

    source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  } ; #end uplevel
} rt::result]

if { $rt::rc } {
  $rt::db resetHdlParse
  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] } { 
     $rt::db killSynthHelper $hsKey
  } 
  source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  return -code "error" $rt::result
}