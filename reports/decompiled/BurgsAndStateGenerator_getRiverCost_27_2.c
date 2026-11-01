
ulonglong BurgsAndStateGenerator__<ExpandProvinces>g__getRiverCost_27_2
                    (int param_1,undefined4 param_2,undefined8 param_3,longlong *param_4)

{
  longlong lVar1;
  char cVar2;
  int iVar3;
  float fVar4;
  undefined1 auVar5 [16];
  undefined1 auVar6 [16];
  undefined8 extraout_XMM0_Qb;
  
  if (DAT_183060254 == '\0') {
    FUN_1802334a0(&DAT_182ee41f0);
    FUN_1802334a0(&DAT_182efd560);
    DAT_183060254 = '\x01';
  }
  cVar2 = System_String__Equals(param_3,DAT_182efd560,0);
  if (cVar2 != '\0') {
    iVar3 = 0;
    if (param_1 == 0) {
      iVar3 = 100;
    }
    return (ulonglong)(uint)(float)iVar3;
  }
  if (param_1 == 0) {
    return 0;
  }
  if ((*param_4 != 0) && (lVar1 = *(longlong *)(*param_4 + 0x28), lVar1 != 0)) {
    fVar4 = (float)FUN_181428f50(lVar1,param_2,DAT_182ee41f0);
    auVar5._0_8_ = (double)MathUtility__MinMax((double)(fVar4 / 10.0),0x4034000000000000,
                                               0x4059000000000000,0);
    auVar5._8_8_ = extraout_XMM0_Qb;
    auVar6._4_12_ = auVar5._4_12_;
    auVar6._0_4_ = (float)auVar5._0_8_;
    return auVar6._0_8_;
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

