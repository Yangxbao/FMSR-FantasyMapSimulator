
void BurgsAndStateGenerator__FilterProvinceCells(void)

{
  int iVar1;
  undefined4 uVar2;
  longlong lVar3;
  char cVar4;
  int iVar5;
  longlong lVar6;
  longlong lVar7;
  longlong lVar8;
  int iVar9;
  undefined8 local_60;
  undefined8 uStack_58;
  longlong local_50;
  undefined4 local_48;
  undefined4 uStack_44;
  undefined4 uStack_40;
  undefined4 uStack_3c;
  longlong local_38;
  
  if (DAT_183060237 == '\0') {
    FUN_1802334a0(&DAT_182edcd98);
    FUN_1802334a0(&DAT_182efd4f0);
    FUN_1802334a0(&DAT_182efd5c8);
    FUN_1802334a0(&DAT_182efd698);
    FUN_1802334a0(&DAT_182eb70a8);
    FUN_1802334a0(&DAT_182eb6ac0);
    FUN_1802334a0(&DAT_182eb23d8);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182ebd1f8);
    FUN_1802334a0(&DAT_182ed7ac0);
    FUN_1802334a0(&DAT_182ebcce8);
    FUN_1802334a0(&DAT_182ed7fd0);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ed80a8);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182e93d88);
    FUN_1802334a0(&DAT_182ef93e8);
    FUN_1802334a0(&DAT_182efe578);
    FUN_1802334a0(&DAT_182ee2b08);
    DAT_183060237 = '\x01';
  }
  lVar6 = thunk_FUN_1802a5470(DAT_182efe578);
  if (lVar6 != 0) {
    MostEnemyArmyProvinceStrategy___ctor(lVar6,0);
    if (*(int *)(DAT_182ee2b08 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    lVar7 = World__get_Instance(0);
    if (lVar7 != 0) {
      lVar3 = *(longlong *)(lVar7 + 0x148);
      *(undefined8 *)(lVar6 + 0x10) = *(undefined8 *)(lVar7 + 0x288);
      FUN_180232f70(lVar6 + 0x10);
      if (*(longlong *)(lVar6 + 0x10) != 0) {
        if (*(int *)(*(longlong *)(lVar6 + 0x10) + 0x18) == 0) {
          return;
        }
        if (lVar3 != 0) {
          *(undefined8 *)(lVar6 + 0x20) = *(undefined8 *)(lVar3 + 0xc0);
          FUN_180232f70(lVar6 + 0x20);
          *(undefined8 *)(lVar6 + 0x28) = *(undefined8 *)(lVar3 + 0x18);
          FUN_180232f70(lVar6 + 0x28);
          *(undefined8 *)(lVar6 + 0x18) = *(undefined8 *)(lVar3 + 0x108);
          FUN_180232f70(lVar6 + 0x18);
          *(undefined8 *)(lVar6 + 0x30) = *(undefined8 *)(lVar3 + 0x78);
          FUN_180232f70(lVar6 + 0x30);
          if (*(longlong *)(lVar6 + 0x10) != 0) {
            FUN_1813e0e20(&local_60,*(longlong *)(lVar6 + 0x10),DAT_182ed7ac0);
            local_48 = (undefined4)local_60;
            uStack_44 = local_60._4_4_;
            uStack_40 = (undefined4)uStack_58;
            uStack_3c = uStack_58._4_4_;
            local_38 = local_50;
            iVar9 = 0;
            local_60 = 0;
            uStack_58 = &local_48;
            while (cVar4 = FUN_1811ab230(&local_48,DAT_182efd5c8), lVar7 = local_38, cVar4 != '\0')
            {
              if (local_38 != 0) {
                if (*(longlong *)(local_38 + 0xa8) == 0) {
                  lVar8 = thunk_FUN_1802a5470(DAT_182edbc38);
                  if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  FUN_1813e2b90(lVar8,DAT_182ebcce8);
                  *(longlong *)(lVar7 + 0xa8) = lVar8;
                  FUN_180232f70(lVar7 + 0xa8,lVar8);
                }
                if (*(longlong *)(lVar7 + 0xa0) == 0) {
                  lVar8 = thunk_FUN_1802a5470(DAT_182eb23d8);
                  if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  FUN_1812c1600(lVar8,DAT_182eb6ac0);
                  *(longlong *)(lVar7 + 0xa0) = lVar8;
                  FUN_180232f70(lVar7 + 0xa0,lVar8);
                }
                if (*(longlong *)(lVar7 + 0xb0) == 0) {
                  lVar8 = thunk_FUN_1802a5470(DAT_182edbc38);
                  if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                    FUN_180233680();
                  }
                  FUN_1813e2b90(lVar8,DAT_182ebcce8);
                  *(longlong *)(lVar7 + 0xb0) = lVar8;
                  FUN_180232f70(lVar7 + 0xb0,lVar8);
                }
                lVar8 = *(longlong *)(lVar7 + 0xa8);
                if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                *(int *)(lVar8 + 0x1c) = *(int *)(lVar8 + 0x1c) + 1;
                *(undefined4 *)(lVar8 + 0x18) = 0;
                if (*(longlong *)(lVar7 + 0xa0) == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                FUN_1812b6700(*(longlong *)(lVar7 + 0xa0),DAT_182eb70a8);
                lVar8 = *(longlong *)(lVar7 + 0xb0);
                if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                *(int *)(lVar8 + 0x1c) = *(int *)(lVar8 + 0x1c) + 1;
                *(undefined4 *)(lVar8 + 0x18) = 0;
                *(undefined2 *)(lVar7 + 0x8a) = 0;
              }
            }
            AISystemState__Start(&local_48,DAT_182efd4f0);
            iVar1 = *(int *)(lVar3 + 0x10);
            if (0 < iVar1) {
              do {
                if (*(longlong *)(lVar6 + 0x20) == 0) goto LAB_18048a491;
                iVar5 = FUN_1813fe630(*(longlong *)(lVar6 + 0x20),iVar9,DAT_182ebe118);
                if (0 < iVar5) {
                  lVar7 = *(longlong *)(lVar6 + 0x10);
                  if (lVar7 == 0) goto LAB_18048a491;
                  if ((iVar5 < *(int *)(lVar7 + 0x18)) &&
                     (lVar7 = FUN_1813e2d10(lVar7,iVar5,DAT_182ed80a8), lVar7 != 0)) {
                    if (*(longlong *)(lVar7 + 0xa8) == 0) goto LAB_18048a491;
                    FUN_1800048f0(*(longlong *)(lVar7 + 0xa8),iVar9,DAT_182ebcf70);
                  }
                }
                iVar9 = iVar9 + 1;
              } while (iVar9 < iVar1);
            }
            if (*(longlong *)(lVar6 + 0x10) != 0) {
              uVar2 = *(undefined4 *)(*(longlong *)(lVar6 + 0x10) + 0x18);
              lVar7 = thunk_FUN_1802a5470(DAT_182edcd98);
              if (lVar7 != 0) {
                Steamworks_SteamAPI_CheckCallbackRegistered_t___ctor(lVar7,lVar6,DAT_182ef93e8,0);
                if (*(int *)(DAT_182e93d88 + 0xe0) == 0) {
                  il2cpp_runtime_class_init();
                }
                System_Threading_Tasks_Parallel__For(&local_60,0,uVar2,lVar7,0);
                return;
              }
            }
          }
        }
      }
    }
  }
LAB_18048a491:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

