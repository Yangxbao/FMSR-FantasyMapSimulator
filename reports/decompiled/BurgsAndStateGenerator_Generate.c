
void BurgsAndStateGenerator__Generate(longlong param_1,char param_2,char param_3)

{
  longlong lVar1;
  ulonglong uVar2;
  char cVar3;
  int iVar4;
  undefined4 uVar5;
  longlong lVar6;
  longlong lVar7;
  undefined8 uVar8;
  longlong lVar9;
  int iVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  longlong local_248 [2];
  longlong local_238;
  longlong *plStack_230;
  longlong local_228;
  longlong local_218;
  undefined8 local_208;
  longlong *plStack_200;
  undefined8 local_1f8;
  longlong local_1f0;
  longlong local_1e8;
  undefined8 uStack_1e0;
  ulonglong local_1d8;
  longlong local_1d0;
  longlong local_1c8;
  longlong local_1b8;
  longlong *plStack_1b0;
  longlong local_1a8;
  longlong *plStack_1a0;
  ulonglong local_198;
  longlong local_190;
  undefined8 uStack_188;
  ulonglong local_180;
  longlong local_178;
  longlong *plStack_170;
  longlong local_168;
  undefined8 uStack_160;
  ulonglong local_158;
  longlong local_150;
  longlong *local_148;
  
  if (DAT_183060226 == '\0') {
    FUN_1802334a0(&DAT_182eadff0);
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182ee8f80);
    FUN_1802334a0(&DAT_182ee5a80);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182efd4f0);
    FUN_1802334a0(&DAT_182f01cf8);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182f01dc8);
    FUN_1802334a0(&DAT_182efd5c8);
    FUN_1802334a0(&DAT_182efd698);
    FUN_1802334a0(&DAT_182f01ea0);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182e8ee38);
    FUN_1802334a0(&DAT_182ee2ed8);
    FUN_1802334a0(&DAT_182ee6300);
    FUN_1802334a0(&DAT_182ed7400);
    FUN_1802334a0(&DAT_182ee6228);
    FUN_1802334a0(&DAT_182ed7328);
    FUN_1802334a0(&DAT_182e9f200);
    FUN_1802334a0(&DAT_182ee63d0);
    FUN_1802334a0(&DAT_182ed7ac0);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ee67f8);
    FUN_1802334a0(&DAT_182e9f6e0);
    FUN_1802334a0(&DAT_182ed70a0);
    FUN_1802334a0(&DAT_182ee6c18);
    FUN_1802334a0(&DAT_182ed7fd0);
    FUN_1802334a0(&DAT_182e99eb8);
    FUN_1802334a0(&DAT_182ee6cf0);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ed80a8);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182ee07f0);
    FUN_1802334a0(&DAT_182ea90e8);
    FUN_1802334a0(&DAT_182ebbdf8);
    FUN_1802334a0(&DAT_182ebd820);
    FUN_1802334a0(&DAT_182ef98e0);
    FUN_1802334a0(&DAT_182efe8c8);
    FUN_1802334a0(&DAT_182e9d120);
    FUN_1802334a0(&DAT_182e9d870);
    FUN_1802334a0(&DAT_182e9d2c0);
    FUN_1802334a0(&DAT_182e9cf80);
    FUN_1802334a0(&DAT_182ed0e78);
    FUN_1802334a0(&DAT_182e9d1f0);
    FUN_1802334a0(&DAT_182ed0f50);
    FUN_1802334a0(&DAT_182e9d7a0);
    FUN_1802334a0(&DAT_182e9cd10);
    FUN_1802334a0(&DAT_182e9d600);
    FUN_1802334a0(&DAT_182eee758);
    FUN_1802334a0(&DAT_182e9d6d0);
    FUN_1802334a0(&DAT_182e9ceb0);
    FUN_1802334a0(&DAT_182e9d530);
    FUN_1802334a0(&DAT_182e9d460);
    FUN_1802334a0(&DAT_182e9cde0);
    FUN_1802334a0(&DAT_182e9d050);
    FUN_1802334a0(&DAT_182e9b360);
    FUN_1802334a0(&DAT_182e9d390);
    FUN_1802334a0(&DAT_182eeb180);
    FUN_1802334a0(&DAT_182e92378);
    FUN_1802334a0(&DAT_182e9d940);
    DAT_183060226 = '\x01';
  }
  iVar10 = 0;
  local_248[0] = 0;
  local_1a8 = 0;
  plStack_1a0 = (longlong *)0x0;
  local_198 = 0;
  local_190 = 0;
  uStack_188 = 0;
  local_180 = 0;
  local_1f8 = 0;
  local_1d0 = 0;
  local_168 = 0;
  uStack_160 = 0;
  local_158 = 0;
  lVar6 = thunk_FUN_1802a5470(DAT_182ebd820);
  local_218 = lVar6;
  if (lVar6 != 0) {
    MostEnemyArmyProvinceStrategy___ctor(lVar6,0);
    System_Diagnostics_Stopwatch__Start(lVar6,0);
    if (*(longlong *)(param_1 + 0x10) != 0) {
      local_1b8 = lVar6;
      if (param_2 != '\0') {
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
        local_1f0 = lVar9;
        local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d6d0,0);
        local_208 = 0;
        plStack_200 = local_248;
        lVar7 = thunk_FUN_1802a5470(DAT_182ee07f0);
        if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_1813e2b90(lVar7,DAT_182ed70a0);
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288);
        if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        local_1c8 = lVar7;
        FUN_1813e0e20(&local_238,lVar1,DAT_182ed7ac0);
        local_1a8 = local_238;
        plStack_1a0 = plStack_230;
        local_198 = local_228;
        local_178 = 0;
        plStack_170 = &local_1a8;
        while (cVar3 = FUN_1811ab230(&local_1a8,DAT_182efd5c8), uVar2 = local_198, cVar3 != '\0') {
          local_150 = local_198;
          if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(char *)(local_198 + 0x89) == '\0') {
            Province__DestroyBattleSword(local_198,0);
            if (*(longlong *)(uVar2 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_1813f96b0(&local_1e8,*(longlong *)(uVar2 + 0xa8),DAT_182ebd480);
            local_190 = local_1e8;
            uStack_188 = uStack_1e0;
            local_180 = local_1d8;
            local_238 = 0;
            plStack_230 = &local_190;
            while (cVar3 = FUN_1811a17e0(&local_190,DAT_182ef2178), cVar3 != '\0') {
              if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              if (*(longlong *)(lVar9 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              FUN_181409950(*(longlong *)(lVar9 + 0xc0),local_180 & 0xffffffff,0);
            }
            AISystemState__Start(&local_190,DAT_182ef20a0);
          }
          else {
            FUN_180304090(lVar7,local_198,DAT_182ed7328);
          }
        }
        AISystemState__Start(plStack_170,DAT_182efd4f0);
        lVar9 = *(longlong *)(param_1 + 0x10);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        *(longlong *)(lVar9 + 0x288) = lVar7;
        FUN_180232f70(lVar9 + 0x288,lVar7);
        BurgsAndStateGenerator__PlaceProvincialCapitalsByJitterGrid(param_1,0);
        if (*plStack_200 != 0) {
          FUN_180002f00(0,DAT_182ee2ed8,*plStack_200);
        }
      }
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d870,0);
      local_238 = 0;
      plStack_230 = local_248;
      BurgsAndStateGenerator__SelectCapitalsFromProvinces(param_1,0);
      if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
      uVar8 = BurgsAndStateGenerator__CreateStates(param_1,0);
      if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      FUN_1813e06d0(lVar9,uVar8,DAT_182ee6300);
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      local_1f0 = local_1b8;
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      local_1c8 = 0;
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9cde0,0);
      local_238 = 0;
      plStack_230 = local_248;
      uVar8 = *(undefined8 *)(param_1 + 0x10);
      lVar9 = thunk_FUN_1802a5470(DAT_182ea90e8);
      if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      AISystemState___ctor(lVar9,uVar8,0);
      local_1c8 = lVar9;
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      if (param_2 != '\0') {
        local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9cd10,0);
        local_238 = 0;
        plStack_230 = local_248;
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288);
        uVar8 = BurgsAndStateGenerator__CreateProvinces(param_1,0);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_1813e06d0(lVar9,uVar8,DAT_182ed7400);
        System_Diagnostics_Stopwatch__Stop(lVar6,0);
        System_Diagnostics_Stopwatch__Restart(lVar6,0);
        BurgsAndStateGenerator__ExpandProvinces(param_1,0);
        System_Diagnostics_Stopwatch__Stop(lVar6,0);
        System_Diagnostics_Stopwatch__Restart(lVar6,0);
        uVar8 = BurgsAndStateGenerator__CreateSeaProvinces(param_1,0);
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_1813e06d0(lVar9,uVar8,DAT_182ed7400);
        BurgsAndStateGenerator__ExpandSeaProvinces(param_1,0);
        if (local_248[0] != 0) {
          FUN_180002f00(0,DAT_182ee2ed8);
        }
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9ceb0,0);
      local_238 = 0;
      plStack_230 = local_248;
      BurgsAndStateGenerator__ExpandStates(param_1,0);
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9cf80,0);
      local_238 = 0;
      plStack_230 = local_248;
      BurgsAndStateGenerator__FilterProvinceCells(0);
      cVar3 = BurgsAndStateGenerator__EnsureProvinceConnectivity(param_1,0);
      if (cVar3 != '\0') {
        BurgsAndStateGenerator__FilterProvinceCells(0);
      }
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      local_1f8 = System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar6,0);
      uVar8 = System_Int64__ToString(&local_1f8,0);
      uVar8 = System_String__Concat(DAT_182e9b360,uVar8,0);
      if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      UnityEngine_Debug__Log(uVar8,0);
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d7a0,0);
      local_238 = 0;
      plStack_230 = local_248;
      BurgsAndStateGenerator__RecalculateProvinceState(param_1,0);
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      local_1f8 = System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar6,0);
      uVar8 = System_Int64__ToString(&local_1f8,0);
      uVar8 = System_String__Concat(DAT_182eee758,uVar8,0);
      if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      UnityEngine_Debug__Log(uVar8,0);
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d940,0);
      local_238 = 0;
      plStack_230 = local_248;
      BurgsAndStateGenerator__SpecifyBurgAndProvince(param_1,param_2,0);
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      local_1f8 = System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar6,0);
      uVar8 = System_Int64__ToString(&local_1f8,0);
      uVar8 = System_String__Concat(DAT_182e92378,uVar8,0);
      if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      UnityEngine_Debug__Log(uVar8,0);
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d1f0,0);
      local_238 = 0;
      plStack_230 = local_248;
      BurgsAndStateGenerator__InitCultureNameSet(param_1,param_2,0);
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      local_1f8 = System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar6,0);
      uVar8 = System_Int64__ToString(&local_1f8,0);
      uVar8 = System_String__Concat(DAT_182ed0e78,uVar8,0);
      if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      UnityEngine_Debug__Log(uVar8,0);
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d2c0,0);
      local_208 = 0;
      plStack_200 = local_248;
      local_1d0 = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d460,0);
      local_238 = 0;
      plStack_230 = &local_1d0;
      BurgsAndStateGenerator__InitEthnicAttribute(param_1,0);
      if (local_1d0 != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      local_1d0 = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d390,0);
      local_238 = 0;
      plStack_230 = &local_1d0;
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      lVar9 = *(longlong *)(param_1 + 0x10);
      uVar8 = Routes__GetSeaRoutes(local_1c8,0);
      if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      *(undefined8 *)(lVar9 + 0x2a8) = uVar8;
      FUN_180232f70(lVar9 + 0x2a8,uVar8);
      if (local_1d0 != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      System_Diagnostics_Stopwatch__Stop(lVar6,0);
      local_1f8 = System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(lVar6,0);
      uVar8 = System_Int64__ToString(&local_1f8,0);
      uVar8 = System_String__Concat(DAT_182ed0f50,uVar8,0);
      if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      UnityEngine_Debug__Log(uVar8,0);
      System_Diagnostics_Stopwatch__Restart(lVar6,0);
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d600,0);
      local_150 = 0;
      local_148 = local_248;
      if (*(longlong *)(param_1 + 0x20) == 0) {
        BurgsAndStateGenerator__RandomStateName(param_1,0);
      }
      if (DAT_183060243 == '\0') {
        FUN_1802334a0(&DAT_182ee7460);
        FUN_1802334a0(&DAT_182ee7d80);
        FUN_1802334a0(&DAT_182ee72b8);
        FUN_1802334a0(&DAT_182ee71e8);
        FUN_1802334a0(&DAT_182ee6c18);
        FUN_1802334a0(&DAT_182ee8278);
        FUN_1802334a0(&DAT_182ee8348);
        FUN_1802334a0(&DAT_182ee3460);
        FUN_1802334a0(&DAT_182e89808);
        FUN_1802334a0(&DAT_182efbf10);
        DAT_183060243 = '\x01';
      }
      lVar6 = thunk_FUN_1802a5470(DAT_182ee3460);
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      FUN_1813e2b90(lVar6,DAT_182ee71e8);
      if (*(int *)(DAT_182e89808 + 0xe0) == 0) {
        il2cpp_runtime_class_init(DAT_182e89808);
      }
      uVar8 = *(undefined8 *)(*(longlong *)(DAT_182e89808 + 0xb8) + 8);
      lVar9 = thunk_FUN_1802a5470(DAT_182ee3460);
      if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      FUN_1813e2970(lVar9,uVar8,DAT_182ee72b8);
      if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      lVar7 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
      if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      iVar4 = *(int *)(lVar7 + 0x18);
      local_218 = CONCAT44(local_218._4_4_,iVar4);
      while (iVar10 < iVar4) {
        if (*(int *)(lVar9 + 0x18) == 0) {
          FUN_180304090(lVar6,DAT_182efbf10);
          iVar10 = iVar10 + 1;
          iVar4 = (int)local_218;
        }
        else {
          uVar5 = UnityEngine_Random__Range(0,*(undefined4 *)(lVar9 + 0x18),0);
          uVar8 = FUN_1813e2d10(lVar9,uVar5,DAT_182ee8348);
          FUN_180304090(lVar6,uVar8,DAT_182ee7460);
          FUN_18140e940(lVar9,uVar5);
          iVar10 = iVar10 + 1;
          iVar4 = (int)local_218;
        }
      }
      if (*(longlong *)(param_1 + 0x20) == 0) {
        if (*(int *)(DAT_182eadff0 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        lVar6 = DefaultNamespace_ColorUtils__GetBaseColors(0);
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_1813e0e20(&local_1e8,lVar9,DAT_182ee67f8);
        local_168 = local_1e8;
        uStack_160 = uStack_1e0;
        local_158 = local_1d8;
        local_238 = 0;
        plStack_230 = &local_168;
        while (cVar3 = FUN_1811ab230(&local_168,DAT_182f01dc8), uVar2 = local_158, cVar3 != '\0') {
          lVar9 = thunk_FUN_1802a5470(DAT_182efe8c8);
          if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          MostEnemyArmyProvinceStrategy___ctor(lVar9,0);
          *(longlong *)(lVar9 + 0x18) = param_1;
          FUN_180232f70(lVar9 + 0x18,param_1);
          if (uVar2 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (((*(char *)(uVar2 + 0x204) == '\0') && (*(int *)(uVar2 + 0x24) != 0)) &&
             (fVar13 = *(float *)(uVar2 + 0x54) - 0.0, fVar14 = *(float *)(uVar2 + 0x58) - 0.0,
             fVar11 = *(float *)(uVar2 + 0x5c) - 0.0, fVar12 = *(float *)(uVar2 + 0x60) - 1.0,
             fVar14 * fVar14 + fVar13 * fVar13 + fVar11 * fVar11 + fVar12 * fVar12 < 9.9999994e-11))
          {
            *(undefined8 *)(lVar9 + 0x10) = *(undefined8 *)(uVar2 + 0xf8);
            FUN_180232f70(lVar9 + 0x10);
            local_1b8 = thunk_FUN_1802a5470(DAT_182e8ee38);
            if (local_1b8 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_181297fb0(local_1b8,lVar9,DAT_182ef98e0,0);
            FUN_180c051b0(&local_208,lVar6,local_1b8);
            *(undefined8 *)(uVar2 + 0x54) = local_208;
            *(longlong **)(uVar2 + 0x5c) = plStack_200;
            FUN_180c06490(&local_178,lVar6,DAT_182ee5a80);
            if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            local_1b8 = local_178;
            plStack_1b0 = plStack_170;
            FUN_180006940(lVar6,&local_1b8,DAT_182e9f200);
            FUN_1813e19b0(lVar6,0,DAT_182e9f6e0);
            *(undefined8 *)(uVar2 + 100) = *(undefined8 *)(uVar2 + 0x54);
            *(undefined8 *)(uVar2 + 0x6c) = *(undefined8 *)(uVar2 + 0x5c);
          }
        }
        AISystemState__Start(&local_168,DAT_182f01cf8);
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_1813e0e20(&local_1e8,lVar6,DAT_182ee67f8);
        local_168 = local_1e8;
        uStack_160 = uStack_1e0;
        local_158 = local_1d8;
        local_238 = 0;
        plStack_230 = &local_168;
        while (cVar3 = FUN_1811ab230(&local_168,DAT_182f01dc8), cVar3 != '\0') {
          if (local_158 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(int *)(local_158 + 0x24) != 0) {
            local_208 = *(undefined8 *)(local_158 + 0x54);
            plStack_200 = *(longlong **)(local_158 + 0x5c);
            State__UpdateColor(local_158,&local_208,0);
          }
        }
        AISystemState__Start(&local_168,DAT_182f01cf8);
        if (local_248[0] != 0) {
          FUN_180002f00(0,DAT_182ee2ed8,local_248[0]);
        }
      }
      else {
        lVar6 = *(longlong *)(param_1 + 0x20);
        if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        local_238 = *(longlong *)(lVar6 + 0x54);
        plStack_230 = *(longlong **)(lVar6 + 0x5c);
        State__UpdateColor(lVar6,&local_238,0);
        if (local_248[0] != 0) {
          FUN_180002f00(0,DAT_182ee2ed8,local_248[0]);
        }
      }
      local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d530,0);
      local_208 = 0;
      plStack_200 = local_248;
      if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288);
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      FUN_1813e0e20(&local_1e8,lVar6,DAT_182ed7ac0);
      local_1a8 = local_1e8;
      plStack_1a0 = (longlong *)uStack_1e0;
      local_198 = local_1d8;
      local_238 = 0;
      plStack_230 = &local_1a8;
      while (cVar3 = FUN_1811ab230(&local_1a8,DAT_182efd5c8), cVar3 != '\0') {
        if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        *(bool *)(local_198 + 0x1a0) = *(char *)(local_198 + 0x89) != '\0';
      }
      AISystemState__Start(&local_1a8,DAT_182efd4f0);
      lVar6 = MapReligionManager__get_Instance(0);
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      MapReligionManager__ForceUpdateReligionBorder(lVar6,0);
      lVar6 = MapCultureManager__get_Instance(0);
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      MapCultureManager__ForceUpdateCultureBorder(lVar6,0);
      if (*(int *)(DAT_182ebbdf8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      lVar6 = StateManager__get_Instance(0);
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      StateManager__ForceUpdateStateBorder(lVar6,0);
      if (local_248[0] != 0) {
        FUN_180002f00(0,DAT_182ee2ed8,local_248[0]);
      }
      System_Diagnostics_Stopwatch__Stop(local_1f0,0);
      local_1f8 = System_Diagnostics_Stopwatch__get_ElapsedMilliseconds(local_1f0,0);
      uVar8 = System_Int64__ToString(&local_1f8,0);
      uVar8 = System_String__Concat(DAT_182eeb180,uVar8,0);
      if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      UnityEngine_Debug__Log(uVar8,0);
      if (*(longlong *)(param_1 + 0x20) != 0) {
        lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x20) + 0x108);
        if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        if (*(int *)(lVar6 + 0x18) == 0) {
          local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d050,0);
          local_1b8 = 0;
          plStack_1b0 = local_248;
          if (DAT_183060246 == '\0') {
            FUN_1802334a0(&DAT_182ebb9c0);
            DAT_183060246 = '\x01';
          }
          lVar6 = thunk_FUN_1802a5470(DAT_182ebb9c0);
          if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          State___ctor(lVar6,0);
          *(undefined2 *)(lVar6 + 0xa8) = 0x101;
          *(undefined1 *)(lVar6 + 0xa0) = 1;
          *(undefined4 *)(lVar6 + 0x54) = 0x3f800000;
          *(undefined4 *)(lVar6 + 0x58) = 0x3f800000;
          *(undefined4 *)(lVar6 + 0x5c) = 0x3f800000;
          *(undefined4 *)(lVar6 + 0x60) = 0x3f800000;
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
          if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          local_1f0 = lVar6;
          FUN_180304090(lVar9,lVar6,DAT_182ee6228);
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
          if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          *(int *)(lVar6 + 0x24) = *(int *)(lVar9 + 0x18) + -1;
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
          if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar9 = *(longlong *)(lVar9 + 0xc0);
          if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          iVar10 = FUN_1813fe630(lVar9,*(undefined4 *)(*(longlong *)(param_1 + 0x10) + 0x3fc),
                                 DAT_182ebe118);
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288);
          if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          local_218 = CONCAT44(local_218._4_4_,iVar10);
          lVar9 = FUN_1813e2d10(lVar9,iVar10,DAT_182ed80a8);
          local_1c8 = lVar9;
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(param_1 + 0x20) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar7 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x270);
          if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar7 = FUN_1813e2d10(lVar7,*(undefined4 *)(*(longlong *)(param_1 + 0x20) + 0xe0),
                                DAT_182e99eb8);
          if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          *(undefined4 *)(lVar7 + 0x58) = 0;
          if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(param_1 + 0x20) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          *(undefined4 *)(*(longlong *)(param_1 + 0x20) + 0xe0) = *(undefined4 *)(lVar9 + 100);
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(param_1 + 0x20) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar7 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x270);
          if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar7 = FUN_1813e2d10(lVar7,*(undefined4 *)(*(longlong *)(param_1 + 0x20) + 0xe0),
                                DAT_182e99eb8);
          if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          *(undefined4 *)(lVar7 + 0x58) = 1;
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar7 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288);
          if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          FUN_1813e0e20(&local_1e8,lVar7,DAT_182ed7ac0);
          local_1a8 = local_1e8;
          plStack_1a0 = (longlong *)uStack_1e0;
          local_198 = local_1d8;
          local_208 = 0;
          plStack_200 = &local_1a8;
          while (cVar3 = FUN_1811ab230(&local_1a8,DAT_182efd5c8), cVar3 != '\0') {
            if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(param_1 + 0x20) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if ((((*(int *)(local_198 + 0x78) == *(int *)(*(longlong *)(param_1 + 0x20) + 0x24)) &&
                 (*(char *)(local_198 + 0x89) != '\0')) && (*(char *)(local_198 + 0x88) == '\0')) &&
               ((*(int *)(local_198 + 0x10) != 0 && (*(int *)(local_198 + 0x10) != iVar10)))) {
              *(undefined4 *)(local_198 + 0x78) = *(undefined4 *)(lVar6 + 0x24);
              if (*(longlong *)(local_198 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              FUN_1813f96b0(&local_1e8,*(longlong *)(local_198 + 0xa8),DAT_182ebd480);
              local_190 = local_1e8;
              uStack_188 = uStack_1e0;
              local_180 = local_1d8;
              local_238 = 0;
              plStack_230 = &local_190;
              while (cVar3 = FUN_1811a17e0(&local_190,DAT_182ef2178), cVar3 != '\0') {
                if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                lVar7 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
                if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                lVar7 = *(longlong *)(lVar7 + 0xa8);
                if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                FUN_181409950(lVar7,local_180 & 0xffffffff,*(undefined4 *)(lVar6 + 0x24));
              }
              AISystemState__Start(&local_190,DAT_182ef20a0);
            }
          }
          AISystemState__Start(plStack_200,DAT_182efd4f0);
          if (*(longlong *)(param_1 + 0x20) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          cVar3 = State__IsBlankConquerable(*(longlong *)(param_1 + 0x20),0);
          if (cVar3 == '\0') {
            if (local_248[0] != 0) {
              FUN_180002f00(0,DAT_182ee2ed8,local_248[0]);
            }
          }
          else {
            *(undefined4 *)(lVar9 + 0x78) = *(undefined4 *)(lVar6 + 0x24);
            if (*(longlong *)(lVar9 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_1813f96b0(&local_1e8,*(longlong *)(lVar9 + 0xa8),DAT_182ebd480);
            local_190 = local_1e8;
            uStack_188 = uStack_1e0;
            local_180 = local_1d8;
            local_238 = 0;
            plStack_230 = &local_190;
            while (cVar3 = FUN_1811a17e0(&local_190,DAT_182ef2178), cVar3 != '\0') {
              if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
              if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              lVar9 = *(longlong *)(lVar9 + 0xa8);
              if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              FUN_181409950(lVar9,local_180 & 0xffffffff,*(undefined4 *)(lVar6 + 0x24));
            }
            AISystemState__Start(&local_190,DAT_182ef20a0);
            if (local_248[0] != 0) {
              FUN_180002f00(0,DAT_182ee2ed8,local_248[0]);
            }
          }
        }
      }
      if (param_3 != '\0') {
        local_248[0] = SaveLoadPerfSession__MeasureCurrent(DAT_182e9d120,0);
        local_178 = 0;
        plStack_170 = local_248;
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_1813e0e20(&local_1e8,lVar6,DAT_182ee67f8);
        local_168 = local_1e8;
        uStack_160 = uStack_1e0;
        local_158 = local_1d8;
        local_238 = 0;
        plStack_230 = &local_168;
        while (cVar3 = FUN_1811ab230(&local_168,DAT_182f01dc8), cVar3 != '\0') {
          if (local_158 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(int *)(local_158 + 0x24) != 0) {
            *(undefined1 *)(local_158 + 0x204) = 1;
          }
        }
        AISystemState__Start(&local_168,DAT_182f01cf8);
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        local_1b8 = FUN_1813e2d10(lVar6,0,DAT_182ee6cf0);
        if (DAT_183060246 == '\0') {
          FUN_1802334a0(&DAT_182ebb9c0);
          DAT_183060246 = '\x01';
        }
        lVar6 = thunk_FUN_1802a5470(DAT_182ebb9c0);
        if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        State___ctor(lVar6,0);
        *(undefined2 *)(lVar6 + 0xa8) = 0x101;
        *(undefined1 *)(lVar6 + 0xa0) = 1;
        *(undefined4 *)(lVar6 + 0x54) = 0x3f800000;
        *(undefined4 *)(lVar6 + 0x58) = 0x3f800000;
        *(undefined4 *)(lVar6 + 0x5c) = 0x3f800000;
        *(undefined4 *)(lVar6 + 0x60) = 0x3f800000;
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        local_1f0 = lVar6;
        FUN_180304090(lVar9,lVar6,DAT_182ee6228);
        *(undefined4 *)(lVar6 + 0x24) = 1;
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_1813e0e20(&local_1e8,lVar9,DAT_182ed7ac0);
        local_1a8 = local_1e8;
        plStack_1a0 = (longlong *)uStack_1e0;
        local_198 = local_1d8;
        local_208 = 0;
        plStack_200 = &local_1a8;
        while (cVar3 = FUN_1811ab230(&local_1a8,DAT_182efd5c8), cVar3 != '\0') {
          if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(char *)(local_198 + 0x89) != '\0') {
            *(undefined4 *)(local_198 + 0x78) = *(undefined4 *)(lVar6 + 0x24);
            if (*(longlong *)(local_198 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_1813f96b0(&local_1e8,*(longlong *)(local_198 + 0xa8),DAT_182ebd480);
            local_190 = local_1e8;
            uStack_188 = uStack_1e0;
            local_180 = local_1d8;
            local_238 = 0;
            plStack_230 = &local_190;
            while (cVar3 = FUN_1811a17e0(&local_190,DAT_182ef2178), cVar3 != '\0') {
              if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
              if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              lVar9 = *(longlong *)(lVar9 + 0xa8);
              if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              FUN_181409950(lVar9,local_180 & 0xffffffff,*(undefined4 *)(lVar6 + 0x24));
            }
            AISystemState__Start(&local_190,DAT_182ef20a0);
          }
        }
        AISystemState__Start(plStack_200,DAT_182efd4f0);
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        *(int *)(lVar9 + 0x1c) = *(int *)(lVar9 + 0x1c) + 1;
        iVar10 = *(int *)(lVar9 + 0x18);
        *(undefined4 *)(lVar9 + 0x18) = 0;
        if (0 < iVar10) {
          System_Array__Clear(*(undefined8 *)(lVar9 + 0x10),0,iVar10,0);
        }
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_180304090(lVar9,local_1b8,DAT_182ee6228);
        if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290);
        if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        FUN_180304090(lVar9,lVar6,DAT_182ee6228);
        local_238 = 0x3f8000003f800000;
        plStack_230 = (longlong *)0x3f8000003f800000;
        State__UpdateColor(lVar6,&local_238,0);
        if (*plStack_170 != 0) {
          FUN_180002f00(0,DAT_182ee2ed8,*plStack_170);
        }
      }
      return;
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

