
void BurgsAndStateGenerator__ExpandSeaProvinces(longlong param_1)

{
  undefined4 uVar1;
  longlong lVar2;
  longlong lVar3;
  longlong lVar4;
  undefined4 uVar5;
  ulonglong uVar6;
  longlong lVar7;
  char cVar8;
  undefined4 uVar9;
  int iVar10;
  undefined4 uVar11;
  longlong lVar12;
  longlong lVar13;
  longlong lVar14;
  undefined8 local_c8;
  undefined8 uStack_c0;
  longlong local_b8;
  longlong local_b0;
  longlong local_a8;
  longlong local_a0;
  undefined8 local_98;
  undefined8 uStack_90;
  ulonglong local_88;
  undefined4 local_80;
  undefined4 uStack_7c;
  undefined4 uStack_78;
  undefined4 uStack_74;
  longlong local_70;
  undefined4 local_58;
  undefined4 uStack_54;
  undefined4 uStack_50;
  undefined4 uStack_4c;
  ulonglong local_48;
  
  if (DAT_18306023c == '\0') {
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182efd4f0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182efd5c8);
    FUN_1802334a0(&DAT_182efd698);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182ed7ac0);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182e99eb8);
    FUN_1802334a0(&DAT_182ea15c0);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ed80a8);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182e9e058);
    FUN_1802334a0(&DAT_182ecd858);
    FUN_1802334a0(&DAT_182ecd930);
    FUN_1802334a0(&DAT_182ecd780);
    FUN_1802334a0(&DAT_182ecda08);
    FUN_1802334a0(&DAT_182efb0c0);
    DAT_18306023c = '\x01';
  }
  local_98 = 0;
  uStack_90 = 0;
  local_88 = 0;
  lVar14 = *(longlong *)(param_1 + 0x10);
  if (lVar14 != 0) {
    lVar2 = *(longlong *)(lVar14 + 0x148);
    lVar3 = *(longlong *)(lVar14 + 0x288);
    lVar4 = *(longlong *)(lVar14 + 0x278);
    lVar14 = *(longlong *)(lVar14 + 0x280);
    lVar12 = thunk_FUN_1802a5470(DAT_182efb0c0);
    if (lVar12 != 0) {
      local_a8 = lVar3;
      FUN_180defcd0(lVar12,DAT_182ecd780);
      if (lVar3 != 0) {
        local_b0 = lVar2;
        local_a0 = lVar12;
        FUN_1813e0e20(&local_c8,lVar3,DAT_182ed7ac0);
        local_80 = (undefined4)local_c8;
        uStack_7c = local_c8._4_4_;
        uStack_78 = (undefined4)uStack_c0;
        uStack_74 = uStack_c0._4_4_;
        local_70 = local_b8;
        local_c8 = 0;
        uStack_c0 = (undefined8 *)&local_80;
        while( true ) {
          cVar8 = FUN_1811ab230(&local_80,DAT_182efd5c8);
          lVar7 = local_70;
          if (cVar8 == '\0') break;
          if (local_70 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if ((*(int *)(local_70 + 0x10) != 0) && (*(char *)(local_70 + 0x89) == '\0')) {
            if (lVar4 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar13 = FUN_1813e2d10(lVar4,*(undefined4 *)(local_70 + 100),DAT_182e99eb8);
            if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (lVar2 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(lVar2 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_181409950(*(longlong *)(lVar2 + 0xc0),*(undefined4 *)(lVar13 + 0x38),
                          *(undefined4 *)(lVar7 + 0x10),DAT_182ebe2c8);
            if (lVar14 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar13 = FUN_1813e2d10(lVar14,*(undefined4 *)(lVar7 + 0x70),DAT_182ea15c0);
            if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(lVar2 + 0x40) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            uVar9 = FUN_1813fe630(*(longlong *)(lVar2 + 0x40),*(undefined4 *)(lVar13 + 0x70),
                                  DAT_182ebe118);
            lVar13 = thunk_FUN_1802a5470(DAT_182e9e058);
            if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            AISystemState__Start(lVar13,0);
            *(undefined4 *)(lVar13 + 0x14) = *(undefined4 *)(lVar7 + 0x48);
            *(undefined4 *)(lVar13 + 0x10) = 0;
            *(undefined4 *)(lVar13 + 0x1c) = uVar9;
            *(undefined4 *)(lVar13 + 0x18) = *(undefined4 *)(lVar7 + 0x10);
            FUN_1814ee2b0(lVar12,lVar13);
          }
        }
        AISystemState__Start(&local_80,DAT_182efd4f0);
        while( true ) {
          if (*(int *)(lVar12 + 0x20) < 1) {
            return;
          }
          lVar14 = FUN_1814edb90(lVar12,DAT_182ecd858);
          if ((lVar14 == 0) || (*(longlong *)(param_1 + 0x10) == 0)) break;
          uVar9 = *(undefined4 *)(lVar14 + 0x18);
          uVar1 = *(undefined4 *)(lVar14 + 0x1c);
          lVar14 = World__GetNeighborCells
                             (*(longlong *)(param_1 + 0x10),*(undefined4 *)(lVar14 + 0x14),0);
          if (lVar14 == 0) break;
          FUN_1813f96b0(&local_58,lVar14);
          local_98 = CONCAT44(uStack_54,local_58);
          uStack_90 = CONCAT44(uStack_4c,uStack_50);
          local_88 = local_48;
          local_c8 = 0;
          uStack_c0 = &local_98;
          while( true ) {
            cVar8 = FUN_1811a17e0(&local_98,DAT_182ef2178);
            uVar6 = local_88;
            if (cVar8 == '\0') break;
            if (lVar2 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            if (*(longlong *)(lVar2 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            uVar5 = (undefined4)local_88;
            iVar10 = FUN_1813fe630(*(longlong *)(lVar2 + 0xc0),local_88 & 0xffffffff);
            if (iVar10 < 1) {
              if (*(longlong *)(lVar2 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              iVar10 = FUN_1813fe630(*(longlong *)(lVar2 + 0x18),uVar6 & 0xffffffff);
              if (iVar10 < 0x14) {
                if (*(longlong *)(lVar2 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                uVar11 = FUN_1813fe630(*(longlong *)(lVar2 + 0xc0),uVar6 & 0xffffffff,DAT_182ebe118)
                ;
                FUN_1813e2d10(lVar3,uVar11,DAT_182ed80a8);
                if (*(longlong *)(lVar2 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                iVar10 = FUN_1813fe630(*(longlong *)(lVar2 + 0x18),uVar6 & 0xffffffff,DAT_182ebe118)
                ;
                if (iVar10 < 0x14) {
                  if (*(longlong *)(lVar2 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  FUN_181409950(*(longlong *)(lVar2 + 0xc0),uVar6 & 0xffffffff,uVar9,DAT_182ebe2c8);
                }
                lVar14 = thunk_FUN_1802a5470(DAT_182e9e058);
                if (lVar14 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                AISystemState__Start(lVar14,0);
                *(undefined4 *)(lVar14 + 0x14) = uVar5;
                *(undefined4 *)(lVar14 + 0x10) = 0x3f800000;
                *(undefined4 *)(lVar14 + 0x1c) = uVar1;
                *(undefined4 *)(lVar14 + 0x18) = uVar9;
                FUN_1814ee2b0(lVar12,lVar14);
              }
            }
          }
          AISystemState__Start(&local_98,DAT_182ef20a0);
        }
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

