First Inspection:  
- In **IR_IMB_R**, take IMB_ALD_NUM=21 and IMB_ALD_NUM=20, IMB_ALD_DTD which is a date, also take BEN_NIR_PSA BEN_RNG_GEM
- Year of IMB_ALD_DTD should be 2011
- Inner Join with **ER_PRS_F** by BEN_NIR_PSA BEN_RNG_GEM, take FLX_DIS_DTD FLX_TRT_DTD FLX_EMT_TYP FLX_EMT_NUM FLX_EMT_ORD ORG_CLE_NUM DCT_ORD_NUM PRS_ORD_NUM REM_TYP_AFF, also take BEN_NAI_ANN^which is a string (e.g. 1979)
- Calculate Age=Year(IMB_ALD_DTD)-BEN_NAI_ANN, only take if Age>50
- Inner Join with **ER_CAM_F** by FLX_DIS_DTD FLX_TRT_DTD FLX_EMT_TYP FLX_EMT_NUM FLX_EMT_ORD ORG_CLE_NUM DCT_ORD_NUM PRS_ORD_NUM REM_TYP_AFF, take CAM_PRS_IDE
