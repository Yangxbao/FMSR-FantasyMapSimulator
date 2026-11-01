
void World__GenerateBaseMap(longlong param_1,char param_2,longlong param_3)

{
  int iVar1;
  undefined4 uVar2;
  longlong lVar3;
  longlong lVar4;
  int iVar5;
  
  if (DAT_183060f81 == '\0') {
    FUN_1802334a0(&DAT_182eb3d70);
    FUN_1802334a0(&DAT_182e99c48);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182ebd820);
    DAT_183060f81 = '\x01';
  }
  lVar3 = thunk_FUN_1802a5470(DAT_182ebd820);
  if (lVar3 != 0) {
    MostEnemyArmyProvinceStrategy___ctor(lVar3);
    System_Diagnostics_Stopwatch__Start(lVar3);
    lVar4 = *(longlong *)(param_1 + 0x278);
    if (lVar4 != 0) {
      iVar5 = *(int *)(lVar4 + 0x18);
      *(int *)(lVar4 + 0x1c) = *(int *)(lVar4 + 0x1c) + 1;
      *(undefined4 *)(lVar4 + 0x18) = 0;
      if (0 < iVar5) {
        System_Array__Clear(*(undefined8 *)(lVar4 + 0x10),0,iVar5,0);
      }
      World__GenerateHeightMapFromJs(param_1);
      World__SetSeaElvationToZero(param_1);
      System_Diagnostics_Stopwatch__Stop(lVar3);
      System_Diagnostics_Stopwatch__Restart(lVar3);
      if (*(char *)(param_1 + 0x184) == '\0') {
        World__RankCellLegacy(param_1);
      }
      else {
        World__RankCellParallel();
      }
      System_Diagnostics_Stopwatch__Stop(lVar3,0);
      if ((param_2 == '\0') || (param_3 == 0)) {
LAB_1806ad78c:
        System_Diagnostics_Stopwatch__Restart(lVar3,0);
        lVar4 = thunk_FUN_1802a5470(DAT_182eb3d70);
        if (lVar4 != 0) {
          AISystemState___ctor(lVar4,param_1,0);
          CultureGenerator__Generate(lVar4,0);
          CultureGenerator__Expand(lVar4,0);
          System_Diagnostics_Stopwatch__Stop(lVar3,0);
          return;
        }
      }
      else {
        iVar5 = 0;
        lVar4 = *(longlong *)(param_1 + 0x148);
        while (lVar4 != 0) {
          if (*(int *)(lVar4 + 0x10) <= iVar5) goto LAB_1806ad78c;
          iVar1 = FUN_1813fe630(param_3);
          if ((iVar1 != 0) && (iVar1 = FUN_1813fe630(param_3), iVar1 != -1)) {
            if (*(longlong *)(param_1 + 0x148) == 0) break;
            lVar4 = *(longlong *)(*(longlong *)(param_1 + 0x148) + 0x40);
            uVar2 = FUN_1813fe630(param_3,iVar5,DAT_182ebe118);
            if (lVar4 == 0) break;
            FUN_181409950(lVar4,iVar5,uVar2,DAT_182ebe2c8);
          }
          iVar5 = iVar5 + 1;
          lVar4 = *(longlong *)(param_1 + 0x148);
        }
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

