
void HeightMapGenerator__mask(longlong param_1,undefined8 param_2)

{
  int iVar1;
  int iVar2;
  longlong lVar3;
  int iVar4;
  int iVar5;
  double dVar6;
  float fVar7;
  float fVar8;
  
  if (DAT_18305fba0 == '\0') {
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    DAT_18305fba0 = '\x01';
  }
  iVar1 = System_Int32__Parse(param_2,0);
  if (iVar1 == 0) {
    iVar5 = 1;
  }
  else {
    if (DAT_18305f9b4 == '\0') {
      FUN_1802334a0(&DAT_182e7eb28);
      DAT_18305f9b4 = '\x01';
    }
    if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    iVar5 = -iVar1;
    if (-iVar1 < 0) {
      iVar5 = iVar1;
    }
  }
  iVar4 = 0;
  lVar3 = *(longlong *)(param_1 + 0x18);
  while (lVar3 != 0) {
    if (*(int *)(lVar3 + 0x18) <= iVar4) {
      return;
    }
    if ((*(longlong *)(param_1 + 0x10) == 0) ||
       (lVar3 = World__GetSite(*(longlong *)(param_1 + 0x10),iVar4,0), lVar3 == 0)) break;
    fVar8 = (*(float *)(lVar3 + 0x10) + *(float *)(lVar3 + 0x10)) / (float)*(int *)(param_1 + 0x28)
            - 1.0;
    fVar7 = (*(float *)(lVar3 + 0x14) + *(float *)(lVar3 + 0x14)) / (float)*(int *)(param_1 + 0x2c)
            - 1.0;
    fVar7 = (1.0 - fVar7 * fVar7) * (1.0 - fVar8 * fVar8);
    if (iVar1 < 0) {
      fVar7 = 1.0 - fVar7;
    }
    if (*(longlong *)(param_1 + 0x18) == 0) break;
    iVar2 = FUN_1813fe630(*(longlong *)(param_1 + 0x18),iVar4,DAT_182ebe118);
    lVar3 = *(longlong *)(param_1 + 0x18);
    dVar6 = (double)MathUtility__Lim((double)(((float)((iVar5 + -1) * iVar2) + (float)iVar2 * fVar7)
                                             / (float)iVar5),0);
    if (lVar3 == 0) break;
    FUN_181409950(lVar3,iVar4,(int)dVar6,DAT_182ebe2c8);
    iVar4 = iVar4 + 1;
    lVar3 = *(longlong *)(param_1 + 0x18);
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

