
void World__GenerateHeightMap(longlong param_1)

{
  longlong lVar1;
  undefined1 uVar2;
  undefined4 uVar3;
  int iVar4;
  longlong lVar5;
  longlong lVar6;
  undefined8 uVar7;
  float fVar8;
  undefined8 local_res8;
  
  if (DAT_183060f7d == '\0') {
    FUN_1802334a0(&DAT_182eb70a8);
    FUN_1802334a0(&DAT_182ee7460);
    FUN_1802334a0(&DAT_182e99c48);
    FUN_1802334a0(&DAT_182ee63d0);
    FUN_1802334a0(&DAT_182ea1280);
    FUN_1802334a0(&DAT_182ed74d8);
    FUN_1802334a0(&DAT_182e8a8a8);
    FUN_1802334a0(&DAT_182ee71e8);
    FUN_1802334a0(&DAT_182ee8278);
    FUN_1802334a0(&DAT_182ee8348);
    FUN_1802334a0(&DAT_182ee3460);
    FUN_1802334a0(&DAT_182ebd820);
    FUN_1802334a0(&DAT_182ef6820);
    FUN_1802334a0(&DAT_182e9f040);
    FUN_1802334a0(&DAT_182efe7a0);
    FUN_1802334a0(&DAT_182ebab10);
    FUN_1802334a0(&DAT_182ede180);
    FUN_1802334a0(&DAT_182e9f1e0);
    FUN_1802334a0(&DAT_182e9f110);
    FUN_1802334a0(&DAT_182e9ef70);
    FUN_1802334a0(&DAT_182e89890);
    FUN_1802334a0(&DAT_182e9f2b0);
    DAT_183060f7d = '\x01';
  }
  uVar3 = UnityEngine_Random__Range(0,0x7fffffff,0);
  *(undefined4 *)(param_1 + 0x1a4) = uVar3;
  *(undefined2 *)(param_1 + 0x2c1) = 0x100;
  lVar5 = BorderDataProcessor__get_Instance(0);
  if (lVar5 != 0) {
    *(undefined1 *)(lVar5 + 0xf0) = 1;
    *(undefined2 *)(param_1 + 0x3b0) = 0;
    *(undefined1 *)(param_1 + 0x17c) = 0;
    iVar4 = UnityEngine_Random__Range(0,3,0);
    *(bool *)(param_1 + 0x3b2) = iVar4 == 0;
    World__SetMapCoordinate(param_1,0);
    if (*(char *)(param_1 + 0x3b2) == '\0') {
      iVar4 = UnityEngine_Random__Range(1,3,0);
      iVar4 = (iVar4 + 1) * 10000;
    }
    else {
      iVar4 = 10000;
    }
    *(int *)(param_1 + 0x144) = iVar4;
    fVar8 = (float)UnityEngine_Random__Range(0);
    if ((1.0 < fVar8) || (59999 < *(int *)(param_1 + 0x140))) {
      uVar2 = 0;
    }
    else {
      World__GenerateNoiseHeightmap(param_1,0,0);
      uVar2 = 1;
    }
    *(undefined1 *)(param_1 + 0x3b0) = uVar2;
    lVar5 = thunk_FUN_1802a5470(DAT_182ee3460);
    if (lVar5 != 0) {
      FUN_1813e2b90(lVar5,DAT_182ee71e8);
      FUN_180304090(lVar5,DAT_182ebab10,DAT_182ee7460);
      FUN_180304090(lVar5,DAT_182ede180,DAT_182ee7460);
      FUN_180304090(lVar5,DAT_182e89890,DAT_182ee7460);
      FUN_180304090(lVar5,DAT_182efe7a0,DAT_182ee7460);
      FUN_180304090(lVar5,DAT_182ef6820,DAT_182ee7460);
      lVar6 = thunk_FUN_1802a5470(DAT_182ee3460);
      if (lVar6 != 0) {
        FUN_1813e2b90(lVar6,DAT_182ee71e8);
        FUN_180304090(lVar6,DAT_182e9ef70,DAT_182ee7460);
        FUN_180304090(lVar6,DAT_182e9f110,DAT_182ee7460);
        FUN_180304090(lVar6,DAT_182e9f110,DAT_182ee7460);
        FUN_180304090(lVar6,DAT_182e9f110,DAT_182ee7460);
        FUN_180304090(lVar6,DAT_182e9f1e0,DAT_182ee7460);
        FUN_180304090(lVar6,DAT_182e9f2b0,DAT_182ee7460);
        FUN_180304090(lVar6,DAT_182e9f040,DAT_182ee7460);
        if (*(int *)(param_1 + 0x140) < 0xea61) {
          uVar3 = UnityEngine_Random__Range(0,*(undefined4 *)(lVar5 + 0x18),0);
          uVar7 = FUN_1813e2d10(lVar5,uVar3,DAT_182ee8348);
          *(undefined8 *)(param_1 + 0x3a8) = uVar7;
          FUN_180232f70(param_1 + 0x3a8,uVar7);
        }
        else {
          uVar3 = UnityEngine_Random__Range(0,*(undefined4 *)(lVar6 + 0x18),0);
          uVar7 = FUN_1813e2d10(lVar6,uVar3,DAT_182ee8348);
          *(undefined8 *)(param_1 + 0x3a8) = uVar7;
          FUN_180232f70(param_1 + 0x3a8,uVar7);
          *(undefined1 *)(param_1 + 0x3b2) = 0;
          *(undefined4 *)(param_1 + 0x144) = 40000;
        }
        uVar3 = UnityEngine_Random__Range(0,0x7fffffff,0);
        *(undefined4 *)(param_1 + 0x1a8) = uVar3;
        local_res8 = 0;
        SerializableVector2___ctor(&local_res8);
        *(undefined8 *)(param_1 + 0x3f0) = local_res8;
        *(undefined4 *)(param_1 + 0x3f8) = 0x3f800000;
        *(undefined4 *)(param_1 + 0x178) = 0x14;
        lVar5 = thunk_FUN_1802a5470(DAT_182ebd820);
        if (lVar5 != 0) {
          MostEnemyArmyProvinceStrategy___ctor(lVar5,0);
          System_Diagnostics_Stopwatch__Start(lVar5,0);
          World__ClearMap(param_1,1,0);
          lVar6 = *(longlong *)(param_1 + 0x220);
          if (lVar6 != 0) {
            iVar4 = *(int *)(lVar6 + 0x18);
            *(int *)(lVar6 + 0x1c) = *(int *)(lVar6 + 0x1c) + 1;
            *(undefined4 *)(lVar6 + 0x18) = 0;
            if (0 < iVar4) {
              System_Array__Clear(*(undefined8 *)(lVar6 + 0x10),0,iVar4,0);
            }
            if (*(longlong *)(param_1 + 0x228) != 0) {
              FUN_1812b6700(*(longlong *)(param_1 + 0x228),DAT_182eb70a8);
              System_Diagnostics_Stopwatch__Stop(lVar5,0);
              System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar5,0);
              lVar6 = thunk_FUN_1802a5470(DAT_182ebd820);
              if (lVar6 != 0) {
                MostEnemyArmyProvinceStrategy___ctor(lVar6,0);
                System_Diagnostics_Stopwatch__Start(lVar6,0);
                lVar6 = thunk_FUN_1802a5470(DAT_182ebd820);
                if (lVar6 != 0) {
                  MostEnemyArmyProvinceStrategy___ctor(lVar6,0);
                  System_Diagnostics_Stopwatch__Start(lVar6,0);
                  System_Diagnostics_Stopwatch__Restart(lVar5,0);
                  lVar1 = *(longlong *)(param_1 + 0x290);
                  if (lVar1 != 0) {
                    iVar4 = *(int *)(lVar1 + 0x18);
                    *(int *)(lVar1 + 0x1c) = *(int *)(lVar1 + 0x1c) + 1;
                    *(undefined4 *)(lVar1 + 0x18) = 0;
                    if (0 < iVar4) {
                      System_Array__Clear(*(undefined8 *)(lVar1 + 0x10),0,iVar4,0);
                    }
                    lVar1 = *(longlong *)(param_1 + 0x288);
                    if (lVar1 != 0) {
                      iVar4 = *(int *)(lVar1 + 0x18);
                      *(int *)(lVar1 + 0x1c) = *(int *)(lVar1 + 0x1c) + 1;
                      *(undefined4 *)(lVar1 + 0x18) = 0;
                      if (0 < iVar4) {
                        System_Array__Clear(*(undefined8 *)(lVar1 + 0x10),0,iVar4,0);
                      }
                      lVar1 = *(longlong *)(param_1 + 0x280);
                      if (lVar1 != 0) {
                        iVar4 = *(int *)(lVar1 + 0x18);
                        *(int *)(lVar1 + 0x1c) = *(int *)(lVar1 + 0x1c) + 1;
                        *(undefined4 *)(lVar1 + 0x18) = 0;
                        if (0 < iVar4) {
                          System_Array__Clear(*(undefined8 *)(lVar1 + 0x10),0,iVar4,0);
                        }
                        lVar1 = *(longlong *)(param_1 + 0x270);
                        if (lVar1 != 0) {
                          iVar4 = *(int *)(lVar1 + 0x18);
                          *(int *)(lVar1 + 0x1c) = *(int *)(lVar1 + 0x1c) + 1;
                          *(undefined4 *)(lVar1 + 0x18) = 0;
                          if (0 < iVar4) {
                            System_Array__Clear(*(undefined8 *)(lVar1 + 0x10),0,iVar4,0);
                          }
                          lVar1 = *(longlong *)(param_1 + 0x278);
                          if (lVar1 != 0) {
                            iVar4 = *(int *)(lVar1 + 0x18);
                            *(int *)(lVar1 + 0x1c) = *(int *)(lVar1 + 0x1c) + 1;
                            *(undefined4 *)(lVar1 + 0x18) = 0;
                            if (0 < iVar4) {
                              System_Array__Clear(*(undefined8 *)(lVar1 + 0x10),0,iVar4,0);
                            }
                            World__GenerateHeightMapFromJs(param_1,0);
                            World__SetSeaElvationToZero(param_1,0);
                            World__DrawRiver(param_1,0);
                            System_Diagnostics_Stopwatch__Stop(lVar5,0);
                            System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar5,0);
                            System_Diagnostics_Stopwatch__Stop(lVar6,0);
                            System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar6,0);
                            System_Diagnostics_Stopwatch__Restart(lVar5,0);
                            World__EnsureFeatureDataReady(param_1,0);
                            World__UpdateAllDrawProvince(param_1,0);
                            lVar5 = BorderDataProcessor__get_Instance(0);
                            if (lVar5 != 0) {
                              *(undefined1 *)(lVar5 + 0xee) = 1;
                              World__CloseUIPanel(param_1,0);
                              return;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

