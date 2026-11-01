
longlong BurgsAndStateGenerator__PlaceProvincialCapitalsByJitterGrid(longlong param_1)

{
  longlong lVar1;
  longlong lVar2;
  ulonglong uVar3;
  longlong lVar4;
  char cVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  int iVar9;
  longlong lVar10;
  longlong lVar11;
  longlong lVar12;
  undefined8 uVar13;
  undefined4 local_res18 [2];
  longlong local_res20;
  undefined8 local_b8;
  undefined8 uStack_b0;
  ulonglong local_a8;
  longlong local_a0;
  undefined4 local_98;
  undefined4 uStack_94;
  undefined4 uStack_90;
  undefined4 uStack_8c;
  ulonglong local_88;
  longlong local_80;
  longlong local_78;
  longlong local_70;
  longlong local_68;
  longlong local_60;
  longlong local_58;
  
  if (DAT_183060231 == '\0') {
    FUN_1802334a0(&DAT_182ea1000);
    FUN_1802334a0(&DAT_182ea4670);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182eb6d48);
    FUN_1802334a0(&DAT_182eb7180);
    FUN_1802334a0(&DAT_182eb6ac0);
    FUN_1802334a0(&DAT_182eb23d8);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182e99aa8);
    FUN_1802334a0(&DAT_182e99c48);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebcce8);
    FUN_1802334a0(&DAT_182e99de8);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182ebd820);
    FUN_1802334a0(&DAT_182e94b40);
    FUN_1802334a0(&DAT_182ec1e48);
    FUN_1802334a0(&DAT_182ec2e00);
    FUN_1802334a0(&DAT_182e8c050);
    DAT_183060231 = '\x01';
  }
  local_res18[0] = 0;
  lVar1 = *(longlong *)(param_1 + 0x10);
  if (lVar1 != 0) {
    lVar2 = *(longlong *)(lVar1 + 0x270);
    local_78 = lVar2;
    if (lVar2 != 0) {
      lVar1 = *(longlong *)(lVar1 + 0x148);
      if (*(int *)(lVar2 + 0x18) == 0) {
        lVar10 = thunk_FUN_1802a5470(DAT_182ea4670);
        if (lVar10 == 0) goto LAB_180491da0;
        BurgData___ctor(lVar10,0);
        FUN_180304090(lVar2,lVar10,DAT_182e99aa8);
      }
      if (*(longlong *)(param_1 + 0x10) != 0) {
        lVar10 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x278);
        local_68 = lVar10;
        if (lVar10 != 0) {
          *(int *)(lVar10 + 0x1c) = *(int *)(lVar10 + 0x1c) + 1;
          iVar9 = *(int *)(lVar10 + 0x18);
          *(undefined4 *)(lVar10 + 0x18) = 0;
          if (0 < iVar9) {
            System_Array__Clear(*(undefined8 *)(lVar10 + 0x10),0,iVar9,0);
          }
          lVar11 = thunk_FUN_1802a5470(DAT_182ebd820);
          if (lVar11 != 0) {
            MostEnemyArmyProvinceStrategy___ctor(lVar11,0);
            if (*(longlong *)(param_1 + 0x10) != 0) {
              World__EnsureProvinceBurgCellsReady(*(longlong *)(param_1 + 0x10),0);
              if (*(longlong *)(param_1 + 0x10) != 0) {
                local_res20 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 800);
                lVar11 = thunk_FUN_1802a5470(DAT_182edbc38);
                if (lVar11 != 0) {
                  FUN_1813e2b90(lVar11,DAT_182ebcce8);
                  local_80 = thunk_FUN_1802a5470(DAT_182edbc38);
                  if (local_80 != 0) {
                    FUN_1813e2b90(local_80,DAT_182ebcce8);
                    lVar12 = thunk_FUN_1802a5470(DAT_182eb23d8);
                    local_a0 = lVar12;
                    if (lVar12 != 0) {
                      FUN_1812c1600(lVar12,DAT_182eb6ac0);
                      local_58 = lVar12;
                      if (*(int *)(DAT_182ea1000 + 0xe0) == 0) {
                        il2cpp_runtime_class_init();
                      }
                      uVar6 = Biomes__GetBiomeNameIndex(DAT_182e8c050,0);
                      uVar7 = Biomes__GetBiomeNameIndex(DAT_182ec1e48,0);
                      uVar8 = Biomes__GetBiomeNameIndex(DAT_182ec2e00,0);
                      lVar12 = local_a0;
                      FUN_1812b58f0(local_a0,uVar6,DAT_182eb6d48);
                      FUN_1812b58f0(lVar12,uVar7,DAT_182eb6d48);
                      FUN_1812b58f0(lVar12,uVar8,DAT_182eb6d48);
                      lVar4 = local_80;
                      lVar12 = local_res20;
                      if (local_res20 != 0) {
                        local_60 = local_80;
                        local_res20 = lVar11;
                        local_70 = lVar1;
                        FUN_1813f96b0(&local_b8,lVar12,DAT_182ebd480);
                        local_98 = (undefined4)local_b8;
                        uStack_94 = local_b8._4_4_;
                        uStack_90 = (undefined4)uStack_b0;
                        uStack_8c = uStack_b0._4_4_;
                        local_88 = local_a8;
                        local_b8 = 0;
                        uStack_b0 = &local_98;
LAB_1804918b0:
                        do {
                          cVar5 = FUN_1811a17e0(&local_98,DAT_182ef2178);
                          uVar3 = local_88;
                          if (cVar5 == '\0') {
                            AISystemState__Start(&local_98,DAT_182ef20a0);
                            lVar12 = local_a0;
                            local_res20 = CONCAT44(local_res20._4_4_,*(undefined4 *)(lVar2 + 0x18));
                            FUN_1813f96b0(&local_b8,lVar11,DAT_182ebd480);
                            local_98 = (undefined4)local_b8;
                            uStack_94 = local_b8._4_4_;
                            uStack_90 = (undefined4)uStack_b0;
                            uStack_8c = uStack_b0._4_4_;
                            local_88 = local_a8;
                            local_b8 = 0;
                            iVar9 = (int)local_res20;
                            uStack_b0 = &local_98;
                            while( true ) {
                              do {
                                cVar5 = FUN_1811a17e0(&local_98,DAT_182ef2178);
                                uVar3 = local_88;
                                if (cVar5 == '\0') {
                                  AISystemState__Start(&local_98,DAT_182ef20a0);
                                  iVar9 = 1;
                                  FUN_1813f96b0(&local_b8,local_80,DAT_182ebd480);
                                  local_98 = (undefined4)local_b8;
                                  uStack_94 = local_b8._4_4_;
                                  uStack_90 = (undefined4)uStack_b0;
                                  uStack_8c = uStack_b0._4_4_;
                                  local_88 = local_a8;
                                  local_b8 = 0;
                                  uStack_b0 = &local_98;
                                  while( true ) {
                                    cVar5 = FUN_1811a17e0(&local_98,DAT_182ef2178);
                                    uVar3 = local_88;
                                    if (cVar5 == '\0') {
                                      AISystemState__Start(&local_98,DAT_182ef20a0);
                                      return lVar2;
                                    }
                                    uVar6 = (undefined4)local_88;
                                    lVar11 = thunk_FUN_1802a5470(DAT_182ea4670);
                                    if (lVar11 == 0) {
                    /* WARNING: Subroutine does not return */
                                      FUN_180233680();
                                    }
                                    BurgData___ctor(lVar11,0);
                                    *(undefined4 *)(lVar11 + 0x38) = uVar6;
                                    if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
                                      FUN_180233680();
                                    }
                                    if (*(longlong *)(lVar1 + 0x88) == 0) break;
                                    uVar6 = FUN_1813fe630(*(longlong *)(lVar1 + 0x88),
                                                          uVar3 & 0xffffffff,DAT_182ebe118);
                                    *(undefined4 *)(lVar11 + 0x3c) = uVar6;
                                    if (*(longlong *)(lVar1 + 0x78) == 0) {
                    /* WARNING: Subroutine does not return */
                                      FUN_180233680();
                                    }
                                    uVar6 = FUN_1813fe630(*(longlong *)(lVar1 + 0x78),
                                                          uVar3 & 0xffffffff,DAT_182ebe118);
                                    *(undefined4 *)(lVar11 + 0x44) = uVar6;
                                    if (*(longlong *)(lVar1 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
                                      FUN_180233680();
                                    }
                                    uVar6 = FUN_1813fe630(*(longlong *)(lVar1 + 0xa8),
                                                          uVar3 & 0xffffffff,DAT_182ebe118);
                                    *(undefined4 *)(lVar11 + 0x40) = uVar6;
                                    local_res18[0] = *(undefined4 *)(lVar10 + 0x18);
                                    uVar13 = System_Int32__ToString(local_res18,0);
                                    uVar13 = System_String__Concat(DAT_182e94b40,uVar13,0);
                                    *(undefined8 *)(lVar11 + 0x18) = uVar13;
                                    FUN_180232f70(lVar11 + 0x18,uVar13);
                                    *(undefined4 *)(lVar11 + 0x58) = 0;
                                    *(int *)(lVar11 + 0x60) = iVar9;
                                    *(undefined1 *)(lVar11 + 100) = 0;
                                    FUN_180304090(lVar10,lVar11,DAT_182e99aa8);
                                    if (*(longlong *)(lVar1 + 0x90) == 0) {
                    /* WARNING: Subroutine does not return */
                                      FUN_180233680();
                                    }
                                    iVar9 = iVar9 + 1;
                                    FUN_181409950(*(longlong *)(lVar1 + 0x90),uVar3 & 0xffffffff,
                                                  *(undefined4 *)(lVar10 + 0x18),DAT_182ebe2c8);
                                  }
                    /* WARNING: Subroutine does not return */
                                  FUN_180233680();
                                }
                                if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
                                  FUN_180233680();
                                }
                                if (*(longlong *)(lVar1 + 0x40) == 0) {
                    /* WARNING: Subroutine does not return */
                                  FUN_180233680();
                                }
                                uVar6 = (undefined4)local_88;
                                uVar7 = FUN_1813fe630(*(longlong *)(lVar1 + 0x40),
                                                      local_88 & 0xffffffff,DAT_182ebe118);
                                cVar5 = FUN_1812d0350(lVar12,uVar7,DAT_182eb7180);
                              } while ((cVar5 != '\0') && (*(char *)(param_1 + 0x28) != '\0'));
                              lVar11 = thunk_FUN_1802a5470(DAT_182ea4670);
                              if (lVar11 == 0) {
                    /* WARNING: Subroutine does not return */
                                FUN_180233680();
                              }
                              BurgData___ctor(lVar11,0);
                              *(undefined4 *)(lVar11 + 0x38) = uVar6;
                              if (*(longlong *)(lVar1 + 0x88) == 0) {
                    /* WARNING: Subroutine does not return */
                                FUN_180233680();
                              }
                              uVar6 = FUN_1813fe630(*(longlong *)(lVar1 + 0x88),uVar3 & 0xffffffff,
                                                    DAT_182ebe118);
                              *(undefined4 *)(lVar11 + 0x3c) = uVar6;
                              if (*(longlong *)(lVar1 + 0x78) == 0) {
                    /* WARNING: Subroutine does not return */
                                FUN_180233680();
                              }
                              uVar6 = FUN_1813fe630(*(longlong *)(lVar1 + 0x78),uVar3 & 0xffffffff,
                                                    DAT_182ebe118);
                              *(undefined4 *)(lVar11 + 0x44) = uVar6;
                              if (*(longlong *)(lVar1 + 0xa8) == 0) break;
                              uVar6 = FUN_1813fe630(*(longlong *)(lVar1 + 0xa8),uVar3 & 0xffffffff,
                                                    DAT_182ebe118);
                              *(undefined4 *)(lVar11 + 0x40) = uVar6;
                              local_res18[0] = *(undefined4 *)(lVar2 + 0x18);
                              uVar13 = System_Int32__ToString(local_res18,0);
                              uVar13 = System_String__Concat(DAT_182e94b40,uVar13,0);
                              *(undefined8 *)(lVar11 + 0x18) = uVar13;
                              FUN_180232f70(lVar11 + 0x18,uVar13);
                              *(undefined4 *)(lVar11 + 0x58) = 0;
                              *(int *)(lVar11 + 0x60) = iVar9;
                              *(undefined1 *)(lVar11 + 100) = 1;
                              FUN_180304090(lVar2,lVar11,DAT_182e99aa8);
                              if (*(longlong *)(lVar1 + 0x90) == 0) {
                    /* WARNING: Subroutine does not return */
                                FUN_180233680();
                              }
                              iVar9 = iVar9 + 1;
                              FUN_181409950(*(longlong *)(lVar1 + 0x90),uVar3 & 0xffffffff,
                                            *(undefined4 *)(lVar2 + 0x18),DAT_182ebe2c8);
                              lVar12 = local_a0;
                            }
                    /* WARNING: Subroutine does not return */
                            FUN_180233680();
                          }
                          if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
                            FUN_180233680();
                          }
                          if (*(longlong *)(lVar1 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
                            FUN_180233680();
                          }
                          iVar9 = FUN_1813fe630(*(longlong *)(lVar1 + 0x18),local_88 & 0xffffffff,
                                                DAT_182ebe118);
                          if (0x13 < iVar9) {
                            if (*(longlong *)(lVar1 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
                              FUN_180233680();
                            }
                            iVar9 = FUN_1813fe630(*(longlong *)(lVar1 + 0xa8),uVar3 & 0xffffffff,
                                                  DAT_182ebe118);
                            if (iVar9 == 0) {
                              FUN_1800048f0(lVar11,uVar3 & 0xffffffff,DAT_182ebcf70);
                              goto LAB_1804918b0;
                            }
                          }
                          if (*(longlong *)(lVar1 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
                            FUN_180233680();
                          }
                          iVar9 = FUN_1813fe630(*(longlong *)(lVar1 + 0x18),uVar3 & 0xffffffff,
                                                DAT_182ebe118);
                          if (iVar9 < 0x14) {
                            FUN_1800048f0(lVar4,uVar3 & 0xffffffff,DAT_182ebcf70);
                          }
                        } while( true );
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
LAB_180491da0:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

