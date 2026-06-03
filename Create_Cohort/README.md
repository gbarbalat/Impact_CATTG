# First Inspection

1- In **IR_IMB_R**, take Year of IMB_ALD_DTD=2011, IMB_ALD_NUM=23 (due to psych disorders), IMB_ALD_DTD which is a date, also take BEN_NIR_PSA BEN_RNG_GEM  
2- In **ER_PRS_F** take EXE_SOI_DTD in 2020 & FLX_DIS_DTD using magic loop, also take BEN_NIR_PSA BEN_RNG_GEM, take FLX_DIS_DTD FLX_TRT_DTD FLX_EMT_TYP FLX_EMT_NUM FLX_EMT_ORD ORG_CLE_NUM DCT_ORD_NUM PRS_ORD_NUM REM_TYP_AFF, also take BEN_NAI_ANN which is a string (e.g. 1979).  
3- In **ER_CAM_F** take FLX_DIS_DTD same as above, also take FLX_TRT_DTD FLX_EMT_TYP FLX_EMT_NUM FLX_EMT_ORD ORG_CLE_NUM DCT_ORD_NUM PRS_ORD_NUM REM_TYP_AFF, take CAM_PRS_IDE==QEQK004 as screening mammograms  
4- **Inner Join** by BEN_NIR_PSA BEN_RNG_GEM, and the 9 joining keys.
