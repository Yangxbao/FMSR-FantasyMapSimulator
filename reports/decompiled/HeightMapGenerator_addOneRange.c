
void HeightMapGenerator_<>c__DisplayClass15_0__<addRange>g__addOneRange_0(longlong param_1)

{
  longlong lVar1;
  ulonglong uVar2;
  char cVar3;
  int iVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  undefined8 uVar7;
  longlong lVar8;
  longlong lVar9;
  uint uVar10;
  int iVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  double dVar16;
  int local_res18;
  longlong local_198;
  longlong local_190;
  undefined8 local_188;
  undefined8 uStack_180;
  ulonglong local_178;
  longlong local_170;
  undefined8 local_168;
  undefined8 *local_160;
  undefined8 local_158;
  undefined8 uStack_150;
  ulonglong local_148;
  undefined8 local_140;
  undefined8 *local_138;
  undefined8 local_130;
  undefined8 *local_128;
  undefined8 local_120;
  undefined8 uStack_118;
  ulonglong local_110;
  longlong local_108;
  longlong local_100;
  longlong local_f8;
  
  if (DAT_18305fbba == '\0') {
    FUN_1802334a0(&DAT_182ee6048);
    FUN_1802334a0(&DAT_182eef608);
    FUN_1802334a0(&DAT_182ef3668);
    FUN_1802334a0(&DAT_182e7f448);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182e95558);
    FUN_1802334a0(&DAT_182edc188);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182ebd1f8);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebcdc0);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182e98a68);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182e98b38);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182ecb308);
    DAT_18305fbba = '\x01';
  }
  local_188 = 0;
  uStack_180 = 0;
  local_178 = 0;
  local_120 = 0;
  uStack_118 = 0;
  local_110 = 0;
  iVar4 = RandomUtils__GetNumberInRange(*(undefined8 *)(param_1 + 0x10),0);
  dVar16 = (double)MathUtility__Lim((double)iVar4,0);
  if ((*(longlong *)(param_1 + 0x18) != 0) &&
     (lVar8 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x18), lVar8 != 0)) {
    uVar7 = FUN_180c097e0(0,*(undefined4 *)(lVar8 + 0x18),DAT_182ef3668);
    local_198 = FUN_180c22330(uVar7,DAT_182e7f448);
    FUN_180232f70(&local_198,local_198);
    if ((*(longlong *)(param_1 + 0x18) != 0) &&
       (*(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10) != 0)) {
      uVar7 = *(undefined8 *)(param_1 + 0x20);
      if (*(int *)(DAT_182edc188 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      fVar12 = (float)HeightMapGenerator__GetPointInRange(uVar7);
      if ((*(longlong *)(param_1 + 0x18) != 0) &&
         (*(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10) != 0)) {
        local_f8 = param_1;
        fVar13 = (float)HeightMapGenerator__GetPointInRange(*(undefined8 *)(param_1 + 0x28));
        iVar4 = 0;
        do {
          if ((*(longlong *)(param_1 + 0x18) == 0) ||
             (lVar8 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10), lVar8 == 0))
          goto LAB_1803a5571;
          fVar14 = (float)UnityEngine_Random__Range(lVar8,(float)*(int *)(lVar8 + 0x138) * 0.8,0);
          if ((*(longlong *)(param_1 + 0x18) == 0) ||
             (lVar8 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10), lVar8 == 0))
          goto LAB_1803a5571;
          iVar11 = *(int *)(lVar8 + 0x138);
          fVar15 = (float)UnityEngine_Random__Range(lVar8,(float)*(int *)(lVar8 + 0x13c) * 0.7,0);
          if ((*(longlong *)(param_1 + 0x18) == 0) ||
             (lVar8 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10), lVar8 == 0))
          goto LAB_1803a5571;
          fVar14 = ABS((fVar14 + (float)iVar11 * 0.1) - fVar12) +
                   ABS(((float)*(int *)(lVar8 + 0x13c) * 0.15 + fVar15) - fVar13);
          uVar10 = *(int *)(lVar8 + 0x138) >> 0x1f & 7;
          if ((float)((int)(*(int *)(lVar8 + 0x138) + uVar10) >> 3) <= fVar14) {
            iVar11 = *(int *)(*(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10) + 0x138);
            uVar10 = iVar11 / 3 + (iVar11 >> 0x1f) +
                     (int)(((longlong)iVar11 / 3 + ((longlong)iVar11 >> 0x3f) & 0xffffffffU) >> 0x1f
                          );
            if (fVar14 <= (float)(int)uVar10) break;
          }
          iVar4 = iVar4 + 1;
        } while (iVar4 < 0x32);
        uVar5 = World__GetCellIndex(*(undefined8 *)(*(longlong *)(param_1 + 0x18) + 0x10),uVar10,
                                    fVar13,0);
        if ((*(longlong *)(param_1 + 0x18) != 0) &&
           (*(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10) != 0)) {
          uVar6 = World__GetCellIndex();
          lVar8 = HeightMapGenerator_<>c__DisplayClass15_0__<addRange>g__GetRange_1
                            (param_1,uVar5,uVar6,&local_198,0);
          local_100 = lVar8;
          lVar9 = thunk_FUN_1802a5470(DAT_182edbc38);
          if (lVar9 != 0) {
            local_170 = lVar8;
            FUN_1813e2970(lVar9,lVar8,DAT_182ebcdc0);
            fVar12 = (float)dVar16;
            local_res18 = 0;
            local_190 = lVar9;
            while (0 < *(int *)(lVar9 + 0x18)) {
              lVar8 = thunk_FUN_1802a5470(DAT_182edbc38);
              local_108 = lVar8;
              if (lVar8 == 0) goto LAB_1803a5571;
              FUN_1813e2970(lVar8,lVar9,DAT_182ebcdc0);
              *(int *)(lVar9 + 0x1c) = *(int *)(lVar9 + 0x1c) + 1;
              *(undefined4 *)(lVar9 + 0x18) = 0;
              FUN_1813f96b0(&local_158,lVar8,DAT_182ebd480);
              local_188 = local_158;
              uStack_180 = uStack_150;
              local_178 = local_148;
              local_140 = 0;
              local_138 = &local_188;
              while (cVar3 = FUN_1811a17e0(&local_188,DAT_182ef2178), uVar2 = local_178,
                    cVar3 != '\0') {
                if (*(longlong *)(param_1 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x18);
                if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                iVar4 = FUN_1813fe630(lVar1,local_178 & 0xffffffff,DAT_182ebe118);
                fVar13 = (float)UnityEngine_Random__Range();
                dVar16 = (double)MathUtility__Lim((double)((fVar13 + 0.85) * fVar12 + (float)iVar4),
                                                  0);
                FUN_181409950(lVar1,uVar2 & 0xffffffff,(int)dVar16);
              }
              AISystemState__Start(&local_188,DAT_182ef20a0);
              if (*(longlong *)(param_1 + 0x18) == 0) goto LAB_1803a5571;
              local_res18 = local_res18 + 1;
              fVar12 = (float)FUN_1802d1a20();
              fVar12 = fVar12 - 1.0;
              if (fVar12 < 2.0) break;
              FUN_1813f96b0(&local_158,lVar8,DAT_182ebd480);
              local_188 = local_158;
              uStack_180 = uStack_150;
              local_178 = local_148;
              local_168 = 0;
              local_160 = &local_188;
              while (cVar3 = FUN_1811a17e0(&local_188,DAT_182ef2178), cVar3 != '\0') {
                if (*(longlong *)(param_1 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                lVar8 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x10);
                if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                lVar8 = World__GetNeighborCells(lVar8,local_178 & 0xffffffff,0);
                if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                FUN_1813f96b0(&local_158,lVar8);
                local_120 = local_158;
                uStack_118 = uStack_150;
                local_110 = local_148;
                local_130 = 0;
                local_128 = &local_120;
                while (cVar3 = FUN_1811a17e0(&local_120,DAT_182ef2178), uVar2 = local_110,
                      cVar3 != '\0') {
                  if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  cVar3 = FUN_1813fe680(local_198,local_110 & 0xffffffff);
                  if (cVar3 == '\0') {
                    FUN_1800048f0(lVar9,uVar2 & 0xffffffff,DAT_182ebcf70);
                    if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
                      FUN_180233680();
                    }
                    FUN_1813fe780(local_198,uVar2 & 0xffffffff);
                  }
                }
                AISystemState__Start(&local_120,DAT_182ef20a0);
              }
              AISystemState__Start(local_160,DAT_182ef20a0);
            }
            iVar4 = 0;
            if (local_170 != 0) {
              do {
                if (*(int *)(local_100 + 0x18) <= iVar4) {
                  return;
                }
                if (iVar4 == (iVar4 / 6 + (iVar4 >> 0x1f) +
                             (int)(((longlong)iVar4 / 6 + ((longlong)iVar4 >> 0x3f) & 0xffffffffU)
                                  >> 0x1f)) * 6) {
                  uVar5 = FUN_1813fe630(local_170,iVar4,DAT_182ebe118);
                  lVar8 = local_f8;
                  iVar11 = 0;
                  if (0 < local_res18) {
                    do {
                      if ((*(longlong *)(lVar8 + 0x18) == 0) ||
                         (lVar9 = *(longlong *)(*(longlong *)(lVar8 + 0x18) + 0x10), lVar9 == 0))
                      goto LAB_1803a5571;
                      uVar7 = World__GetNeighborCells(lVar9,uVar5,0);
                      lVar9 = *(longlong *)(param_1 + 0x30);
                      if (lVar9 == 0) {
                        lVar9 = thunk_FUN_1802a5470(DAT_182e95558);
                        if (lVar9 == 0) goto LAB_1803a5571;
                        FUN_18129a570(lVar9,param_1,DAT_182ecb308,0);
                        *(longlong *)(param_1 + 0x30) = lVar9;
                        FUN_180232f70(param_1 + 0x30,lVar9);
                      }
                      uVar7 = FUN_180c09290(uVar7,lVar9,DAT_182eef608);
                      uVar6 = FUN_180c06730(uVar7,DAT_182ee6048);
                      if ((*(longlong *)(param_1 + 0x18) == 0) ||
                         (lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x18), lVar9 == 0))
                      goto LAB_1803a5571;
                      FUN_1813fe630(lVar9,uVar5,DAT_182ebe118);
                      if ((*(longlong *)(param_1 + 0x18) == 0) ||
                         (lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x18), lVar1 == 0))
                      goto LAB_1803a5571;
                      FUN_1813fe630(lVar1,uVar6,DAT_182ebe118);
                      FUN_181409950(lVar9,uVar6);
                      iVar11 = iVar11 + 1;
                      uVar5 = uVar6;
                    } while (iVar11 < local_res18);
                  }
                }
                iVar4 = iVar4 + 1;
              } while( true );
            }
          }
        }
      }
    }
  }
LAB_1803a5571:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

