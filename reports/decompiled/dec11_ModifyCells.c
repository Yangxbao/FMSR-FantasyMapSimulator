
void HeightMapGenerator__ModifyCells
               (undefined8 param_1,undefined8 param_2,undefined4 param_3,longlong param_4)

{
  int iVar1;
  char cVar2;
  undefined1 uVar3;
  int iVar4;
  undefined4 uVar5;
  longlong lVar6;
  longlong lVar7;
  longlong lVar8;
  undefined8 uVar9;
  undefined8 uVar10;
  undefined1 local_58 [56];
  
  if (DAT_18305fba7 == '\0') {
    FUN_1802334a0(&DAT_182edcd98);
    FUN_1802334a0(&DAT_182e95558);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182e7eb28);
    FUN_1802334a0(&DAT_182e940c8);
    FUN_1802334a0(&DAT_182e93d88);
    FUN_1802334a0(&DAT_182ecb590);
    FUN_1802334a0(&DAT_182ecb668);
    FUN_1802334a0(&DAT_182ecb740);
    FUN_1802334a0(&DAT_182ecb818);
    FUN_1802334a0(&DAT_182e9adc8);
    FUN_1802334a0(&DAT_182ee2b08);
    FUN_1802334a0(&DAT_182e74c20);
    FUN_1802334a0(&DAT_182eec148);
    FUN_1802334a0(&DAT_182ef4a18);
    FUN_1802334a0(&DAT_182ed4d18);
    FUN_1802334a0(&DAT_182ef6f48);
    DAT_18305fba7 = '\x01';
  }
  lVar6 = thunk_FUN_1802a5470(DAT_182e9adc8);
  if (lVar6 == 0) goto LAB_18038c849;
  MostEnemyArmyProvinceStrategy___ctor(lVar6,0);
  *(undefined4 *)(lVar6 + 0x14) = param_3;
  *(undefined8 *)(lVar6 + 0x20) = param_1;
  FUN_180232f70(lVar6 + 0x20,param_1);
  if (*(int *)(DAT_182ee2b08 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  lVar7 = World__get_Instance(0);
  if ((lVar7 == 0) || (*(longlong *)(lVar7 + 0x148) == 0)) goto LAB_18038c849;
  *(undefined8 *)(lVar6 + 0x28) = *(undefined8 *)(*(longlong *)(lVar7 + 0x148) + 0x18);
  FUN_180232f70(lVar6 + 0x28);
  cVar2 = System_String__Equals(param_4,DAT_182ed4d18,0);
  if (cVar2 == '\0') {
    cVar2 = System_String__Equals(param_4,DAT_182ef6f48,0);
    if (cVar2 == '\0') {
      if ((param_4 == 0) || (lVar7 = System_String__Split(param_4,0x2d,0,0), lVar7 == 0))
      goto LAB_18038c849;
      if (*(int *)(lVar7 + 0x18) == 0) {
LAB_18038c8a0:
                    /* WARNING: Subroutine does not return */
        FUN_180233670();
      }
      uVar5 = System_Single__Parse(*(undefined8 *)(lVar7 + 0x20),0);
      *(undefined4 *)(lVar6 + 0x30) = uVar5;
      if (*(uint *)(lVar7 + 0x18) < 2) goto LAB_18038c8a0;
      uVar5 = System_Single__Parse(*(undefined8 *)(lVar7 + 0x28),0);
      *(undefined4 *)(lVar6 + 0x34) = uVar5;
      if (*(float *)(lVar6 + 0x30) == 20.0) {
        uVar3 = 1;
        goto LAB_18038c605;
      }
    }
    else {
      *(undefined4 *)(lVar6 + 0x30) = 0;
      *(undefined4 *)(lVar6 + 0x34) = 0x42c80000;
    }
    uVar3 = 0;
  }
  else {
    *(undefined4 *)(lVar6 + 0x30) = 0x41a00000;
    uVar3 = 1;
    *(undefined4 *)(lVar6 + 0x34) = 0x42c80000;
  }
LAB_18038c605:
  *(undefined1 *)(lVar6 + 0x10) = uVar3;
  cVar2 = System_String__Equals(param_2,DAT_182ef4a18,0);
  if (cVar2 == '\0') {
    cVar2 = System_String__Equals(param_2,DAT_182eec148,0);
    if (cVar2 == '\0') {
      cVar2 = System_String__Equals(param_2,DAT_182e74c20,0);
      if (cVar2 == '\0') {
        uVar9 = thunk_FUN_180225b60(&DAT_182e98f38);
        uVar9 = thunk_FUN_1802a5470(uVar9);
        FUN_180002ff0(uVar9);
        uVar10 = thunk_FUN_180225b60(&DAT_182e798b8);
        System_ArgumentException___ctor(uVar9,uVar10,0);
        uVar10 = thunk_FUN_180225b60(&DAT_182ecc738);
                    /* WARNING: Subroutine does not return */
        FUN_180233640(uVar9,uVar10);
      }
      lVar7 = thunk_FUN_1802a5470(DAT_182e95558);
      uVar9 = DAT_182ecb740;
    }
    else {
      lVar7 = thunk_FUN_1802a5470(DAT_182e95558);
      uVar9 = DAT_182ecb668;
    }
  }
  else {
    lVar7 = thunk_FUN_1802a5470(DAT_182e95558);
    uVar9 = DAT_182ecb590;
  }
  if (lVar7 != 0) {
    FUN_18129a570(lVar7,lVar6,uVar9,0);
    *(longlong *)(lVar6 + 0x38) = lVar7;
    FUN_180232f70(lVar6 + 0x38,lVar7);
    iVar4 = thunk_FUN_18029fca0(0);
    if (*(longlong *)(lVar6 + 0x20) != 0) {
      iVar1 = *(int *)(*(longlong *)(lVar6 + 0x20) + 0x18);
      if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      uVar5 = System_Math__Max(1,(longlong)iVar1 / (longlong)(iVar4 * 4) & 0xffffffff,0);
      *(undefined4 *)(lVar6 + 0x18) = uVar5;
      if (*(longlong *)(lVar6 + 0x20) != 0) {
        uVar5 = *(undefined4 *)(*(longlong *)(lVar6 + 0x20) + 0x18);
        lVar7 = thunk_FUN_1802a5470(DAT_182e940c8);
        if (lVar7 != 0) {
          System_Threading_Tasks_ParallelOptions___ctor(lVar7,0);
          System_Threading_Tasks_ParallelOptions__set_MaxDegreeOfParallelism(lVar7,iVar4,0);
          lVar8 = thunk_FUN_1802a5470(DAT_182edcd98);
          if (lVar8 != 0) {
            Steamworks_SteamAPI_CheckCallbackRegistered_t___ctor(lVar8,lVar6,DAT_182ecb818,0);
            if (*(int *)(DAT_182e93d88 + 0xe0) == 0) {
              il2cpp_runtime_class_init();
            }
            System_Threading_Tasks_Parallel__For(local_58,0,uVar5,lVar7,lVar8,0);
            return;
          }
        }
      }
    }
  }
LAB_18038c849:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

