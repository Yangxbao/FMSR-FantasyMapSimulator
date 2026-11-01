
longlong BurgsAndStateGenerator__CreateStates(longlong param_1)

{
  undefined4 uVar1;
  longlong lVar2;
  int iVar3;
  undefined4 uVar4;
  longlong lVar5;
  longlong lVar6;
  longlong lVar7;
  undefined8 uVar8;
  longlong lVar9;
  int iVar10;
  float fVar11;
  double dVar12;
  int local_res8 [2];
  undefined8 local_88;
  undefined8 uStack_80;
  
  if (DAT_183060232 == '\0') {
    FUN_1802334a0(&DAT_182eadff0);
    FUN_1802334a0(&DAT_182ee6228);
    FUN_1802334a0(&DAT_182ee6080);
    FUN_1802334a0(&DAT_182ee6c18);
    FUN_1802334a0(&DAT_182e99de8);
    FUN_1802334a0(&DAT_182e99eb8);
    FUN_1802334a0(&DAT_182ea15c0);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182ee32b8);
    FUN_1802334a0(&DAT_182ebb9c0);
    FUN_1802334a0(&DAT_182eaaee0);
    FUN_1802334a0(&DAT_182e94b40);
    FUN_1802334a0(&DAT_182e96208);
    FUN_1802334a0(&DAT_182e75d30);
    DAT_183060232 = '\x01';
  }
  if (*(longlong *)(param_1 + 0x10) != 0) {
    lVar2 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x270);
    lVar5 = thunk_FUN_1802a5470(DAT_182ee32b8);
    if (lVar5 != 0) {
      FUN_1813e2b90(lVar5,DAT_182ee6080);
      if ((*(longlong *)(param_1 + 0x10) != 0) &&
         (lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x290), lVar6 != 0)) {
        iVar10 = *(int *)(lVar6 + 0x18);
        if (iVar10 == 0) {
          lVar6 = thunk_FUN_1802a5470(DAT_182ebb9c0);
          if (lVar6 == 0) goto LAB_180485cbd;
          local_88 = 0x3f8000003f800000;
          uStack_80 = 0x3f8000003f800000;
          State___ctor(lVar6,0,&local_88,DAT_182eaaee0,0,0,DAT_182e75d30,0,0,0);
          FUN_180304090(lVar5,lVar6,DAT_182ee6228);
          iVar10 = 1;
        }
        if (lVar2 != 0) {
          iVar3 = *(int *)(lVar2 + 0x18);
          if (*(int *)(DAT_182eadff0 + 0xe0) == 0) {
            il2cpp_runtime_class_init();
          }
          DefaultNamespace_ColorUtils__GetColors(iVar3 + -1,0);
          RandomUtils__Each(5,0);
          if (*(longlong *)(param_1 + 0x10) != 0) {
            lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x148);
            local_res8[0] = 0;
            do {
              if (*(int *)(lVar2 + 0x18) <= local_res8[0]) {
                return lVar5;
              }
              if (local_res8[0] != 0) {
                lVar7 = FUN_1813e2d10(lVar2,local_res8[0],DAT_182e99eb8);
                if (lVar7 == 0) break;
                if (*(int *)(lVar7 + 0x58) != 0) {
                  if ((lVar6 == 0) || (*(longlong *)(lVar6 + 0xa8) == 0)) break;
                  iVar3 = FUN_1813fe630(*(longlong *)(lVar6 + 0xa8),*(undefined4 *)(lVar7 + 0x38),
                                        DAT_182ebe118);
                  if ((iVar3 == 0) && (*(char *)(lVar7 + 0x66) != '\0')) {
                    *(int *)(lVar7 + 0x10) = local_res8[0];
                    *(int *)(lVar7 + 0x40) = iVar10;
                    if (*(longlong *)(lVar6 + 0x88) == 0) break;
                    uVar4 = FUN_1813fe630(*(longlong *)(lVar6 + 0x88),*(undefined4 *)(lVar7 + 0x38),
                                          DAT_182ebe118);
                    *(undefined4 *)(lVar7 + 0x3c) = uVar4;
                    if (*(longlong *)(lVar6 + 0x78) == 0) break;
                    uVar4 = FUN_1813fe630(*(longlong *)(lVar6 + 0x78),*(undefined4 *)(lVar7 + 0x38),
                                          DAT_182ebe118);
                    *(undefined4 *)(lVar7 + 0x44) = uVar4;
                    *(undefined4 *)(lVar7 + 0x58) = 1;
                    fVar11 = (float)UnityEngine_Random__get_value(0);
                    dVar12 = (double)MathUtility__Rn((double)(fVar11 * 5.0 + 1.0),1,0);
                    uVar8 = System_Int32__ToString(local_res8,0);
                    System_String__Concat(DAT_182e96208,uVar8,0);
                    uVar8 = System_Int32__ToString(local_res8,0);
                    System_String__Concat(DAT_182e94b40,uVar8,0);
                    if (((*(longlong *)(param_1 + 0x10) == 0) ||
                        (lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x280), lVar9 == 0))
                       || (lVar9 = FUN_1813e2d10(lVar9,*(undefined4 *)(lVar7 + 0x3c),DAT_182ea15c0),
                          iVar3 = local_res8[0], lVar9 == 0)) break;
                    uVar8 = *(undefined8 *)(lVar9 + 0x58);
                    uVar4 = *(undefined4 *)(lVar7 + 0x3c);
                    uVar1 = *(undefined4 *)(lVar7 + 0x38);
                    lVar9 = thunk_FUN_1802a5470(DAT_182ebb9c0);
                    if (lVar9 == 0) break;
                    local_88 = 0;
                    uStack_80 = 0x3f80000000000000;
                    State___ctor(lVar9,iVar10,&local_88,0,(float)dVar12,iVar3,uVar8,uVar1,uVar4,0);
                    if (*(longlong *)(param_1 + 0x20) != 0) {
                      *(int *)(*(longlong *)(param_1 + 0x20) + 0x24) = iVar10;
                      lVar9 = *(longlong *)(param_1 + 0x20);
                      if (lVar9 == 0) break;
                      *(float *)(lVar9 + 0xdc) = (float)dVar12;
                      *(int *)(lVar9 + 0xe0) = local_res8[0];
                      lVar9 = *(longlong *)(param_1 + 0x20);
                      if (lVar9 == 0) break;
                      *(undefined8 *)(lVar9 + 0xd0) = uVar8;
                      FUN_180232f70(lVar9 + 0xd0,uVar8);
                      if (*(longlong *)(param_1 + 0x20) == 0) break;
                      *(undefined4 *)(*(longlong *)(param_1 + 0x20) + 0xa4) =
                           *(undefined4 *)(lVar7 + 0x38);
                      if (*(longlong *)(param_1 + 0x20) == 0) break;
                      *(undefined4 *)(*(longlong *)(param_1 + 0x20) + 0xc0) =
                           *(undefined4 *)(lVar7 + 0x3c);
                      lVar9 = *(longlong *)(param_1 + 0x20);
                    }
                    if (*(longlong *)(lVar6 + 0x90) == 0) break;
                    FUN_181409950(*(longlong *)(lVar6 + 0x90),*(undefined4 *)(lVar7 + 0x38),
                                  local_res8[0]);
                    FUN_180304090(lVar5,lVar9,DAT_182ee6228);
                    iVar10 = iVar10 + 1;
                  }
                }
              }
              local_res8[0] = local_res8[0] + 1;
            } while( true );
          }
        }
      }
    }
  }
LAB_180485cbd:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

