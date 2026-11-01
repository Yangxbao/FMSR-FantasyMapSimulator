
void BurgsAndStateGenerator__ExpandStates(longlong param_1)

{
  float fVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  ulonglong uVar4;
  char cVar5;
  undefined4 uVar6;
  int iVar7;
  int iVar8;
  undefined8 uVar9;
  longlong lVar10;
  longlong lVar11;
  longlong lVar12;
  longlong lVar13;
  int iVar14;
  int iVar15;
  longlong lVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  longlong local_1c8;
  longlong local_1c0;
  longlong local_1b8;
  undefined8 local_1b0;
  undefined8 uStack_1a8;
  longlong local_1a0;
  longlong local_198;
  undefined8 local_190;
  undefined4 *local_188;
  longlong local_180;
  undefined4 *local_178;
  undefined4 local_170;
  undefined4 uStack_16c;
  undefined4 uStack_168;
  undefined4 uStack_164;
  longlong local_160;
  longlong local_158;
  longlong local_150;
  undefined8 local_148;
  undefined8 uStack_140;
  ulonglong local_138;
  undefined8 local_130;
  undefined8 uStack_128;
  ulonglong local_120;
  undefined4 local_118;
  undefined4 uStack_114;
  undefined4 uStack_110;
  undefined4 uStack_10c;
  ulonglong local_108;
  
  if (DAT_183060239 == '\0') {
    FUN_1802334a0(&DAT_182ef3c30);
    FUN_1802334a0(&DAT_182e82388);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ee39f8);
    FUN_1802334a0(&DAT_182f01cf8);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182f01dc8);
    FUN_1802334a0(&DAT_182ee3ac8);
    FUN_1802334a0(&DAT_182f01ea0);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182ee3ba0);
    FUN_1802334a0(&DAT_182e99d18);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ee67f8);
    FUN_1802334a0(&DAT_182e99de8);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182e99eb8);
    FUN_1802334a0(&DAT_182eacab0);
    FUN_1802334a0(&DAT_182ee6cf0);
    FUN_1802334a0(&DAT_182ea15c0);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ee41f0);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182ee4398);
    FUN_1802334a0(&DAT_182ec6e50);
    FUN_1802334a0(&DAT_182ec6f28);
    FUN_1802334a0(&DAT_182ec6d78);
    FUN_1802334a0(&DAT_182ec7000);
    FUN_1802334a0(&DAT_182ef9498);
    FUN_1802334a0(&DAT_182e9e058);
    DAT_183060239 = '\x01';
  }
  local_148 = 0;
  uStack_140 = 0;
  local_138 = 0;
  local_130 = 0;
  uStack_128 = 0;
  local_120 = 0;
  if (*(longlong *)(param_1 + 0x10) != 0) {
    local_1c8 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
    FUN_180232f70(&local_1c8);
    if ((*(longlong *)(param_1 + 0x10) != 0) &&
       (lVar13 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290), local_1b8 = lVar13,
       lVar13 != 0)) {
      iVar7 = 0;
      FUN_1813e0e20(&local_1b0,lVar13,DAT_182ee67f8);
      local_170 = (undefined4)local_1b0;
      uStack_16c = local_1b0._4_4_;
      uStack_168 = (undefined4)uStack_1a8;
      uStack_164 = uStack_1a8._4_4_;
      local_160 = local_1a0;
      local_180 = 0;
      local_178 = &local_170;
      iVar15 = iVar7;
      iVar14 = iVar7;
      while (cVar5 = FUN_1811ab230(&local_170,DAT_182f01dc8), cVar5 != '\0') {
        if (((local_160 != 0) && (*(int *)(local_160 + 0x24) != 0)) &&
           (*(char *)(local_160 + 0xa0) == '\0')) {
          iVar15 = iVar15 + 1;
          iVar14 = *(int *)(local_160 + 0x24);
        }
      }
      AISystemState__Start(&local_170,DAT_182f01cf8);
      if (iVar15 == 0) {
        return;
      }
      if (iVar15 == 1) {
        if ((local_1c8 != 0) && (lVar13 = *(longlong *)(local_1c8 + 0x18), lVar13 != 0)) {
          do {
            if (*(int *)(lVar13 + 0x18) <= iVar7) {
              return;
            }
            iVar15 = FUN_1813fe630(lVar13,iVar7,DAT_182ebe118);
            if (0x13 < iVar15) {
              if ((local_1c8 == 0) || (*(longlong *)(local_1c8 + 0xa8) == 0)) break;
              iVar15 = FUN_1813fe630(*(longlong *)(local_1c8 + 0xa8),iVar7,DAT_182ebe118);
              if (iVar15 == 0) {
                if ((local_1c8 == 0) || (*(longlong *)(local_1c8 + 0xa8) == 0)) break;
                FUN_181409950(*(longlong *)(local_1c8 + 0xa8),iVar7,iVar14,DAT_182ebe2c8);
              }
            }
            iVar7 = iVar7 + 1;
          } while( true );
        }
      }
      else {
        lVar16 = *(longlong *)(param_1 + 0x10);
        if ((lVar16 != 0) && (local_1c8 != 0)) {
          lVar12 = *(longlong *)(lVar16 + 0x270);
          lVar16 = *(longlong *)(lVar16 + 0x280);
          local_198 = lVar12;
          uVar9 = FUN_180c09a30(0,*(undefined4 *)(local_1c8 + 0x10),DAT_182ef3c30);
          lVar10 = FUN_180c22f90(uVar9,DAT_182e82388);
          lVar11 = thunk_FUN_1802a5470(DAT_182ef9498);
          local_1c0 = lVar11;
          if ((lVar11 != 0) &&
             (FUN_1814ec040(lVar11,DAT_182ec6d78), *(longlong *)(param_1 + 0x10) != 0)) {
            local_180 = lVar11;
            local_158 = lVar12;
            local_150 = lVar10;
            FUN_1813e0e20(&local_1b0,lVar13,DAT_182ee67f8);
            local_170 = (undefined4)local_1b0;
            uStack_16c = local_1b0._4_4_;
            uStack_168 = (undefined4)uStack_1a8;
            uStack_164 = uStack_1a8._4_4_;
            local_160 = local_1a0;
            local_190 = 0;
            local_188 = &local_170;
            while (cVar5 = FUN_1811ab230(&local_170,DAT_182f01dc8), lVar13 = local_160,
                  cVar5 != '\0') {
              if (((local_160 != 0) && (*(int *)(local_160 + 0x24) != 0)) &&
                 (*(char *)(local_160 + 0xa0) == '\0')) {
                if (lVar12 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                iVar14 = *(int *)(local_160 + 0xe0);
                if ((iVar14 < *(int *)(lVar12 + 0x18)) && (-1 < iVar14)) {
                  lVar12 = FUN_1813e2d10(lVar12,iVar14,DAT_182e99eb8);
                  if (lVar12 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  if (*(longlong *)(local_1c8 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  FUN_181409950(*(longlong *)(local_1c8 + 0xa8),*(undefined4 *)(lVar12 + 0x38),
                                *(undefined4 *)(lVar13 + 0x24),DAT_182ebe2c8);
                  if (lVar16 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  lVar12 = FUN_1813e2d10(lVar16,*(undefined4 *)(lVar13 + 0xc0),DAT_182ea15c0);
                  if (lVar12 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  if (*(longlong *)(local_1c8 + 0x40) == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  uVar6 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x40),
                                        *(undefined4 *)(lVar12 + 0x70),DAT_182ebe118);
                  lVar12 = thunk_FUN_1802a5470(DAT_182e9e058);
                  if (lVar12 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  AISystemState__Start(lVar12,0);
                  *(undefined4 *)(lVar12 + 0x14) = *(undefined4 *)(lVar13 + 0xa4);
                  *(undefined4 *)(lVar12 + 0x10) = 0;
                  *(undefined4 *)(lVar12 + 0x1c) = uVar6;
                  *(undefined4 *)(lVar12 + 0x18) = *(undefined4 *)(lVar13 + 0x24);
                  FUN_1814e95d0(local_1c0,lVar12,0,DAT_182ec6f28);
                  if (lVar10 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  FUN_181428fa0(lVar10,*(undefined4 *)(lVar13 + 0xa4),0x3f800000);
                  lVar12 = local_198;
                }
              }
            }
            AISystemState__Start(&local_170,DAT_182f01cf8);
            lVar13 = local_1c0;
            lVar16 = local_1b8;
            while (0 < *(int *)(lVar13 + 0x28)) {
              lVar12 = FUN_1814e6c30(lVar13,DAT_182ec6e50);
              if (lVar12 == 0) goto LAB_180489fcf;
              uVar6 = *(undefined4 *)(lVar12 + 0x14);
              fVar1 = *(float *)(lVar12 + 0x10);
              uVar2 = *(undefined4 *)(lVar12 + 0x18);
              uVar3 = *(undefined4 *)(lVar12 + 0x1c);
              lVar12 = FUN_1813e2d10(lVar16,uVar2,DAT_182ee6cf0);
              if (lVar12 == 0) goto LAB_180489fcf;
              local_190 = *(undefined8 *)(lVar12 + 0xd0);
              lVar12 = FUN_1813e2d10(lVar16,uVar2,DAT_182ee6cf0);
              if ((lVar12 == 0) || (*(longlong *)(param_1 + 0x10) == 0)) goto LAB_180489fcf;
              iVar14 = *(int *)(lVar12 + 0xc0);
              lVar12 = World__GetNeighborCells(*(longlong *)(param_1 + 0x10),uVar6,0);
              if (lVar12 == 0) goto LAB_180489fcf;
              FUN_1813f96b0(&local_118,lVar12,DAT_182ebd480);
              local_148 = CONCAT44(uStack_114,local_118);
              uStack_140 = CONCAT44(uStack_10c,uStack_110);
              local_138 = local_108;
              local_1b0 = 0;
              uStack_1a8 = &local_148;
LAB_1804897f5:
              cVar5 = FUN_1811a17e0(&local_148,DAT_182ef2178);
              uVar4 = local_138;
              if (cVar5 != '\0') {
                if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                if (*(longlong *)(local_1c8 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                iVar15 = (int)local_138;
                uVar6 = FUN_1813fe630(*(longlong *)(local_1c8 + 0xa8),local_138 & 0xffffffff,
                                      DAT_182ebe118);
                lVar12 = FUN_1813e2d10(lVar16,uVar6,DAT_182ee6cf0);
                if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                if (*(longlong *)(local_1c8 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                iVar7 = FUN_1813fe630(*(longlong *)(local_1c8 + 0xa8),uVar4 & 0xffffffff,
                                      DAT_182ebe118);
                lVar13 = local_1c0;
                if (0 < iVar7) goto code_r0x000180489888;
                goto LAB_18048989d;
              }
              AISystemState__Start(&local_148,DAT_182ef20a0);
              lVar12 = local_198;
            }
            if (lVar12 != 0) {
              FUN_1813e0e20(&local_118,lVar12,DAT_182e99d18);
              local_120 = local_108;
              local_1b0 = 0;
              uStack_1a8 = &local_130;
              while( true ) {
                do {
                  cVar5 = FUN_1811ab230(&local_130,DAT_182ee3ac8);
                  uVar4 = local_120;
                  if (cVar5 == '\0') {
                    AISystemState__Start(&local_130,DAT_182ee39f8);
                    return;
                  }
                  if (local_120 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                } while (*(int *)(local_120 + 0x10) == 0);
                if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                if (*(longlong *)(local_1c8 + 0xa8) == 0) break;
                uVar6 = FUN_1813fe630(*(longlong *)(local_1c8 + 0xa8),
                                      *(undefined4 *)(local_120 + 0x38),DAT_182ebe118);
                *(undefined4 *)(uVar4 + 0x40) = uVar6;
              }
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
          }
        }
      }
    }
  }
LAB_180489fcf:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
code_r0x000180489888:
  if (lVar12 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  if (iVar15 != *(int *)(lVar12 + 0xa4)) {
LAB_18048989d:
    if (lVar12 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    if ((*(char *)(lVar12 + 0xa0) == '\0') || (*(int *)(lVar12 + 0x24) < 1)) {
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_1c8 + 0x88) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      iVar8 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x88),uVar4 & 0xffffffff,DAT_182ebe118);
      iVar7 = -9;
      if (iVar14 != iVar8) {
        iVar7 = 100;
      }
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_1c8 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      iVar8 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x18),uVar4 & 0xffffffff,DAT_182ebe118);
      if (iVar8 < 0x14) {
        fVar21 = 0.0;
      }
      else {
        if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        if (*(longlong *)(local_1c8 + 0x50) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        fVar21 = (float)FUN_181428f50(*(longlong *)(local_1c8 + 0x50),uVar4 & 0xffffffff,
                                      DAT_182ee41f0);
        if (fVar21 <= 0.0) {
          fVar21 = 5000.0;
        }
        else {
          if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(local_1c8 + 0x50) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          fVar21 = (float)FUN_181428f50(*(longlong *)(local_1c8 + 0x50),uVar4 & 0xffffffff,
                                        DAT_182ee41f0);
          fVar21 = 20.0 - fVar21;
          if (fVar21 <= 0.0) {
            fVar21 = 0.0;
          }
        }
      }
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_1c8 + 0x40) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar6 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x40),uVar4 & 0xffffffff,DAT_182ebe118);
      fVar17 = (float)BurgsAndStateGenerator__<ExpandStates>g__getBiomeCost_25_0
                                (uVar3,uVar6,local_190,0);
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_1c8 + 0x78) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      lVar13 = *(longlong *)(local_1c8 + 0x118);
      uVar6 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x78),uVar4 & 0xffffffff,DAT_182ebe118);
      if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar9 = FUN_1813e2d10(lVar13,uVar6,DAT_182eacab0);
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_1c8 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      FUN_1813fe630(*(longlong *)(local_1c8 + 0x18),uVar4 & 0xffffffff,DAT_182ebe118);
      fVar18 = (float)BurgsAndStateGenerator__<ExpandStates>g__getHeightCost_25_1(uVar9);
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_1c8 + 0x30) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar6 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x30),uVar4 & 0xffffffff,DAT_182ebe118);
      uVar9 = local_190;
      fVar19 = (float)BurgsAndStateGenerator__<ExpandStates>g__getRiverCost_25_2
                                (uVar6,uVar4 & 0xffffffff,local_190,&local_1c8,0);
      if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_1c8 + 0x80) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar6 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x80),uVar4 & 0xffffffff,DAT_182ebe118);
      fVar20 = (float)BurgsAndStateGenerator__<ExpandStates>g__getTypeCost_25_3(uVar6,uVar9,0);
      lVar16 = local_1b8;
      fVar20 = (float)iVar7 + fVar21 + fVar17 + fVar18 + fVar19 + fVar20;
      if (fVar20 <= 0.0) {
        fVar20 = 0.0;
      }
      lVar13 = FUN_1813e2d10(local_1b8,uVar2,DAT_182ee6cf0);
      if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (lVar10 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      fVar17 = fVar1 + 10.0 + fVar20 / *(float *)(lVar13 + 0xdc);
      fVar21 = (float)FUN_181428f50(lVar10,uVar4 & 0xffffffff,DAT_182ee41f0);
      if ((fVar21 == 0.0) ||
         (fVar21 = (float)FUN_181428f50(lVar10,uVar4 & 0xffffffff,DAT_182ee41f0), lVar13 = local_1c0
         , fVar17 < fVar21)) {
        if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        if (*(longlong *)(local_1c8 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        iVar7 = FUN_1813fe630(*(longlong *)(local_1c8 + 0x18),uVar4 & 0xffffffff,DAT_182ebe118);
        if (0x13 < iVar7) {
          if (local_1c8 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(local_1c8 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          FUN_181409950(*(longlong *)(local_1c8 + 0xa8),uVar4 & 0xffffffff,uVar2,DAT_182ebe2c8);
        }
        FUN_181428fa0(lVar10,uVar4 & 0xffffffff,fVar17,DAT_182ee4398);
        lVar12 = thunk_FUN_1802a5470(DAT_182e9e058);
        if (lVar12 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        AISystemState__Start(lVar12,0);
        lVar13 = local_1c0;
        *(int *)(lVar12 + 0x14) = iVar15;
        *(float *)(lVar12 + 0x10) = fVar17;
        *(undefined4 *)(lVar12 + 0x1c) = uVar3;
        *(undefined4 *)(lVar12 + 0x18) = uVar2;
        FUN_1814e95d0(local_1c0,lVar12,fVar17);
      }
    }
  }
  goto LAB_1804897f5;
}

