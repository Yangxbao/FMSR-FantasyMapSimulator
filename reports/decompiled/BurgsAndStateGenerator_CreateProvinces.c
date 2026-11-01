
longlong BurgsAndStateGenerator__CreateProvinces(longlong param_1)

{
  undefined4 uVar1;
  longlong lVar2;
  int iVar3;
  undefined4 uVar4;
  longlong lVar5;
  longlong lVar6;
  longlong lVar7;
  undefined8 uVar8;
  int iVar9;
  int local_res18 [2];
  longlong local_res20;
  undefined8 local_88;
  undefined8 uStack_80;
  longlong local_78;
  undefined8 local_68;
  undefined8 uStack_60;
  
  if (DAT_183060234 == '\0') {
    FUN_1802334a0(&DAT_182ed7328);
    FUN_1802334a0(&DAT_182ed70a0);
    FUN_1802334a0(&DAT_182ed7fd0);
    FUN_1802334a0(&DAT_182e99de8);
    FUN_1802334a0(&DAT_182e99eb8);
    FUN_1802334a0(&DAT_182ea15c0);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182ee07f0);
    FUN_1802334a0(&DAT_182e9c428);
    FUN_1802334a0(&DAT_182eaaee0);
    FUN_1802334a0(&DAT_182e94b40);
    FUN_1802334a0(&DAT_182e75d30);
    DAT_183060234 = '\x01';
  }
  if (*(longlong *)(param_1 + 0x10) != 0) {
    lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x270);
    local_res20 = lVar6;
    lVar5 = thunk_FUN_1802a5470(DAT_182ee07f0);
    local_78 = lVar5;
    if (lVar5 != 0) {
      FUN_1813e2b90(lVar5,DAT_182ed70a0);
      if ((*(longlong *)(param_1 + 0x10) != 0) &&
         (lVar2 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x288), lVar2 != 0)) {
        iVar9 = *(int *)(lVar2 + 0x18);
        if (iVar9 == 0) {
          lVar6 = thunk_FUN_1802a5470(DAT_182e9c428);
          if (lVar6 == 0) goto LAB_180484b3d;
          local_88 = 0x3f8000003f800000;
          uStack_80 = 0x3f8000003f800000;
          Province___ctor(lVar6,0,&local_88,DAT_182eaaee0,0,0,DAT_182e75d30,0,0,0);
          FUN_180304090(lVar5,lVar6,DAT_182ed7328);
          iVar9 = 1;
          lVar6 = local_res20;
        }
        if (*(longlong *)(param_1 + 0x10) != 0) {
          lVar2 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
          local_res18[0] = 0;
          if (lVar6 != 0) {
            do {
              if (*(int *)(lVar6 + 0x18) <= local_res18[0]) {
                return lVar5;
              }
              if (local_res18[0] != 0) {
                lVar7 = FUN_1813e2d10(lVar6,local_res18[0],DAT_182e99eb8);
                if (((lVar2 == 0) || (lVar7 == 0)) || (*(longlong *)(lVar2 + 0xc0) == 0)) break;
                iVar3 = FUN_1813fe630(*(longlong *)(lVar2 + 0xc0),*(undefined4 *)(lVar7 + 0x38),
                                      DAT_182ebe118);
                lVar6 = local_res20;
                if ((iVar3 == 0) && (*(char *)(lVar7 + 0x66) != '\0')) {
                  *(int *)(lVar7 + 0x10) = local_res18[0];
                  if (*(longlong *)(lVar2 + 0xa8) == 0) break;
                  uVar4 = FUN_1813fe630(*(longlong *)(lVar2 + 0xa8),*(undefined4 *)(lVar7 + 0x38),
                                        DAT_182ebe118);
                  *(undefined4 *)(lVar7 + 0x40) = uVar4;
                  *(int *)(lVar7 + 0x60) = iVar9;
                  if (*(longlong *)(lVar2 + 0x88) == 0) break;
                  uVar4 = FUN_1813fe630(*(longlong *)(lVar2 + 0x88),*(undefined4 *)(lVar7 + 0x38),
                                        DAT_182ebe118);
                  *(undefined4 *)(lVar7 + 0x3c) = uVar4;
                  if (*(longlong *)(lVar2 + 0x78) == 0) break;
                  uVar4 = FUN_1813fe630(*(longlong *)(lVar2 + 0x78),*(undefined4 *)(lVar7 + 0x38),
                                        DAT_182ebe118);
                  *(undefined4 *)(lVar7 + 0x44) = uVar4;
                  uVar8 = System_Int32__ToString(local_res18,0);
                  local_88 = System_String__Concat(DAT_182e94b40,uVar8,0);
                  if (((*(longlong *)(param_1 + 0x10) == 0) ||
                      (lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x280), lVar6 == 0)) ||
                     (lVar6 = FUN_1813e2d10(lVar6,*(undefined4 *)(lVar7 + 0x3c),DAT_182ea15c0),
                     iVar3 = local_res18[0], lVar6 == 0)) break;
                  uVar8 = *(undefined8 *)(lVar6 + 0x58);
                  uVar4 = *(undefined4 *)(lVar7 + 0x38);
                  uVar1 = *(undefined4 *)(lVar7 + 0x3c);
                  lVar6 = thunk_FUN_1802a5470(DAT_182e9c428);
                  if (lVar6 == 0) break;
                  local_68 = 0;
                  uStack_60 = 0x3f80000000000000;
                  Province___ctor(lVar6,iVar9,&local_68,local_88,0x3f800000,iVar3,uVar8,uVar4,uVar1,
                                  0);
                  *(undefined1 *)(lVar6 + 0x89) = 1;
                  if (*(longlong *)(lVar2 + 0x90) == 0) break;
                  FUN_181409950(*(longlong *)(lVar2 + 0x90),*(undefined4 *)(lVar7 + 0x38),
                                local_res18[0],DAT_182ebe2c8);
                  lVar5 = local_78;
                  FUN_180304090(local_78,lVar6,DAT_182ed7328);
                  iVar9 = iVar9 + 1;
                  lVar6 = local_res20;
                }
              }
              local_res18[0] = local_res18[0] + 1;
            } while( true );
          }
        }
      }
    }
  }
LAB_180484b3d:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

