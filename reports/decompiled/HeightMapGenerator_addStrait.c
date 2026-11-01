
void HeightMapGenerator__addStrait(longlong param_1,undefined8 param_2,undefined8 param_3)

{
  ulonglong uVar1;
  char cVar2;
  int iVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  undefined8 uVar6;
  longlong lVar7;
  longlong lVar8;
  int iVar9;
  int iVar10;
  float fVar11;
  double dVar12;
  longlong local_e8;
  longlong local_e0;
  float local_d8;
  float local_d4;
  longlong local_d0;
  undefined8 local_c8;
  undefined8 *local_c0;
  undefined8 local_b8;
  undefined8 *local_b0;
  undefined8 local_a8;
  undefined8 uStack_a0;
  ulonglong local_98;
  undefined8 local_90;
  undefined8 uStack_88;
  ulonglong local_80;
  undefined8 local_78;
  undefined8 uStack_70;
  ulonglong local_68;
  
  if (DAT_18305fb9e == '\0') {
    FUN_1802334a0(&DAT_182ef3668);
    FUN_1802334a0(&DAT_182e7f448);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebd558);
    FUN_1802334a0(&DAT_182ebcce8);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182e98a68);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182e98b38);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182eb5040);
    DAT_18305fb9e = '\x01';
  }
  local_e0 = 0;
  local_a8 = 0;
  uStack_a0 = 0;
  local_98 = 0;
  local_90 = 0;
  uStack_88 = 0;
  local_80 = 0;
  local_e8 = param_1;
  FUN_180232f70(&local_e8,param_1);
  iVar3 = RandomUtils__GetNumberInRange(param_2,0);
  if (*(longlong *)(param_1 + 0x10) != 0) {
    iVar9 = (int)*(double *)(*(longlong *)(param_1 + 0x10) + 0x238);
    iVar10 = iVar9 / 3;
    if (iVar3 < iVar10) {
      iVar10 = iVar3;
    }
    if ((iVar10 < 1) && (cVar2 = RandomUtils__P(iVar9,0), cVar2 != '\0')) {
      return;
    }
    if (*(longlong *)(param_1 + 0x10) != 0) {
      uVar6 = FUN_180c097e0(0,*(undefined4 *)(*(longlong *)(param_1 + 0x10) + 0x250),DAT_182ef3668);
      local_e0 = FUN_180c22330(uVar6,DAT_182e7f448);
      FUN_180232f70(&local_e0,local_e0);
      cVar2 = System_String__Equals(param_3,DAT_182eb5040,0);
      if (cVar2 == '\0') {
        fVar11 = (float)UnityEngine_Random__Range
                                  ((float)*(int *)(param_1 + 0x2c) * 0.4,
                                   (float)*(int *)(param_1 + 0x2c) * 0.7,0);
        if (DAT_18305f9b5 == '\0') {
          FUN_1802334a0(&DAT_182e7eb28);
          DAT_18305f9b5 = '\x01';
        }
        if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        dVar12 = (double)FUN_1802d10b0((double)fVar11);
        iVar3 = *(int *)(param_1 + 0x2c);
        fVar11 = (float)UnityEngine_Random__Range();
        if (DAT_18305f9b5 == '\0') {
          FUN_1802334a0(&DAT_182e7eb28);
          DAT_18305f9b5 = '\x01';
        }
        if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        FUN_1802d10b0((double)(((float)(iVar3 - (int)dVar12) - (float)iVar3 * 0.1) + fVar11));
      }
      else {
        fVar11 = (float)UnityEngine_Random__Range
                                  ((float)*(int *)(param_1 + 0x28) * 0.4,
                                   (float)*(int *)(param_1 + 0x28) * 0.7,0);
        if (DAT_18305f9b5 == '\0') {
          FUN_1802334a0(&DAT_182e7eb28);
          DAT_18305f9b5 = '\x01';
        }
        if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        dVar12 = (double)FUN_1802d10b0((double)fVar11);
        iVar3 = *(int *)(param_1 + 0x28);
        fVar11 = (float)UnityEngine_Random__Range();
        if (DAT_18305f9b5 == '\0') {
          FUN_1802334a0(&DAT_182e7eb28);
          DAT_18305f9b5 = '\x01';
        }
        if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        FUN_1802d10b0((double)(((float)(iVar3 - (int)dVar12) - (float)iVar3 * 0.1) + fVar11));
      }
      if ((*(longlong *)(param_1 + 0x10) != 0) &&
         (uVar4 = World__GetCellIndex(), *(longlong *)(param_1 + 0x10) != 0)) {
        uVar5 = World__GetCellIndex();
        lVar7 = HeightMapGenerator__<addStrait>g__GetRange_17_0(param_1,uVar4,uVar5,&local_e8,0);
        if (*(longlong *)(param_1 + 0x18) != 0) {
          uVar6 = FUN_180c097e0(0,*(undefined4 *)(*(longlong *)(param_1 + 0x18) + 0x18),
                                DAT_182ef3668);
          local_e0 = FUN_180c22330(uVar6,DAT_182e7f448);
          FUN_180232f70(&local_e0,local_e0);
          lVar8 = thunk_FUN_1802a5470(DAT_182edbc38);
          if (lVar8 != 0) {
            local_d8 = 0.1 / (float)iVar10;
            FUN_1813e2b90(lVar8,DAT_182ebcce8);
            local_d0 = lVar8;
            while( true ) {
              if (iVar10 < 1) {
                return;
              }
              if (lVar7 == 0) break;
              local_d4 = 0.9 - (float)iVar10 * local_d8;
              FUN_1813f96b0(&local_78,lVar7,DAT_182ebd480);
              local_a8 = local_78;
              uStack_a0 = uStack_70;
              local_98 = local_68;
              local_c8 = 0;
              local_c0 = &local_a8;
              while (cVar2 = FUN_1811a17e0(&local_a8,DAT_182ef2178), cVar2 != '\0') {
                if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                lVar7 = World__GetNeighborCells
                                  (*(longlong *)(param_1 + 0x10),local_98 & 0xffffffff,0);
                if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                FUN_1813f96b0(&local_78,lVar7);
                local_90 = local_78;
                uStack_88 = uStack_70;
                local_80 = local_68;
                local_b8 = 0;
                local_b0 = &local_90;
                while (cVar2 = FUN_1811a17e0(&local_90,DAT_182ef2178), uVar1 = local_80,
                      cVar2 != '\0') {
                  if (local_e0 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  cVar2 = FUN_1813fe680(local_e0,local_80 & 0xffffffff);
                  if (cVar2 == '\0') {
                    if (local_e0 == 0) {
                    /* WARNING: Subroutine does not return */
                      FUN_180233680();
                    }
                    FUN_1813fe780(local_e0,uVar1 & 0xffffffff,1,DAT_182e98b38);
                    FUN_1800048f0(lVar8,uVar1 & 0xffffffff,DAT_182ebcf70);
                    lVar7 = *(longlong *)(param_1 + 0x18);
                    if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
                      FUN_180233680();
                    }
                    FUN_1813fe630(lVar7,uVar1 & 0xffffffff,DAT_182ebe118);
                    fVar11 = (float)FUN_1802d1a20();
                    FUN_181409950(lVar7,uVar1 & 0xffffffff,(int)fVar11,DAT_182ebe2c8);
                  }
                }
                AISystemState__Start(&local_90,DAT_182ef20a0);
              }
              AISystemState__Start(local_c0,DAT_182ef20a0);
              lVar7 = FUN_1813e0e60(lVar8,0,*(undefined4 *)(lVar8 + 0x18),DAT_182ebd558);
              iVar10 = iVar10 + -1;
            }
          }
        }
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

