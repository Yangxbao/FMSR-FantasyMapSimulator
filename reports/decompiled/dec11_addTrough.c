
void HeightMapGenerator__addTrough
               (undefined8 param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
               undefined8 param_5)

{
  int iVar1;
  longlong lVar2;
  
  if (DAT_18305fb9d == '\0') {
    FUN_1802334a0(&DAT_182e9ac28);
    DAT_18305fb9d = '\x01';
  }
  lVar2 = thunk_FUN_1802a5470(DAT_182e9ac28);
  if (lVar2 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  MostEnemyArmyProvinceStrategy___ctor(lVar2,0);
  *(undefined8 *)(lVar2 + 0x10) = param_1;
  FUN_180232f70(lVar2 + 0x10,param_1);
  *(undefined8 *)(lVar2 + 0x18) = param_3;
  FUN_180232f70(lVar2 + 0x18,param_3);
  *(undefined8 *)(lVar2 + 0x20) = param_4;
  FUN_180232f70(lVar2 + 0x20,param_4);
  *(undefined8 *)(lVar2 + 0x28) = param_5;
  FUN_180232f70(lVar2 + 0x28);
  for (iVar1 = RandomUtils__GetNumberInRange(param_2,0); 0 < iVar1; iVar1 = iVar1 + -1) {
    HeightMapGenerator_<>c__DisplayClass16_0__<addTrough>g__addOneTrough_0(lVar2,0);
  }
  return;
}

