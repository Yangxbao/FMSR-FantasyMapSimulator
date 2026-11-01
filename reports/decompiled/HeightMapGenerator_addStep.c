
void HeightMapGenerator__addStep
               (undefined8 param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
               undefined8 param_5,undefined8 param_6)

{
  char cVar1;
  int iVar2;
  longlong lVar3;
  undefined8 local_48;
  undefined8 local_40;
  undefined8 uStack_38;
  undefined8 local_30;
  
  if (DAT_18305fba1 == '\0') {
    FUN_1802334a0(&DAT_182efe510);
    FUN_1802334a0(&DAT_182ed7aa0);
    FUN_1802334a0(&DAT_182e867b0);
    FUN_1802334a0(&DAT_182ea18e0);
    FUN_1802334a0(&DAT_182e8bdc8);
    FUN_1802334a0(&DAT_182eeb518);
    FUN_1802334a0(&DAT_182ed4de0);
    FUN_1802334a0(&DAT_182e9c418);
    FUN_1802334a0(&DAT_182eeb258);
    FUN_1802334a0(&DAT_182ebec80);
    FUN_1802334a0(&DAT_182ed29b0);
    DAT_18305fba1 = '\x01';
  }
  cVar1 = System_String__Equals(param_2,DAT_182ebec80,0);
  if (cVar1 != '\0') {
    local_30 = 0;
    local_40 = 0;
    uStack_38 = 0;
    local_48 = param_1;
    FUN_180232f70(&local_48,param_1);
    local_40 = param_4;
    FUN_180232f70(&local_40,param_4);
    uStack_38 = param_5;
    FUN_180232f70(&uStack_38,param_5);
    local_30 = param_6;
    FUN_180232f70(&local_30,param_6);
    for (iVar2 = RandomUtils__GetNumberInRange(param_3,0); 0 < iVar2; iVar2 = iVar2 + -1) {
      HeightMapGenerator__<addHill>g__addOneHill_13_0(param_1,&local_48,0);
    }
  }
  cVar1 = System_String__Equals(param_2,DAT_182ed7aa0,0);
  if (cVar1 != '\0') {
    local_30 = 0;
    local_40 = 0;
    uStack_38 = 0;
    local_48 = param_1;
    FUN_180232f70(&local_48,param_1);
    local_40 = param_4;
    FUN_180232f70(&local_40,param_4);
    uStack_38 = param_5;
    FUN_180232f70(&uStack_38,param_5);
    local_30 = param_6;
    FUN_180232f70(&local_30,param_6);
    for (iVar2 = RandomUtils__GetNumberInRange(param_3,0); 0 < iVar2; iVar2 = iVar2 + -1) {
      HeightMapGenerator__<addPit>g__addOnePit_14_0(param_1,&local_48,0);
    }
  }
  cVar1 = System_String__Equals(param_2,DAT_182eeb258,0);
  if (cVar1 != '\0') {
    if (DAT_18305fb9c == '\0') {
      FUN_1802334a0(&DAT_182e9ab58);
      DAT_18305fb9c = '\x01';
    }
    lVar3 = thunk_FUN_1802a5470(DAT_182e9ab58);
    if (lVar3 == 0) goto LAB_18038f394;
    MostEnemyArmyProvinceStrategy___ctor(lVar3,0);
    *(undefined8 *)(lVar3 + 0x10) = param_4;
    FUN_180232f70(lVar3 + 0x10,param_4);
    *(undefined8 *)(lVar3 + 0x18) = param_1;
    FUN_180232f70(lVar3 + 0x18,param_1);
    *(undefined8 *)(lVar3 + 0x20) = param_5;
    FUN_180232f70(lVar3 + 0x20,param_5);
    *(undefined8 *)(lVar3 + 0x28) = param_6;
    FUN_180232f70(lVar3 + 0x28,param_6);
    for (iVar2 = RandomUtils__GetNumberInRange(param_3,0); 0 < iVar2; iVar2 = iVar2 + -1) {
      HeightMapGenerator_<>c__DisplayClass15_0__<addRange>g__addOneRange_0(lVar3,0);
    }
  }
  cVar1 = System_String__Equals(param_2,DAT_182eeb518,0);
  if (cVar1 != '\0') {
    if (DAT_18305fb9d == '\0') {
      FUN_1802334a0(&DAT_182e9ac28);
      DAT_18305fb9d = '\x01';
    }
    lVar3 = thunk_FUN_1802a5470(DAT_182e9ac28);
    if (lVar3 == 0) {
LAB_18038f394:
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    MostEnemyArmyProvinceStrategy___ctor(lVar3,0);
    *(undefined8 *)(lVar3 + 0x10) = param_1;
    FUN_180232f70(lVar3 + 0x10,param_1);
    *(undefined8 *)(lVar3 + 0x18) = param_4;
    FUN_180232f70(lVar3 + 0x18,param_4);
    *(undefined8 *)(lVar3 + 0x20) = param_5;
    FUN_180232f70(lVar3 + 0x20,param_5);
    *(undefined8 *)(lVar3 + 0x28) = param_6;
    FUN_180232f70(lVar3 + 0x28,param_6);
    for (iVar2 = RandomUtils__GetNumberInRange(param_3,0); 0 < iVar2; iVar2 = iVar2 + -1) {
      HeightMapGenerator_<>c__DisplayClass16_0__<addTrough>g__addOneTrough_0(lVar3,0);
    }
  }
  cVar1 = System_String__Equals(param_2,DAT_182e9c418,0);
  if (cVar1 != '\0') {
    HeightMapGenerator__addStrait(param_1,param_3,param_4,0);
  }
  cVar1 = System_String__Equals(param_2,DAT_182e867b0,0);
  if (cVar1 != '\0') {
    HeightMapGenerator__mask(param_1,param_3,0);
  }
  cVar1 = System_String__Equals(param_2,DAT_182efe510,0);
  if (cVar1 != '\0') {
    HeightMapGenerator__Modify(param_1,param_4,param_3,DAT_182ed4de0,0,0);
  }
  cVar1 = System_String__Equals(param_2,DAT_182ea18e0,0);
  if (cVar1 != '\0') {
    HeightMapGenerator__Modify(param_1,param_4,DAT_182ed29b0,param_3,0,0);
  }
  cVar1 = System_String__Equals(param_2,DAT_182e8bdc8,0);
  if (cVar1 != '\0') {
    HeightMapGenerator__smooth(param_1,param_3,DAT_182ed29b0,0);
  }
  return;
}

