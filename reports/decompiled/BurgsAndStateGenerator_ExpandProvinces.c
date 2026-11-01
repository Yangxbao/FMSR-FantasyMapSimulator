
void BurgsAndStateGenerator__ExpandProvinces(longlong param_1)

{
  float fVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  int iVar4;
  longlong lVar5;
  int iVar6;
  ulonglong uVar7;
  char cVar8;
  undefined4 uVar9;
  int iVar10;
  int iVar11;
  undefined8 uVar12;
  longlong lVar13;
  longlong lVar14;
  longlong lVar15;
  longlong lVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  longlong local_198;
  longlong local_190;
  undefined8 local_188;
  undefined8 uStack_180;
  longlong local_178;
  longlong local_170;
  longlong local_168;
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
  undefined8 local_100;
  undefined4 uStack_f8;
  undefined4 uStack_f4;
  longlong local_f0;
  
  if (DAT_18306023b == '\0') {
    FUN_1802334a0(&DAT_182ea1000);
    FUN_1802334a0(&DAT_182ef3c30);
    FUN_1802334a0(&DAT_182e82388);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ee39f8);
    FUN_1802334a0(&DAT_182efd4f0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ee3ac8);
    FUN_1802334a0(&DAT_182efd5c8);
    FUN_1802334a0(&DAT_182efd698);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182ee3ba0);
    FUN_1802334a0(&DAT_182ed7ac0);
    FUN_1802334a0(&DAT_182e99d18);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182e99eb8);
    FUN_1802334a0(&DAT_182ea15c0);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ed80a8);
    FUN_1802334a0(&DAT_182ee41f0);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182ee4398);
    FUN_1802334a0(&DAT_182ec6e50);
    FUN_1802334a0(&DAT_182ec6f28);
    FUN_1802334a0(&DAT_182ec6d78);
    FUN_1802334a0(&DAT_182ec7000);
    FUN_1802334a0(&DAT_182ef9498);
    FUN_1802334a0(&DAT_182e9e058);
    FUN_1802334a0(&DAT_182ec1e48);
    FUN_1802334a0(&DAT_182ec2e00);
    FUN_1802334a0(&DAT_182e8c050);
    DAT_18306023b = '\x01';
  }
  local_148 = 0;
  uStack_140 = 0;
  local_138 = 0;
  local_130 = 0;
  uStack_128 = 0;
  local_120 = 0;
  if (*(longlong *)(param_1 + 0x10) != 0) {
    local_198 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
    FUN_180232f70(&local_198);
    lVar16 = *(longlong *)(param_1 + 0x10);
    if ((lVar16 != 0) && (local_198 != 0)) {
      lVar5 = *(longlong *)(lVar16 + 0x288);
      lVar15 = *(longlong *)(lVar16 + 0x270);
      lVar16 = *(longlong *)(lVar16 + 0x280);
      local_170 = lVar15;
      uVar12 = FUN_180c09a30(0,*(undefined4 *)(local_198 + 0x10),DAT_182ef3c30);
      lVar13 = FUN_180c22f90(uVar12,DAT_182e82388);
      lVar14 = thunk_FUN_1802a5470(DAT_182ef9498);
      local_190 = lVar14;
      if ((lVar14 != 0) &&
         ((FUN_1814ec040(lVar14,DAT_182ec6d78), *(longlong *)(param_1 + 0x10) != 0 &&
          (local_168 = lVar5, lVar5 != 0)))) {
        local_160 = lVar15;
        local_158 = lVar13;
        local_150 = lVar14;
        FUN_1813e0e20(&local_188,lVar5,DAT_182ed7ac0);
        local_100._0_4_ = (undefined4)local_188;
        local_100._4_4_ = local_188._4_4_;
        uStack_f8 = (undefined4)uStack_180;
        uStack_f4 = uStack_180._4_4_;
        local_f0 = local_178;
        local_188 = 0;
        uStack_180 = &local_100;
        while (cVar8 = FUN_1811ab230(&local_100,DAT_182efd5c8), lVar14 = local_f0, cVar8 != '\0') {
          if (local_f0 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if ((((*(int *)(local_f0 + 0x10) != 0) && (*(char *)(local_f0 + 0x89) != '\0')) &&
              (*(char *)(local_f0 + 0x88) == '\0')) && (*(char *)(local_f0 + 0x95) != '\0')) {
            if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar15 = FUN_1813e2d10(lVar15,*(undefined4 *)(local_f0 + 100),DAT_182e99eb8);
            if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(local_198 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_181409950(*(longlong *)(local_198 + 0xc0),*(undefined4 *)(lVar15 + 0x38),
                          *(undefined4 *)(lVar14 + 0x10),DAT_182ebe2c8);
            if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar15 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
            if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar15 = *(longlong *)(lVar15 + 0x88);
            if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            uVar9 = FUN_1813fe630(lVar15,*(undefined4 *)(lVar14 + 0x48),DAT_182ebe118);
            if (lVar16 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar15 = FUN_1813e2d10(lVar16,uVar9,DAT_182ea15c0);
            if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(local_198 + 0x40) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            uVar9 = FUN_1813fe630(*(longlong *)(local_198 + 0x40),*(undefined4 *)(lVar14 + 0x48),
                                  DAT_182ebe118);
            lVar15 = thunk_FUN_1802a5470(DAT_182e9e058);
            if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            AISystemState__Start(lVar15,0);
            *(undefined4 *)(lVar15 + 0x14) = *(undefined4 *)(lVar14 + 0x48);
            *(undefined4 *)(lVar15 + 0x10) = 0;
            *(undefined4 *)(lVar15 + 0x1c) = uVar9;
            *(undefined4 *)(lVar15 + 0x18) = *(undefined4 *)(lVar14 + 0x10);
            FUN_1814e95d0(local_190,lVar15,0,DAT_182ec6f28);
            if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_181428fa0(lVar13,*(undefined4 *)(lVar14 + 0x48),0x3f800000);
            lVar15 = local_170;
          }
        }
        AISystemState__Start(&local_100,DAT_182efd4f0);
        lVar16 = local_190;
        if (*(int *)(DAT_182ea1000 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        Biomes__GetBiomeNameIndex(DAT_182e8c050,0);
        Biomes__GetBiomeNameIndex(DAT_182ec1e48,0);
        Biomes__GetBiomeNameIndex(DAT_182ec2e00,0);
        while (0 < *(int *)(lVar16 + 0x28)) {
          lVar15 = FUN_1814e6c30(lVar16,DAT_182ec6e50);
          if (lVar15 == 0) goto LAB_1804879b4;
          uVar9 = *(undefined4 *)(lVar15 + 0x14);
          fVar1 = *(float *)(lVar15 + 0x10);
          uVar2 = *(undefined4 *)(lVar15 + 0x18);
          uVar3 = *(undefined4 *)(lVar15 + 0x1c);
          lVar15 = FUN_1813e2d10(lVar5,uVar2,DAT_182ed80a8);
          if (lVar15 == 0) goto LAB_1804879b4;
          uVar12 = *(undefined8 *)(lVar15 + 0x68);
          lVar15 = FUN_1813e2d10(lVar5,uVar2,DAT_182ed80a8);
          if ((lVar15 == 0) || (*(longlong *)(param_1 + 0x10) == 0)) goto LAB_1804879b4;
          iVar4 = *(int *)(lVar15 + 0x70);
          lVar15 = World__GetNeighborCells(*(longlong *)(param_1 + 0x10),uVar9,0);
          if (lVar15 == 0) goto LAB_1804879b4;
          FUN_1813f96b0(&local_118,lVar15,DAT_182ebd480);
          local_148 = CONCAT44(uStack_114,local_118);
          uStack_140 = CONCAT44(uStack_10c,uStack_110);
          local_138 = local_108;
          local_188 = 0;
          uStack_180 = &local_148;
LAB_180487325:
          cVar8 = FUN_1811a17e0(&local_148,DAT_182ef2178);
          uVar7 = local_138;
          if (cVar8 != '\0') {
            if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(local_198 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            iVar6 = (int)local_138;
            uVar9 = FUN_1813fe630(*(longlong *)(local_198 + 0xc0),local_138 & 0xffffffff,
                                  DAT_182ebe118);
            lVar15 = FUN_1813e2d10(lVar5,uVar9,DAT_182ed80a8);
            if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(local_198 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            iVar10 = FUN_1813fe630(*(longlong *)(local_198 + 0xc0),uVar7 & 0xffffffff,DAT_182ebe118)
            ;
            lVar16 = local_190;
            if (0 < iVar10) goto code_r0x0001804873b8;
            goto LAB_1804873ca;
          }
          AISystemState__Start(&local_148,DAT_182ef20a0);
          lVar15 = local_170;
        }
        if (lVar15 != 0) {
          FUN_1813e0e20(&local_118,lVar15,DAT_182e99d18);
          local_120 = local_108;
          local_188 = 0;
          uStack_180 = &local_130;
          while( true ) {
            do {
              cVar8 = FUN_1811ab230(&local_130,DAT_182ee3ac8);
              uVar7 = local_120;
              if (cVar8 == '\0') {
                AISystemState__Start(&local_130,DAT_182ee39f8);
                return;
              }
              if (local_120 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
            } while (*(int *)(local_120 + 0x10) == 0);
            if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(local_198 + 0xc0) == 0) break;
            uVar9 = FUN_1813fe630(*(longlong *)(local_198 + 0xc0),*(undefined4 *)(local_120 + 0x38),
                                  DAT_182ebe118);
            *(undefined4 *)(uVar7 + 0x60) = uVar9;
          }
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
      }
    }
  }
LAB_1804879b4:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
code_r0x0001804873b8:
  if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  if (iVar6 != *(int *)(lVar15 + 0x48)) {
LAB_1804873ca:
    if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    if ((*(char *)(lVar15 + 0x88) == '\0') || (*(int *)(lVar15 + 0x10) < 1)) {
      if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_198 + 0x40) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      FUN_1813fe630(*(longlong *)(local_198 + 0x40),uVar7 & 0xffffffff,DAT_182ebe118);
      if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_198 + 0x88) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      iVar11 = FUN_1813fe630(*(longlong *)(local_198 + 0x88),uVar7 & 0xffffffff,DAT_182ebe118);
      iVar10 = -9;
      if (iVar4 != iVar11) {
        iVar10 = 100;
      }
      if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_198 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      iVar11 = FUN_1813fe630(*(longlong *)(local_198 + 0x18),uVar7 & 0xffffffff,DAT_182ebe118);
      if (iVar11 < 0x14) {
        fVar20 = 0.0;
      }
      else {
        if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        if (*(longlong *)(local_198 + 0x50) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        fVar20 = (float)FUN_181428f50(*(longlong *)(local_198 + 0x50),uVar7 & 0xffffffff,
                                      DAT_182ee41f0);
        if (fVar20 <= 0.0) {
          fVar20 = 5000.0;
        }
        else {
          if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(local_198 + 0x50) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          fVar20 = (float)FUN_181428f50(*(longlong *)(local_198 + 0x50),uVar7 & 0xffffffff,
                                        DAT_182ee41f0);
          fVar20 = 20.0 - fVar20;
          if (fVar20 <= 0.0) {
            fVar20 = 0.0;
          }
        }
      }
      if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_198 + 0x40) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar9 = FUN_1813fe630(*(longlong *)(local_198 + 0x40),uVar7 & 0xffffffff,DAT_182ebe118);
      fVar17 = (float)BurgsAndStateGenerator__<ExpandProvinces>g__getBiomeCost_27_0
                                (uVar3,uVar9,uVar12,0);
      if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_198 + 0x30) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar9 = FUN_1813fe630(*(longlong *)(local_198 + 0x30),uVar7 & 0xffffffff,DAT_182ebe118);
      fVar18 = (float)BurgsAndStateGenerator__<ExpandProvinces>g__getRiverCost_27_2
                                (uVar9,uVar7 & 0xffffffff,uVar12,&local_198,0);
      if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(local_198 + 0x80) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar9 = FUN_1813fe630(*(longlong *)(local_198 + 0x80),uVar7 & 0xffffffff,DAT_182ebe118);
      fVar19 = (float)BurgsAndStateGenerator__<ExpandProvinces>g__getTypeCost_27_3(uVar9,uVar12,0);
      fVar19 = (float)iVar10 + fVar20 + fVar17 + 0.0 + fVar18 + fVar19;
      if (fVar19 <= 0.0) {
        fVar19 = 0.0;
      }
      lVar16 = FUN_1813e2d10(lVar5,uVar2,DAT_182ed80a8);
      if (lVar16 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      fVar17 = fVar1 + 10.0 + fVar19 / *(float *)(lVar16 + 0x60);
      fVar20 = (float)FUN_181428f50(lVar13,uVar7 & 0xffffffff,DAT_182ee41f0);
      if ((fVar20 == 0.0) ||
         (fVar20 = (float)FUN_181428f50(lVar13,uVar7 & 0xffffffff,DAT_182ee41f0), lVar16 = local_190
         , fVar17 < fVar20)) {
        if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        if (*(longlong *)(local_198 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        iVar10 = FUN_1813fe630(*(longlong *)(local_198 + 0x18),uVar7 & 0xffffffff,DAT_182ebe118);
        if (0x13 < iVar10) {
          if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(local_198 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          FUN_181409950(*(longlong *)(local_198 + 0xc0),uVar7 & 0xffffffff,uVar2,DAT_182ebe2c8);
        }
        FUN_181428fa0(lVar13,uVar7 & 0xffffffff,fVar17,DAT_182ee4398);
        lVar15 = thunk_FUN_1802a5470(DAT_182e9e058);
        if (lVar15 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        AISystemState__Start(lVar15,0);
        lVar16 = local_190;
        *(int *)(lVar15 + 0x14) = iVar6;
        *(float *)(lVar15 + 0x10) = fVar17;
        *(undefined4 *)(lVar15 + 0x1c) = uVar3;
        *(undefined4 *)(lVar15 + 0x18) = uVar2;
        FUN_1814e95d0(local_190,lVar15,fVar17);
      }
    }
  }
  goto LAB_180487325;
}

