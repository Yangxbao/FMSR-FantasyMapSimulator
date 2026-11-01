
undefined1 BurgsAndStateGenerator__EnsureProvinceConnectivity(longlong param_1)

{
  longlong lVar1;
  undefined8 uVar2;
  bool bVar3;
  ulonglong uVar4;
  char cVar5;
  int iVar6;
  undefined4 uVar7;
  longlong lVar8;
  longlong lVar9;
  longlong lVar10;
  longlong lVar11;
  undefined1 local_res20;
  longlong local_168;
  longlong local_160;
  undefined8 uStack_158;
  longlong local_150;
  longlong local_148;
  undefined8 local_140;
  undefined8 uStack_138;
  ulonglong local_130;
  undefined8 local_128;
  undefined8 uStack_120;
  ulonglong local_118;
  undefined4 local_110;
  undefined4 uStack_10c;
  undefined4 uStack_108;
  undefined4 uStack_104;
  ulonglong local_100;
  longlong local_f8;
  longlong local_f0;
  undefined8 local_e8;
  undefined8 *local_e0;
  undefined8 local_d8;
  undefined4 *local_d0;
  undefined8 local_c8;
  undefined8 uStack_c0;
  longlong local_b8;
  undefined8 local_b0;
  undefined8 *local_a8;
  undefined8 local_a0;
  undefined8 *local_98;
  longlong local_90;
  longlong local_88;
  undefined4 local_80;
  undefined4 uStack_7c;
  undefined4 uStack_78;
  undefined4 uStack_74;
  longlong local_70;
  
  if (DAT_183060238 == '\0') {
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182efd4f0);
    FUN_1802334a0(&DAT_182ef1c88);
    FUN_1802334a0(&DAT_182ef1d58);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182efd5c8);
    FUN_1802334a0(&DAT_182efd698);
    FUN_1802334a0(&DAT_182ef1fd0);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182eb6d48);
    FUN_1802334a0(&DAT_182eb7180);
    FUN_1802334a0(&DAT_182eb7408);
    FUN_1802334a0(&DAT_182eb7e28);
    FUN_1802334a0(&DAT_182eb6b98);
    FUN_1802334a0(&DAT_182eb6ac0);
    FUN_1802334a0(&DAT_182eb8338);
    FUN_1802334a0(&DAT_182eb23d8);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182ed7ac0);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebcce8);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182ecac80);
    FUN_1802334a0(&DAT_182ecad58);
    FUN_1802334a0(&DAT_182eca928);
    FUN_1802334a0(&DAT_182ecafe0);
    FUN_1802334a0(&DAT_182efa948);
    DAT_183060238 = '\x01';
  }
  local_160 = 0;
  uStack_158 = 0;
  local_140 = 0;
  uStack_138 = 0;
  local_130 = 0;
  local_128 = 0;
  uStack_120 = 0;
  local_118 = 0;
  local_168 = param_1;
  FUN_180232f70(&local_168,param_1);
  if (*(longlong *)(param_1 + 0x10) != 0) {
    local_160 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
    FUN_180232f70(&local_160);
    lVar1 = *(longlong *)(param_1 + 0x10);
    if (lVar1 != 0) {
      lVar8 = *(longlong *)(lVar1 + 0x288);
      uStack_158 = *(undefined8 *)(lVar1 + 0x270);
      FUN_180232f70(&uStack_158);
      if (lVar8 != 0) {
        local_res20 = 0;
        FUN_1813e0e20(&local_c8,lVar8,DAT_182ed7ac0);
        local_80 = (undefined4)local_c8;
        uStack_7c = local_c8._4_4_;
        uStack_78 = (undefined4)uStack_c0;
        uStack_74 = uStack_c0._4_4_;
        local_70 = local_b8;
        local_d8 = 0;
        local_d0 = &local_80;
        do {
          do {
            do {
              do {
                cVar5 = FUN_1811ab230(&local_80,DAT_182efd5c8);
                lVar1 = local_70;
                if (cVar5 == '\0') {
                  AISystemState__Start(local_d0,DAT_182efd4f0);
                  return local_res20;
                }
                local_150 = local_70;
              } while (((((local_70 == 0) || (*(int *)(local_70 + 0x10) == 0)) ||
                        (*(char *)(local_70 + 0x89) == '\0')) ||
                       ((*(longlong *)(local_70 + 0xa8) == 0 ||
                        (*(int *)(*(longlong *)(local_70 + 0xa8) + 0x18) == 0)))) ||
                      (iVar6 = BurgsAndStateGenerator__<EnsureProvinceConnectivity>g__GetMainCell_24_1
                                         (param_1,local_70,&local_168,0), iVar6 < 0));
              lVar8 = BurgsAndStateGenerator__<EnsureProvinceConnectivity>g__CollectComponent_24_0
                                (param_1,iVar6,*(undefined4 *)(lVar1 + 0x10),&local_168,0);
              local_148 = lVar8;
              if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              if (*(longlong *)(lVar1 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
            } while (*(int *)(lVar8 + 0x20) == *(int *)(*(longlong *)(lVar1 + 0xa8) + 0x18));
            uVar2 = *(undefined8 *)(lVar1 + 0xa8);
            lVar9 = thunk_FUN_1802a5470(DAT_182eb23d8);
            if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_1812c1900(lVar9,uVar2,DAT_182eb6b98);
            FUN_1812d24f0(&local_110,lVar8,DAT_182eb7408);
            local_140 = CONCAT44(uStack_10c,local_110);
            uStack_138 = CONCAT44(uStack_104,uStack_108);
            local_130 = local_100;
            local_b0 = 0;
            local_a8 = &local_140;
            while (cVar5 = FUN_1811a8b30(&local_140,DAT_182ef1d58), cVar5 != '\0') {
              FUN_1812d9a40(lVar9,local_130 & 0xffffffff,DAT_182eb7e28);
            }
            AISystemState__Start(&local_140,DAT_182ef1c88);
          } while (*(int *)(lVar9 + 0x20) == 0);
          lVar10 = thunk_FUN_1802a5470(DAT_182eb23d8);
          if (lVar10 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          FUN_1812c1600(lVar10,DAT_182eb6ac0);
          local_f0 = lVar10;
          FUN_1812d24f0(&local_110,lVar9,DAT_182eb7408);
          local_140 = CONCAT44(uStack_10c,local_110);
          uStack_138 = CONCAT44(uStack_104,uStack_108);
          local_130 = local_100;
          local_e8 = 0;
          local_e0 = &local_140;
          while (cVar5 = FUN_1811a8b30(&local_140,DAT_182ef1d58), uVar4 = local_130, cVar5 != '\0')
          {
            cVar5 = FUN_1812d0350(lVar10,local_130 & 0xffffffff,DAT_182eb7180);
            if (cVar5 == '\0') {
              lVar9 = thunk_FUN_1802a5470(DAT_182edbc38);
              local_f8 = lVar9;
              if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              FUN_1813e2b90(lVar9,DAT_182ebcce8);
              lVar11 = thunk_FUN_1802a5470(DAT_182efa948);
              if (lVar11 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              FUN_180defcd0(lVar11,DAT_182eca928);
              local_88 = lVar11;
              FUN_1814ee5f0(lVar11,uVar4 & 0xffffffff,DAT_182ecad58);
              local_90 = lVar9;
              FUN_1812b58f0(lVar10,uVar4 & 0xffffffff,DAT_182eb6d48);
              bVar3 = false;
              while (0 < *(int *)(lVar11 + 0x20)) {
                uVar7 = FUN_1814ede40(lVar11,DAT_182ecac80);
                FUN_1800048f0(lVar9,uVar7,DAT_182ebcf70);
                if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                lVar9 = World__GetNeighborCells(*(longlong *)(param_1 + 0x10),uVar7,0);
                if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                FUN_1813f96b0(&local_110,lVar9,DAT_182ebd480);
                local_128 = CONCAT44(uStack_10c,local_110);
                uStack_120 = CONCAT44(uStack_104,uStack_108);
                local_118 = local_100;
                local_a0 = 0;
                local_98 = &local_128;
                while (cVar5 = FUN_1811a17e0(&local_128,DAT_182ef2178), uVar4 = local_118,
                      cVar5 != '\0') {
                  if (local_160 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  if (*(longlong *)(local_160 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  iVar6 = FUN_1813fe630(*(longlong *)(local_160 + 0xc0),local_118 & 0xffffffff,
                                        DAT_182ebe118);
                  if (iVar6 == *(int *)(lVar1 + 0x10)) {
                    cVar5 = FUN_1812d0350(lVar8,uVar4 & 0xffffffff,DAT_182eb7180);
                    if ((cVar5 == '\0') &&
                       (cVar5 = FUN_1812d0350(lVar10,uVar4 & 0xffffffff,DAT_182eb7180),
                       cVar5 == '\0')) {
                      FUN_1812b58f0(lVar10,uVar4 & 0xffffffff,DAT_182eb6d48);
                      FUN_1814ee5f0(lVar11,uVar4 & 0xffffffff,DAT_182ecad58);
                    }
                  }
                  else {
                    if (local_160 == 0) {
                    /* WARNING: Subroutine does not return */
                      FUN_180233680();
                    }
                    if (*(longlong *)(local_160 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
                      FUN_180233680();
                    }
                    iVar6 = FUN_1813fe630(*(longlong *)(local_160 + 0x18),uVar4 & 0xffffffff,
                                          DAT_182ebe118);
                    if (iVar6 < 0x14) {
                      bVar3 = true;
                    }
                  }
                }
                AISystemState__Start(&local_128,DAT_182ef20a0);
                lVar9 = local_f8;
              }
              if (!bVar3) {
                FUN_1813f96b0(&local_110,lVar9,DAT_182ebd480);
                local_128 = CONCAT44(uStack_10c,local_110);
                uStack_120 = CONCAT44(uStack_104,uStack_108);
                local_118 = local_100;
                local_c8 = 0;
                uStack_c0 = &local_128;
                while (cVar5 = FUN_1811a17e0(&local_128,DAT_182ef2178), uVar4 = local_118,
                      cVar5 != '\0') {
                  iVar6 = BurgsAndStateGenerator__<EnsureProvinceConnectivity>g__FindBestNeighborProvince_24_2
                                    (param_1,*(undefined4 *)(lVar1 + 0x10),local_118 & 0xffffffff,
                                     &local_168,0);
                  if (iVar6 != *(int *)(lVar1 + 0x10)) {
                    if (local_160 == 0) {
                    /* WARNING: Subroutine does not return */
                      FUN_180233680();
                    }
                    if (*(longlong *)(local_160 + 0xc0) == 0) {
                    /* WARNING: Subroutine does not return */
                      FUN_180233680();
                    }
                    FUN_181409950(*(longlong *)(local_160 + 0xc0),uVar4 & 0xffffffff,iVar6);
                    local_res20 = 1;
                  }
                }
                AISystemState__Start(&local_128,DAT_182ef20a0);
              }
            }
          }
          AISystemState__Start(local_e0,DAT_182ef1c88);
        } while( true );
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

