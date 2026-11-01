
longlong BurgsAndStateGenerator__CreateSeaProvinces(longlong param_1)

{
  int iVar1;
  longlong lVar2;
  longlong lVar3;
  undefined8 uVar4;
  int iVar5;
  undefined4 uVar6;
  longlong lVar7;
  longlong lVar8;
  undefined8 uVar9;
  longlong lVar10;
  int iVar11;
  int local_res18 [2];
  undefined4 local_res20;
  undefined8 local_68;
  undefined8 uStack_60;
  
  if (DAT_183060235 == '\0') {
    FUN_1802334a0(&DAT_182eadff0);
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
    FUN_1802334a0(&DAT_182e94b40);
    FUN_1802334a0(&DAT_182e96208);
    DAT_183060235 = '\x01';
  }
  local_res18[0] = 0;
  if (*(longlong *)(param_1 + 0x10) != 0) {
    lVar2 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x278);
    lVar7 = thunk_FUN_1802a5470(DAT_182ee07f0);
    if (lVar7 != 0) {
      FUN_1813e2b90(lVar7,DAT_182ed70a0);
      if (lVar2 != 0) {
        iVar1 = *(int *)(lVar2 + 0x18);
        if (*(int *)(DAT_182eadff0 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        DefaultNamespace_ColorUtils__GetColors(iVar1 + -1,0);
        lVar3 = *(longlong *)(param_1 + 0x10);
        if ((lVar3 != 0) && (*(longlong *)(lVar3 + 0x288) != 0)) {
          iVar1 = *(int *)(*(longlong *)(lVar3 + 0x288) + 0x18);
          iVar11 = 0;
          lVar3 = *(longlong *)(lVar3 + 0x148);
          do {
            if (*(int *)(lVar2 + 0x18) <= iVar11) {
              return lVar7;
            }
            if (iVar11 != 0) {
              local_res18[0] = iVar1 + -1 + iVar11;
              lVar8 = FUN_1813e2d10(lVar2,iVar11,DAT_182e99eb8);
              if (((lVar8 == 0) || (*(int *)(lVar8 + 0x10) = local_res18[0], lVar3 == 0)) ||
                 (*(longlong *)(lVar3 + 0xa8) == 0)) break;
              uVar6 = FUN_1813fe630(*(longlong *)(lVar3 + 0xa8),*(undefined4 *)(lVar8 + 0x38),
                                    DAT_182ebe118);
              *(undefined4 *)(lVar8 + 0x40) = uVar6;
              *(int *)(lVar8 + 0x60) = local_res18[0];
              if (*(longlong *)(lVar3 + 0x88) == 0) break;
              uVar6 = FUN_1813fe630(*(longlong *)(lVar3 + 0x88),*(undefined4 *)(lVar8 + 0x38),
                                    DAT_182ebe118);
              *(undefined4 *)(lVar8 + 0x3c) = uVar6;
              if (*(longlong *)(lVar3 + 0x78) == 0) break;
              uVar6 = FUN_1813fe630(*(longlong *)(lVar3 + 0x78),*(undefined4 *)(lVar8 + 0x38),
                                    DAT_182ebe118);
              *(undefined4 *)(lVar8 + 0x44) = uVar6;
              uVar9 = System_Int32__ToString(local_res18,0);
              System_String__Concat(DAT_182e96208,uVar9,0);
              uVar9 = System_Int32__ToString(local_res18,0);
              uVar9 = System_String__Concat(DAT_182e94b40,uVar9,0);
              if ((*(longlong *)(param_1 + 0x10) == 0) ||
                 (lVar10 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x280), lVar10 == 0))
              break;
              lVar10 = FUN_1813e2d10(lVar10,*(undefined4 *)(lVar8 + 0x3c),DAT_182ea15c0);
              iVar5 = local_res18[0];
              if (lVar10 == 0) break;
              uVar4 = *(undefined8 *)(lVar10 + 0x58);
              local_res20 = *(undefined4 *)(lVar8 + 0x3c);
              uVar6 = *(undefined4 *)(lVar8 + 0x38);
              lVar10 = thunk_FUN_1802a5470(DAT_182e9c428);
              if (lVar10 == 0) break;
              local_68 = 0;
              uStack_60 = 0x3f80000000000000;
              Province___ctor(lVar10,iVar5,&local_68,uVar9,0x3f800000,iVar11,uVar4,uVar6,local_res20
                              ,0);
              *(undefined1 *)(lVar10 + 0x89) = 0;
              if (*(longlong *)(lVar3 + 0x90) == 0) break;
              FUN_181409950(*(longlong *)(lVar3 + 0x90),*(undefined4 *)(lVar8 + 0x38),iVar11,
                            DAT_182ebe2c8);
              FUN_180304090(lVar7,lVar10,DAT_182ed7328);
            }
            iVar11 = iVar11 + 1;
          } while( true );
        }
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

